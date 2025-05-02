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
  Estate? _selectedEstate; // Track selected estate

  @override
  void initState() {
    super.initState();
    // Initialize the ValueNotifier for ETA updates.
    _etaNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    // Load persisted estate and initial data, then start the refresh timer.
    _loadPersistedEstate();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    // Cancel the timer and dispose of the ValueNotifier.
    _refreshTimer?.cancel();
    _etaNotifier.dispose();
    super.dispose();
  }

  // Loads the persisted estate from SharedPreferences or defaults to the first estate.
  Future<void> _loadPersistedEstate() async {
    final prefs = await SharedPreferences.getInstance();
    Estate? selectedEstate;

    // Try to load persisted estate
    final estateId = prefs.getString('selectedEstateId');
    if (estateId != null) {
      selectedEstate = await _dbHelper.getEstateById(estateId);
    }

    // If no persisted estate or invalid, default to the first estate in the list
    if (selectedEstate == null) {
      final estates = await _dbHelper.getAllEstates();
      if (estates.isNotEmpty) {
        selectedEstate = estates.first;
        // Persist the default estate
        await prefs.setString('selectedEstateId', selectedEstate.estateId);
      }
    }

    if (mounted && selectedEstate != null) {
      setState(() {
        _selectedEstate = selectedEstate;
      });
    }

    await _loadInitialData();
  }

  // Loads initial route and schedule data from the database, filtered by selected estate.
  Future<void> _loadInitialData() async {
    final routes = await _dbHelper.getAllRoutes();
    final List<Map<String, dynamic>> routeData = [];
    final currentTime = DateTime.now();
    final dayType = EtaCalculator.getDayType(currentTime);

    for (var route in routes) {
      // Filter routes by selected estate, if any
      if (_selectedEstate != null && route.estateId != _selectedEstate!.estateId) {
        continue;
      }

      final estate = await _dbHelper.getEstateById(route.estateId);
      final schedules = await _dbHelper.getSchedulesForRoute(
        route.routeId,
        dayType,
      );
      final etaData = EtaCalculator.calculateEtas(schedules, currentTime);

      if (estate != null) {
        routeData.add({
          'route': route,
          'estate': estate,
          'schedules': schedules,
          'eta': etaData['eta'], // int? (minutes)
          'upcomingEta': etaData['upcomingEta'], // List<int>
        });
      }
    }

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
        final updatedRouteData = _cachedRouteData.map((data) {
          final schedules = data['schedules'] as List<Schedule>;
          int? currentEta = data['eta'] as int?;
          List<int> upcomingEta = List<int>.from(data['upcomingEta'] as List);

          if (currentEta == null) {
            return {
              'route': data['route'],
              'estate': data['estate'],
              'schedules': schedules,
              'eta': null,
              'upcomingEta': <int>[],
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

          return {
            'route': data['route'],
            'estate': data['estate'],
            'schedules': schedules,
            'eta': currentEta,
            'upcomingEta': upcomingEta,
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
      builder: (context) {
        return EstateFilterSheet(
          onEstateSelected: (Estate estate) async {
            setState(() {
              _selectedEstate = estate; // Update selected estate
            });
            // Save the selected estate to SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('selectedEstateId', estate.estateId);
            await _loadInitialData(); // Refresh routes for the selected estate
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeBar(
        onTap: _showEstateFilterSheet, // Pass callback to HomeBar
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: _cachedRouteData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _etaNotifier,
                builder: (context, routeData, child) {
                  if (routeData.isEmpty) {
                    // Show message if no routes are found.
                    return const Center(child: Text('No routes available'));
                  }

                  // Build list of ShuttleCard widgets from cached data.
                  return ListView.builder(
                    itemCount: routeData.length,
                    itemBuilder: (context, index) {
                      final data = routeData[index];
                      final route = data['route'] as Routes?;
                      final eta = data['eta'] as int?;
                      final upcomingEta = data['upcomingEta'] as List<dynamic>?;

                      // Handle null or malformed data gracefully.
                      if (route == null || upcomingEta == null) {
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

                      // Ensure upcomingEta contains valid integers.
                      final formattedUpcomingEta = upcomingEta
                          .cast<int>()
                          .map((e) => EtaCalculator.formatEta(e))
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ShuttleCard(
                          route: route.routeName,
                          info: route.info,
                          eta: EtaCalculator.formatEta(eta),
                          upcomingEta: formattedUpcomingEta,
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