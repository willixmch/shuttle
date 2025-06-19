import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/utils/eta_calculator.dart';

// Service to manage periodic ETA refresh and updates.
class EtaRefreshTimer {
  Timer? _refreshTimer;
  final Function(List<Map<String, dynamic>>) onUpdate;
  final List<Map<String, dynamic>> Function() getRouteData; // Callback to get latest routeData
  final Stop? Function() getEffectiveStop; // Callback to get latest effectiveStop

  EtaRefreshTimer({
    required this.onUpdate,
    required this.getRouteData,
    required this.getEffectiveStop,
  });

  // Starts a timer to trigger at the start of each minute to decrement ETAs and handle expiry.
  void startRefreshTimer() {
    _refreshTimer?.cancel();
    
    // Calculate initial delay to the next minute boundary
    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;
    final initialDelay = Duration(seconds: secondsUntilNextMinute);

    // Run the first update after the initial delay, then every 60 seconds
    _refreshTimer = Timer(initialDelay, () {
      _updateEtas();
      // Start periodic timer for subsequent updates
      _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
        _updateEtas();
      });
    });
  }

  // Updates ETAs for all routes and triggers the onUpdate callback.
  void _updateEtas() {
    final routeData = getRouteData();
    final effectiveStop = getEffectiveStop();

    if (routeData.isNotEmpty) {
      final currentTime = DateTime.now();
      final updatedRouteData = routeData.map((data) {
        final schedules = data['schedules'] as List<Schedule>;
        int? currentEta = data['eta'] as int?;
        List<int> upcomingEta = List<int>.from(data['upcomingEta'] as List);
        final etaNotifier = data['etaNotifier'] as ValueNotifier<String>;
        final upcomingEtaNotifier = data['upcomingEtaNotifier'] as ValueNotifier<List<String>>;

        // If no stop or no ETA, clear ETAs
        if (effectiveStop == null || currentEta == null) {
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

        // Decrement ETAs
        currentEta = currentEta - 1;
        upcomingEta = upcomingEta.map((eta) => eta - 1).toList();

        // Handle expired ETA
        if (currentEta <= -1) {
          if (upcomingEta.isNotEmpty) {
            currentEta = upcomingEta.removeAt(0);
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
            currentEta = null;
            upcomingEta = [];
          }
        }

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

      onUpdate(updatedRouteData);
    }
  }

  // Cancels the refresh timer.
  void dispose() {
    _refreshTimer?.cancel();
  }
}