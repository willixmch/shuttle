import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shuttle/components/shuttle_card.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/utils/eta_calculator.dart';

// Stateful widget to display the home page with a list of shuttle routes.
// Refreshes ETAs every 15 seconds using a ValueNotifier for smooth updates.
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

  @override
  void initState() {
    super.initState();
    // Initialize the ValueNotifier for ETA updates.
    _etaNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
    // Load initial data and start the refresh timer.
    _loadInitialData();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    // Cancel the timer and dispose of the ValueNotifier.
    _refreshTimer?.cancel();
    _etaNotifier.dispose();
    super.dispose();
  }

  // Loads initial route and schedule data from the database.
  Future<void> _loadInitialData() async {
    final routes = await _dbHelper.getAllRoutes();
    final List<Map<String, dynamic>> routeData = [];
    final currentTime = DateTime.now();
    final dayType = EtaCalculator.getDayType(currentTime);

    for (var route in routes) {
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
          'eta': etaData['eta'],
          'upcomingEta': etaData['upcomingEta'],
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

  // Starts a 15-second timer to refresh ETAs.
  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted && _cachedRouteData.isNotEmpty) {
        final currentTime = DateTime.now();
        final dayType = EtaCalculator.getDayType(currentTime);
        final updatedRouteData =
            _cachedRouteData.map((data) {
              final schedules = data['schedules'] as List<Schedule>;
              final etaData = EtaCalculator.calculateEtas(
                schedules,
                currentTime,
              );
              return {
                'route': data['route'],
                'estate': data['estate'],
                'schedules': schedules,
                'eta': etaData['eta'],
                'upcomingEta': etaData['upcomingEta'],
              };
            }).toList();

        _etaNotifier.value = updatedRouteData;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The ReGent')),
      body: Container(
        margin: const EdgeInsets.all(16),
        child:
            _cachedRouteData.isEmpty
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
                        final route = routeData[index]['route'] as Routes;
                        final eta = routeData[index]['eta'] as String;
                        final upcomingEta =
                            routeData[index]['upcomingEta'] as List<String>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ShuttleCard(
                            route: route.routeName,
                            info: route.info,
                            eta: eta,
                            upcomingEta: upcomingEta,
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
