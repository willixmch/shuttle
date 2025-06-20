import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';
import 'package:shuttle/utils/day_type_checker.dart';

// Combined service to manage ETA calculations, periodic updates, and app lifecycle events.
class EtaCalculator with WidgetsBindingObserver {
  // Static map for localized strings
  static String _languageCode = 'en'; // Default, overridden by device language
  static final Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'noService': 'No Service',
      'arriving': 'Arriving',
      'minutes': 'Mins',
      'hours': 'Hrs',
    },
    'zh': {
      'noService': '沒有服務',
      'arriving': '即將到達',
      'minutes': '分鐘',
      'hours': '小時',
    },
  };

  Timer? _refreshTimer;
  final Function(List<Map<String, dynamic>>)? onUpdate;
  final List<Map<String, dynamic>> Function()? getRouteData;
  final Stop? Function()? getEffectiveStop;

  EtaCalculator({
    this.onUpdate,
    this.getRouteData,
    this.getEffectiveStop,
  }) {
    // Register as a WidgetsBindingObserver to listen for lifecycle events
    WidgetsBinding.instance.addObserver(this);
    // Start the periodic timer
    startRefreshTimer();
  }

  // Method to update the language
  static void setLanguage(String languageCode) {
    if (_localizedStrings.containsKey(languageCode)) {
      _languageCode = languageCode;
    } else {
      _languageCode = 'en';
    }
  }

  // Determines the day type (workday or weekend) based on the given date.
  static String getDayType(DateTime date) {
    return DayTypeChecker.getDayType(date);
  }

  // Helper method to parse a schedule time into a DateTime for the current day.
  static DateTime _parseScheduleTime(String departureTime, DateTime currentTime) {
    final timeFormat = DateFormat('HH:mm');
    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final parsedTime = timeFormat.parse(departureTime);
    return today.add(Duration(hours: parsedTime.hour, minutes: parsedTime.minute));
  }

  // Calculates the next ETA and upcoming ETAs for a route based on the schedule time plus etaOffset.
  // Returns a map with 'eta' (int, minutes) and 'upcomingEta' (List<int>, minutes).
  static Map<String, dynamic> calculateEtas(
    List<Schedule> schedules,
    DateTime currentTime,
    Stop? stop,
  ) {
    if (schedules.isEmpty) {
      return {'eta': null, 'upcomingEta': []};
    }

    final etaOffset = stop?.etaOffset ?? 0;
    // Filter schedules with arrival times (departure + offset) after current time
    final futureDepartures = schedules
        .map((schedule) {
          final departureTime = _parseScheduleTime(schedule.departureTime, currentTime);
          // Add etaOffset to get the actual arrival time at the stop
          return departureTime.add(Duration(minutes: etaOffset));
        })
        .where((arrivalTime) => arrivalTime.isAfter(currentTime))
        .toList()
      ..sort();

    if (futureDepartures.isEmpty) {
      return {'eta': null, 'upcomingEta': []};
    }

    // Calculate ETAs based on the difference between arrival time and current time
    final etas = futureDepartures.map((arrivalTime) {
      final minutes = arrivalTime.difference(currentTime).inSeconds / 60;
      // Use floor for non-base stops (etaOffset > 0), ceil for base stops
      return etaOffset > 0 ? minutes.floor() : minutes.ceil();
    }).toList();

    // Return the first ETA and up to two upcoming ETAs
    return {
      'eta': etas.isEmpty ? null : etas[0],
      'upcomingEta': etas.skip(1).take(2).toList(),
    };
  }

  // Helper function to format minutes into a string (e.g., "Arriving", "6 Mins", or "2 Hrs 10 Mins").
  static String formatEta(int? minutes) {
    final strings = _localizedStrings[_languageCode]!;

    if (minutes == null || minutes < 0) {
      return strings['noService']!;
    }

    if (minutes == 0) {
      return strings['arriving']!;
    }

    if (minutes < 60) {
      return '$minutes ${strings['minutes']}';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours ${strings['hours']}';
    }
    return '$hours ${strings['hours']} $remainingMinutes ${strings['minutes']}';
  }

  // Starts a timer to trigger at the start of each minute to decrement ETAs and handle expiry.
  void startRefreshTimer() {
    _refreshTimer?.cancel();

    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;
    final initialDelay = Duration(seconds: secondsUntilNextMinute);

    _refreshTimer = Timer(initialDelay, () {
      _updateEtas();
      _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
        _updateEtas();
      });
    });
  }

  // Updates ETAs for all routes and triggers the onUpdate callback for periodic timer updates.
  void _updateEtas() {
    if (getRouteData == null || onUpdate == null || getEffectiveStop == null) {
      return;
    }

    final routeData = getRouteData!();
    final effectiveStop = getEffectiveStop!();
    final currentTime = DateTime.now();

    if (routeData.isNotEmpty) {
      final updatedRouteData = routeData.map((data) {
        final schedules = data['schedules'] as List<Schedule>;
        int? currentEta = data['eta'] as int?;
        List<int> upcomingEta = List<int>.from(data['upcomingEta'] as List);
        final etaNotifier = data['etaNotifier'] as ValueNotifier<String>;
        final upcomingEtaNotifier = data['upcomingEtaNotifier'] as ValueNotifier<List<String>>;

        // If no stop or no schedules, clear ETAs
        if (effectiveStop == null || schedules.isEmpty) {
          etaNotifier.value = formatEta(null);
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

        // Decrement ETAs if currentEta is valid and not expired
        if (currentEta != null && currentEta > -1) {
          currentEta = currentEta - 1;
          upcomingEta = upcomingEta.map((eta) => eta - 1).toList();
        }

        // If currentEta is null or expired, handle promotion or recalculate
        if (currentEta == null || currentEta <= -1) {
          if (upcomingEta.isNotEmpty) {
            currentEta = upcomingEta.removeAt(0); // Promote first upcoming ETA
          } else {
            // Recalculate to check for new ETAs
            final etas = calculateEtas(schedules, currentTime, effectiveStop);
            currentEta = etas['eta'] as int?;
            upcomingEta = List<int>.from(etas['upcomingEta'] as List);
          }

          // If still fewer than 2 upcoming ETAs, try to replenish
          if (upcomingEta.length < 2 && schedules.isNotEmpty) {
            final etas = calculateEtas(schedules, currentTime, effectiveStop);
            final newUpcomingEtas = etas['upcomingEta'] as List<int>;
            for (var eta in newUpcomingEtas) {
              if (upcomingEta.length < 2 && !upcomingEta.contains(eta)) {
                upcomingEta.add(eta);
              }
            }
          }
        }

        // Update notifiers, ensuring only first 2 upcoming ETAs are shown
        etaNotifier.value = formatEta(currentEta);
        upcomingEtaNotifier.value = upcomingEta.take(2).map((e) => formatEta(e)).toList();

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

      onUpdate!(updatedRouteData);
    }
  }

  // Refreshes ETAs by recalculating for all routes, used for app resume or manual refresh.
  void refreshEtas() {
    if (getRouteData == null || onUpdate == null || getEffectiveStop == null) {
      return;
    }

    final routeData = getRouteData!();
    final effectiveStop = getEffectiveStop!();
    final currentTime = DateTime.now();

    if (routeData.isNotEmpty) {
      final updatedRouteData = routeData.map((data) {
        final schedules = data['schedules'] as List<Schedule>;
        final etaNotifier = data['etaNotifier'] as ValueNotifier<String>;
        final upcomingEtaNotifier = data['upcomingEtaNotifier'] as ValueNotifier<List<String>>;

        // If no stop or no schedules, clear ETAs
        if (effectiveStop == null || schedules.isEmpty) {
          etaNotifier.value = formatEta(null);
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

        // Recalculate fresh ETAs
        final etas = calculateEtas(schedules, currentTime, effectiveStop);
        final currentEta = etas['eta'] as int?;
        final upcomingEta = List<int>.from(etas['upcomingEta'] as List);

        // Update notifiers, ensuring only first 2 upcoming ETAs are shown
        etaNotifier.value = formatEta(currentEta);
        upcomingEtaNotifier.value = upcomingEta.take(2).map((e) => formatEta(e)).toList();

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

      onUpdate!(updatedRouteData);
    }
  }

  // Handles app lifecycle events to refresh ETAs on resume.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh ETAs when the app resumes
      refreshEtas();
      // Restart the timer to align with the next minute boundary
      startRefreshTimer();
    }
  }

  // Cancels the refresh timer and removes observer.
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}