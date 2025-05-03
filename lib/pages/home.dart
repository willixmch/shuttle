import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shuttle/components/estate_filter_sheet.dart';
import 'package:shuttle/components/home_bar.dart';
import 'package:shuttle/components/shuttle_card.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/utils/eta_calculator.dart';
import 'package:shuttle/utils/persistence_data.dart';
import 'package:shuttle/utils/eta_refresh_timer.dart';

// Stateful widget to display the home page with a list of shuttle routes.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final PersistenceData _persistenceService = PersistenceData();
  late final EtaRefreshTimer _etaRefreshService;
  List<Map<String, dynamic>> _cachedRouteData = [];
  late ValueNotifier<List<Map<String, dynamic>>> _etaNotifier;
  Estate? _selectedEstate;
  Stop? _selectedStop;
  int? _expandedCardIndex;

  @override
  void initState() {
    super.initState();
    _etaNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    _etaRefreshService = EtaRefreshTimer(
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
    _etaRefreshService.dispose();
    _etaNotifier.dispose();
    super.dispose();
  }

  // Loads initial data, including persisted estate/stop and route data.
  Future<void> _loadInitialData() async {
    // Load persisted estate and stop
    final persistedData = await _persistenceService.loadPersistedData();
    if (mounted && persistedData['estate'] != null) {
      setState(() {
        _selectedEstate = persistedData['estate'];
        _selectedStop = persistedData['stop'];
      });
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
        print('Skipping route ${route.routeId}: estateId mismatch');
        continue;
      }

      final stops = await _dbHelper.getStopsForRoute(route.routeId);
      if (_selectedStop != null && !stops.any((stop) => stop.stopId == _selectedStop!.stopId)) {
        print('Skipping route ${route.routeId}: no matching stop');
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

    print('Loaded routes: ${routeData.map((e) => e['route'].routeId)}');
    if (mounted) {
      setState(() {
        _cachedRouteData = routeData;
        _etaNotifier.value = routeData;
      });
      _etaRefreshService.startRefreshTimer(routeData, effectiveStop);
    }
  }

  // Shows the bottom sheet for estate filtering.
  void _showEstateFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EstateFilterSheet(
          onEstateSelected: (Estate estate) async {
            await _persistenceService.saveEstate(estate);
            setState(() {
              _selectedEstate = estate;
              _selectedStop = null;
              _expandedCardIndex = null;
            });
            await _persistenceService.clearStop();
            await _loadInitialData();
          },
        );
      },
    );
  }

  // Handles stop selection
  void _onStopSelected(Stop stop) async {
    await _persistenceService.saveStop(stop);
    setState(() {
      _selectedStop = stop;
      _expandedCardIndex = null;
    });
    await _loadInitialData();
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