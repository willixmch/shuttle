// lib/utils/eta_calculator.dart
// Provides utilities to calculate ETAs for shuttle routes based on schedules.
// Calculates the next ETA and upcoming ETAs in minutes, formatted as strings (e.g., "6 分鐘").

import 'package:intl/intl.dart';
import '../models/schedule.dart';

class EtaCalculator {
  // Determines the day type (workday or weekend) based on the given date.
  static String getDayType(DateTime date) {
    return date.weekday >= 1 && date.weekday <= 5 ? 'workday' : 'weekend';
  }

  // Calculates the next ETA and upcoming ETAs for a route based on the current time.
  // Returns a map with 'eta' (String, e.g., "6 分鐘") and 'upcomingEta' (List<String>).
  static Map<String, dynamic> calculateEtas(
    List<Schedule> schedules,
    DateTime currentTime,
  ) {
    if (schedules.isEmpty) {
      return {'eta': 'No departures today', 'upcomingEta': []};
    }

    // Parse schedule times and calculate time differences.
    final timeFormat = DateFormat('HH:mm');
    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final timeDifferences = schedules.map((schedule) {
      final departureTime = timeFormat.parse(schedule.departureTime);
      final departureDateTime = today.add(Duration(
        hours: departureTime.hour,
        minutes: departureTime.minute,
      ));
      final difference = departureDateTime.difference(currentTime).inMinutes;
      return {'time': schedule.departureTime, 'difference': difference};
    }).toList();

    // Filter future departures (difference > 0) and sort by time.
    final futureDepartures = timeDifferences
        .where((d) {
          final difference = d['difference'];
          return difference != null && (difference as int) > 0;
        })
        .toList()
      ..sort((a, b) {
        final aDiff = a['difference'] as int;
        final bDiff = b['difference'] as int;
        return aDiff.compareTo(bDiff);
      });

    if (futureDepartures.isEmpty) {
      return {'eta': 'No more departures today', 'upcomingEta': []};
    }

    // Get the next ETA and up to 2 upcoming ETAs.
    final nextEtaMinutes = futureDepartures[0]['difference'] as int;
    final eta = '$nextEtaMinutes 分鐘';
    final upcomingEta = futureDepartures
        .skip(1)
        .take(2)
        .map((d) => '${d['difference']} 分鐘')
        .toList();

    return {'eta': eta, 'upcomingEta': upcomingEta};
  }
}