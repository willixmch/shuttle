import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shuttle/components/estate_filter_sheet.dart';
import 'package:shuttle/components/home_bar.dart';
import 'package:shuttle/components/shuttle_card.dart';
import 'package:shuttle/components/stop_filter_sheet.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/services/day_type_checker.dart';
import 'package:shuttle/services/location_service.dart';
import 'package:shuttle/services/route_query.dart';
import 'package:shuttle/utils/persistence_estate.dart';
import 'package:shuttle/utils/eta_refresh_timer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final PersistenceEstate _persistenceEstate = PersistenceEstate();
  final LocationService _locationService = LocationService();
  final RouteQuery _routeQuery;
  late final EtaRefreshTimer _etaRefreshTimer;
  List<Map<String, dynamic>> _cachedRouteData = [];
  late ValueNotifier<List<Map<String, dynamic>>> _etaNotifier;
  Estate? _selectedEstate;
  Stop? _selectedStop;
  int? _expandedCardIndex;
  Position? _userPosition;
  DateTime? _backgroundTime;

  _HomeState() : _routeQuery = RouteQuery(DatabaseHelper.instance);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add lifecycle observer
    DayTypeChecker.initialize();
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
      getRouteData: () => _cachedRouteData,
      getEffectiveStop: () => _selectedStop,
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

  // Loads initial data, including persisted estate and route data
  Future<void> _loadInitialData() async {
    // Load persisted estate from storage
    final persistenceEstate = await _persistenceEstate.loadPersistenceEstate();
    if (mounted && persistenceEstate['estate'] != null) {
      setState(() {
        _selectedEstate = persistenceEstate['estate']; // Set the persisted estate as selected
      });
    }

    // Get user's location
    _userPosition = await _locationService.getCurrentPosition();

    // Select closest stop or first stop if no manual selection
    if (_selectedStop == null) {
      if (_userPosition != null) {
        _selectedStop = await _locationService.findClosestStop(
          _userPosition!,
          _selectedEstate!.estateId,
          _dbHelper,
        );
      }
      if (_selectedStop == null) {
        final stops = await _dbHelper.getStopsForEstate(_selectedEstate!.estateId);
        if (stops.isNotEmpty) {
          _selectedStop = stops.first;
        }
      }
    }

    // Load route data
    final routeData = await _routeQuery.loadRouteData(
      selectedEstate: _selectedEstate,
      selectedStop: _selectedStop,
    );

    // Update state if the widget is still mounted
    if (mounted) {
      setState(() {
        _cachedRouteData = routeData; // Cache the processed route data
        _etaNotifier.value = routeData; // Update ETA notifier with new data
      });
      _etaRefreshTimer.startRefreshTimer(); // Start timer to periodically refresh ETA data
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
            await _persistenceEstate.saveEstate(estate);
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