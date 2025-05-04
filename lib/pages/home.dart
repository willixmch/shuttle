import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // For location services and distance calculation
import 'package:shuttle/components/estate_filter_sheet.dart';
import 'package:shuttle/components/home_bar.dart';
import 'package:shuttle/components/shuttle_card.dart';
import 'package:shuttle/components/stop_filter_sheet.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/utils/eta_calculator.dart';
import 'package:shuttle/utils/persistence_data.dart';
import 'package:shuttle/utils/eta_refresh_timer.dart';

// Stateful widget to display the home page with a list of shuttle routes.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final PersistenceData _persistenceData = PersistenceData();
  late final EtaRefreshTimer _etaRefreshTimer;
  List<Map<String, dynamic>> _cachedRouteData = [];
  late ValueNotifier<List<Map<String, dynamic>>> _etaNotifier;
  Estate? _selectedEstate;
  Stop? _selectedStop;
  int? _expandedCardIndex;
  Position? _userPosition; // Store user's current location
  DateTime? _backgroundTime; // Track when app goes to background

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    _etaNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _etaRefreshTimer = EtaRefreshTimer(
      onUpdate: (updatedRouteData) {
        if (mounted) {
          setState(() {
            _cachedRouteData = updatedRouteData;
            _etaNotifier.value = updatedRouteData;
          });
        }
      },
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove lifecycle observer
    _etaRefreshTimer.dispose();
    _etaNotifier.dispose();
    super.dispose();
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now(); // Record time when app goes to background
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTime != null) {
        final duration = DateTime.now().difference(_backgroundTime!);
        if (duration.inMinutes >= 30) {
          // Refresh closest stop after 30 minutes in background
          _selectedStop = null; // Reset manual selection
          _loadInitialData();
        }
      }
      _backgroundTime = null; // Clear background time
    }
  }

  // Checks if location services are enabled and permissions are granted
  Future<bool> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false; // Location services disabled
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false; // Permission denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Permission permanently denied
    }

    return true; // Permissions granted
  }

  // Finds the closest stop based on user's location
  Future<Stop?> _findClosestStop() async {
    if (_userPosition == null || _selectedEstate == null) {
      return null; // No location or estate selected
    }

    final stops = await _dbHelper.getStopsForEstate(_selectedEstate!.estateId);
    if (stops.isEmpty) {
      return null; // No stops available
    }

    Stop? closestStop;
    double minDistance = double.infinity;

    for (var stop in stops) {
      if (stop.latitude == null || stop.longitude == null) {
        continue; // Skip stops without coordinates
      }

      final distance = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        stop.latitude!,
        stop.longitude!,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestStop = stop;
      }
    }

    return closestStop;
  }

  // Loads initial data, including persisted estate and route data
  Future<void> _loadInitialData() async {
    // Load persisted estate
    final persistedData = await _persistenceData.loadPersistedData();
    if (mounted && persistedData['estate'] != null) {
      setState(() {
        _selectedEstate = persistedData['estate'];
      });
    }

    // Get user's location
    if (await _checkLocationPermissions()) {
      try {
        _userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        _userPosition = null; // Handle location retrieval failure
      }
    } else {
      _userPosition = null; // No permissions or services
    }

    // Select closest stop if no manual selection
    if (_selectedStop == null && _selectedEstate != null) {
      _selectedStop = await _findClosestStop();
    }

    // Load route and schedule data
    final routes = await _dbHelper.getAllRoutes();
    final List<Map<String, dynamic>> routeData = [];
    final currentTime = DateTime.now();
    final dayType = EtaCalculator.getDayType(currentTime);

    final defaultStop = Stop(
      stopId: 'default',
      stopNameZh: 'Default Stop',
      routeId: '',
      etaOffset: 0,
    );
    final effectiveStop = _selectedStop ?? defaultStop;

    for (var route in routes) {
      if (_selectedEstate != null && route.estateId != _selectedEstate!.estateId) {
        continue;
      }

      final stops = await _dbHelper.getStopsForRoute(route.routeId);
      if (_selectedStop != null && !stops.any((stop) => stop.stopId == _selectedStop!.stopId)) {
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
          'eta': etaData['eta'],
          'upcomingEta': etaData['upcomingEta'],
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

    if (mounted) {
      setState(() {
        _cachedRouteData = routeData;
        _etaNotifier.value = routeData;
      });
      _etaRefreshTimer.startRefreshTimer(routeData, effectiveStop);
    }
  }

  // Shows the bottom sheet for estate filtering
  void _showEstateFilterSheet() {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EstateFilterSheet(
          onEstateSelected: (Estate estate) async {
            await _persistenceData.saveEstate(estate);
            setState(() {
              _selectedEstate = estate;
              _selectedStop = null;
              _expandedCardIndex = null;
            });
            await _loadInitialData();
          },
        );
      },
    );
  }

  // Shows the bottom sheet for stop filtering
  void _showStopFilterSheet() {
    showModalBottomSheet(
      showDragHandle: true,
      enableDrag: true,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StopFilterSheet(
          estateId: _selectedEstate?.estateId ?? '',
          onStopSelected: (Stop stop) async {
            setState(() {
              _selectedStop = stop;
              _expandedCardIndex = null;
            });
            await _loadInitialData();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeBar(
        estateOnTap: _showEstateFilterSheet,
        estateTitle: _selectedEstate?.estateTitleZh ?? '-',
        locationOnTap: _showStopFilterSheet,
        stopTitle: _selectedStop?.stopNameZh ?? '-',
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: _cachedRouteData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _etaNotifier,
                builder: (context, routeData, child) {
                  if (routeData.isEmpty) {
                    return const Center(child: Text('沒有可用的路線'));
                  }

                  return ListView.builder(
                    itemCount: routeData.length,
                    itemBuilder: (context, index) {
                      final data = routeData[index];
                      final route = data['route'] as Routes?;
                      final etaNotifier = data['etaNotifier'] as ValueNotifier<String>;
                      final upcomingEtaNotifier = data['upcomingEtaNotifier'] as ValueNotifier<List<String>>;

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
                                _expandedCardIndex = null;
                              } else {
                                _expandedCardIndex = index;
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