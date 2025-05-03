import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttle/components/estate_filter_sheet.dart';
import 'package:shuttle/components/home_bar.dart';
import 'package:shuttle/components/shuttle_card.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/utils/eta_calculator.dart';

// Stateful widget to display the home page with a list of shuttle routes.
// Stores ETAs as integers, decrements them every 60 seconds, and shifts ETAs when one expires.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Timer? _refreshTimer;
  List<Map<String, dynamic>> _cachedRouteData = [];
  late ValueNotifier<List<Map<String, dynamic>>> _etaNotifier;
  Estate? _selectedEstate; // Track selected estate (non-null after init)
  Stop? _selectedStop; // Track selected stop (may be null if no stops)
  int? _expandedCardIndex; // Track index of expanded ShuttleCard (null if none)

  @override
  void initState() {
    super.initState();
    // Initialize the ValueNotifier for ETA updates.
    _etaNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    // Load persisted estate and stop, then start the refresh timer.
    _loadPersistedData();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    // Cancel the timer and dispose of the ValueNotifier.
    _refreshTimer?.cancel();
    _etaNotifier.dispose();
    super.dispose();
  }

  // Loads the persisted estate and stop from SharedPreferences or defaults to the first available.
  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    Estate? selectedEstate;
    Stop? selectedStop;

    // Try to load persisted estate
    final estateId = prefs.getString('selectedEstateId');
    if (estateId != null) {
      selectedEstate = await _dbHelper.getEstateById(estateId);
    }

    // If no persisted estate or invalid, default to the first estate
    if (selectedEstate == null) {
      final estates = await _dbHelper.getAllEstates();
      if (estates.isNotEmpty) {
        selectedEstate = estates.first;
        await prefs.setString('selectedEstateId', selectedEstate.estateId);
      }
    }

    // Try to load persisted stop
    if (selectedEstate != null) {
      final stopId = prefs.getString('selectedStopId');
      final stops = await _dbHelper.getStopsForEstate(selectedEstate.estateId);
      if (stopId != null && stops.isNotEmpty) {
        selectedStop = stops.firstWhere(
          (stop) => stop.stopId == stopId,
          orElse: () => stops.first, // Default to first stop if persisted stopId is invalid
        );
      } else if (stops.isNotEmpty) {
        // Default to the first stop if no persisted stopId
        selectedStop = stops.first;
      }

      // Persist the selected stop
      if (selectedStop != null) {
        await prefs.setString('selectedStopId', selectedStop.stopId);
      } else {
        // Clear persisted stopId if no stops are available
        await prefs.remove('selectedStopId');
      }
    }

    // Only set state if we have a valid estate
    if (mounted && selectedEstate != null) {
      setState(() {
        _selectedEstate = selectedEstate;
        _selectedStop = selectedStop; // May be null if no stops available
      });
    }

    await _loadInitialData();
  }

  // Loads initial route and schedule data from the database, filtered by selected estate and stop.
  Future<void> _loadInitialData() async {
    final routes = await _dbHelper.getAllRoutes();
    final List<Map<String, dynamic>> routeData = [];
    final currentTime = DateTime.now();
    final dayType = EtaCalculator.getDayType(currentTime);

    // Use a default stop if _selectedStop is null
    final defaultStop = Stop(
      stopId: 'default',
      stopNameZh: 'Default Stop',
      routeId: '',
      etaOffset: 0,
    );
    final effectiveStop = _selectedStop ?? defaultStop;

    for (var route in routes) {
      // Filter routes by selected estate
      if (_selectedEstate != null && route.estateId != _selectedEstate!.estateId) {
        print('Skipping route ${route.routeId}: estateId mismatch (${route.estateId} != ${_selectedEstate!.estateId})');
        continue;
      }

      // Check if the route includes the selected stop (skip if using default stop)
      final stops = await _dbHelper.getStopsForRoute(route.routeId);
      if (_selectedStop != null && !stops.any((stop) => stop.stopId == _selectedStop!.stopId)) {
        print('Skipping route ${route.routeId}: no matching stop ${_selectedStop!.stopId}');
        continue;
      }

      final estate = await _dbHelper.getEstateById(route.estateId);
      final schedules = await _dbHelper.getSchedulesForRoute(
        route.routeId,
        dayType,
      );
      final etaData = EtaCalculator.calculateEtas(schedules, currentTime, effectiveStop);

      if (estate != null) {
        routeData.add({
          'route': route,
          'estate': estate,
          'schedules': schedules,
          'eta': etaData['eta'], // int? (minutes)
          'upcomingEta': etaData['upcomingEta'], // List<int>
          'etaNotifier': ValueNotifier<String>(EtaCalculator.formatEta(etaData['eta'])),
          'upcomingEtaNotifier': ValueNotifier<List<String>>(
            (etaData['upcomingEta'] as List<dynamic>)
                .cast<int>()
                .map((e) => EtaCalculator.formatEta(e))
                .toList(),
          ),
        });
      }
    }

    print('Loaded routes for display: ${routeData.map((e) => e['route'].routeId)}'); // Debugging
    if (mounted) {
      setState(() {
        _cachedRouteData = routeData;
        _etaNotifier.value = routeData;
      });
    }
  }

  // Starts a 60-second timer to decrement ETAs and handle expiry.
  void _startRefreshTimer() {
    // Cancel any existing timer to prevent duplicates
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted && _cachedRouteData.isNotEmpty) {
        final currentTime = DateTime.now();
        // Use a default stop if _selectedStop is null
        final defaultStop = Stop(
          stopId: 'default',
          stopNameZh: 'Default Stop',
          routeId: '',
          etaOffset: 0,
        );
        final effectiveStop = _selectedStop ?? defaultStop;

        final updatedRouteData = _cachedRouteData.map((data) {
          final schedules = data['schedules'] as List<Schedule>;
          int? currentEta = data['eta'] as int?;
          List<int> upcomingEta = List<int>.from(data['upcomingEta'] as List);
          final etaNotifier = data['etaNotifier'] as ValueNotifier<String>;
          final upcomingEtaNotifier = data['upcomingEtaNotifier'] as ValueNotifier<List<String>>;

          if (currentEta == null) {
            etaNotifier.value = EtaCalculator.formatEta(null);
            upcomingEtaNotifier.value = [];
            return {
              'route': data['route'],
              'estate': data['estate'],
              'schedules': schedules,
              'eta': null,
              'upcomingEta': <int>[],
              'etaNotifier': etaNotifier,
              'upcomingEtaNotifier': upcomingEtaNotifier,
            };
          }

          // Decrement all ETAs by 1 minute.
          currentEta = currentEta - 1;
          upcomingEta = upcomingEta.map((eta) => eta - 1).toList();

          // Check if the current ETA has reached -1.
          if (currentEta <= -1) {
            if (upcomingEta.isNotEmpty) {
              // Shift the first upcoming ETA to current ETA.
              currentEta = upcomingEta.removeAt(0);
              // Calculate a new upcoming ETA if needed.
              if (upcomingEta.length < 2 && schedules.isNotEmpty) {
                final lastEta = upcomingEta.isNotEmpty ? upcomingEta.last : currentEta;
                final nextEta = EtaCalculator.calculateNextEta(
                  schedules,
                  currentTime,
                  lastEta,
                  effectiveStop,
                );
                if (nextEta != null) {
                  upcomingEta.add(nextEta);
                }
              }
            } else {
              // No more ETAs available.
              currentEta = null;
              upcomingEta = [];
            }
          }

          // Update notifiers
          etaNotifier.value = EtaCalculator.formatEta(currentEta);
          upcomingEtaNotifier.value = upcomingEta
              .map((e) => EtaCalculator.formatEta(e))
              .toList();

          return {
            'route': data['route'],
            'estate': data['estate'],
            'schedules': schedules,
            'eta': currentEta,
            'upcomingEta': upcomingEta,
            'etaNotifier': etaNotifier,
            'upcomingEtaNotifier': upcomingEtaNotifier,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _cachedRouteData = updatedRouteData;
            _etaNotifier.value = updatedRouteData;
          });
        }
      }
    });
  }

  // Shows the bottom sheet for estate filtering.
  void _showEstateFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EstateFilterSheet(
          onEstateSelected: (Estate estate) async {
            final prefs = await SharedPreferences.getInstance();
            setState(() {
              _selectedEstate = estate;
              _selectedStop = null; // Reset stop when estate changes
              _expandedCardIndex = null; // Collapse all cards
            });
            await prefs.setString('selectedEstateId', estate.estateId);
            await prefs.remove('selectedStopId'); // Clear persisted stop
            await _loadPersistedData(); // Refresh data
          },
        );
      },
    );
  }

  // Handles stop selection
  void _onStopSelected(Stop stop) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedStop = stop;
      _expandedCardIndex = null; // Collapse all cards
    });
    await prefs.setString('selectedStopId', stop.stopId);
    await _loadInitialData(); // Refresh routes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeBar(
        estateOnTap: _showEstateFilterSheet,
        estateTitle: _selectedEstate?.estateTitleZh ?? 'Select Estate',
        locationOnTap: () async {
          final stops = await _dbHelper.getStopsForEstate(_selectedEstate?.estateId ?? '');
          if (stops.isNotEmpty) {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    return ListTile(
                      title: Text(stop.stopNameZh),
                      onTap: () {
                        _onStopSelected(stop);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            );
          }
        },
        stopTitle: _selectedStop?.stopNameZh ?? 'Select Stop',
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: _cachedRouteData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _etaNotifier,
                builder: (context, routeData, child) {
                  // Show a message if no routes are available
                  if (routeData.isEmpty) {
                    return const Center(child: Text('沒有可用的路線'));
                  }

                  // Build list of ShuttleCard widgets from cached data.
                  return ListView.builder(
                    itemCount: routeData.length,
                    itemBuilder: (context, index) {
                      final data = routeData[index];
                      final route = data['route'] as Routes?;
                      final etaNotifier = data['etaNotifier'] as ValueNotifier<String>;
                      final upcomingEtaNotifier = data['upcomingEtaNotifier'] as ValueNotifier<List<String>>;

                      // Handle null or malformed data gracefully.
                      if (route == null) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              title: Text('Error'),
                              subtitle: Text('Invalid route data'),
                            ),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ShuttleCard(
                          route: route.routeName,
                          info: route.info,
                          eta: etaNotifier,
                          upcomingEta: upcomingEtaNotifier,
                          isExpanded: _expandedCardIndex == index,
                          onToggle: () {
                            setState(() {
                              if (_expandedCardIndex == index) {
                                _expandedCardIndex = null; // Collapse if already expanded
                              } else {
                                _expandedCardIndex = index; // Expand this card
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}