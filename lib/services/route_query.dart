import 'package:flutter/material.dart';
import 'package:shuttle/models/estate.dart';
import 'package:shuttle/models/routes.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/services/database_helper.dart';
import 'package:shuttle/utils/eta_calculator.dart';

class RouteQuery {
  final DatabaseHelper _dbHelper;

  RouteQuery(this._dbHelper);

  Future<List<Map<String, dynamic>>> loadRouteData({
    required Estate? selectedEstate,
    required Stop? selectedStop,
  }) async {
    // Return empty data if no estate is selected
    if (selectedEstate == null) {
      return [];
    }

    // Load routes and prepare route data
    final routes = await _dbHelper.getAllRoutes();
    final List<Map<String, dynamic>> routeData = [];
    final currentTime = DateTime.now();
    final dayType = EtaCalculator.getDayType(currentTime);

    for (var route in routes) {
      // Skip routes that don't match selected estate
      if (route.estateId != selectedEstate.estateId) {
        continue;
      }

      // Fetch stops associated with the current route
      final stops = await _dbHelper.getBoardingStopsForRoute(route.routeId);
      // Skip routes that don't include the selected stop
      if (selectedStop != null &&
          !stops.any((stop) => stop.stopId == selectedStop.stopId)) {
        continue;
      }

      // Retrieve estate details for the route
      final estate = await _dbHelper.getEstateById(route.estateId);
      if (estate == null) {
        continue; // Skip if estate data is missing
      }

      // Fetch schedules for the route based on the day type
      final schedules = await _dbHelper.getSchedulesForRoute(
        route.routeId,
        dayType,
      );

      // Build route data entry with ETA calculations
      final routeDataEntry = await _buildRouteDataEntry(
        route,
        estate,
        schedules,
        currentTime,
        selectedStop,
      );
      if (routeDataEntry != null) {
        routeData.add(routeDataEntry);
      }
    }

    return routeData;
  }

  // Builds a single route data entry, including ETA calculations via EtaCalculator
  Future<Map<String, dynamic>?> _buildRouteDataEntry(
    Routes route,
    Estate estate,
    List<Schedule> schedules,
    DateTime currentTime,
    Stop? selectedStop,
  ) async {
    // Skip ETA calculations if no stop is selected
    if (selectedStop == null) {
      return null;
    }

    // Calculate ETA and upcoming ETAs using EtaCalculator
    final etaData = EtaCalculator.calculateEtas(
      schedules,
      currentTime,
      selectedStop,
    );

    // Explicitly cast upcomingEta to List<int>
    final upcomingEta = (etaData['upcomingEta'] as List<dynamic>).cast<int>();

    // Create route data entry with notifiers for real-time updates
    return {
      'route': route,
      'estate': estate,
      'schedules': schedules,
      'eta': etaData['eta'],
      'upcomingEta': upcomingEta,
      'etaNotifier': ValueNotifier<String>(
        EtaCalculator.formatEta(etaData['eta']),
      ),
      'upcomingEtaNotifier': ValueNotifier<List<String>>(
        upcomingEta.map((e) => EtaCalculator.formatEta(e)).toList(),
      ),
    };
  }
}