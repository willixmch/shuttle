// lib/utils/eta_calculator.dart
import 'package:intl/intl.dart';
import 'package:shuttle/utils/day_type_checker.dart';
import '../models/schedule.dart';
import '../models/stop.dart';

class EtaCalculator {
  // Determines the day type (workday or weekend) based on the given date.
  static String getDayType(DateTime date) {
    return DayTypeChecker.getDayType(date);
  }

  // Calculates the next ETA and upcoming ETAs for a route based on the current time and stop offset.
  // Returns a map with 'eta' (int, minutes) and 'upcomingEta' (List<int>, minutes).
  static Map<String, dynamic> calculateEtas(
    List<Schedule> schedules,
    DateTime currentTime,
    Stop? stop,
  ) {
    if (schedules.isEmpty) {
      return {'eta': null, 'upcomingEta': []};
    }

    // Use 0 as default etaOffset if stop is null
    final etaOffset = stop?.etaOffset ?? 0;

    // Parse schedule times and calculate time differences.
    final timeFormat = DateFormat('HH:mm');
    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);
    final timeDifferences = schedules.map((schedule) {
      final departureTime = timeFormat.parse(schedule.departureTime);
      final departureDateTime = today.add(Duration(
        hours: departureTime.hour,
        minutes: departureTime.minute,
      ));
      final difference = departureDateTime.difference(currentTime).inMinutes + etaOffset;
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
      return {'eta': null, 'upcomingEta': []};
    }

    // Get the next ETA and up to 2 upcoming ETAs as integers.
    final nextEtaMinutes = futureDepartures[0]['difference'] as int;
    final upcomingEta = futureDepartures
        .skip(1)
        .take(2)
        .map((d) => d['difference'] as int)
        .toList();

    return {'eta': nextEtaMinutes, 'upcomingEta': upcomingEta};
  }

  // Helper function to calculate the next ETA after a given list of ETAs.
  static int? calculateNextEta(
    List<Schedule> schedules,
    DateTime currentTime,
    int lastEtaMinutes,
    Stop? stop,
  ) {
    final timeFormat = DateFormat('HH:mm');
    final today = DateTime(currentTime.year, currentTime.month, currentTime.day);

    // Use 0 as default etaOffset if stop is null
    final etaOffset = stop?.etaOffset ?? 0;

    // Adjust last ETA to account for stop offset
    final adjustedLastEta = lastEtaMinutes - etaOffset;

    // Find the schedule time that corresponds to the last ETA.
    final lastDepartureTime = schedules.firstWhere(
      (schedule) {
        final departureTime = timeFormat.parse(schedule.departureTime);
        final departureDateTime = today.add(Duration(
          hours: departureTime.hour,
          minutes: departureTime.minute,
        ));
        final difference = departureDateTime.difference(currentTime).inMinutes;
        return difference == adjustedLastEta;
      },
      orElse: () => Schedule(id: 0, routeId: '', dayType: '', departureTime: ''),
    );

    if (lastDepartureTime.departureTime.isEmpty) {
      return null;
    }

    // Find the next schedule time after the last departure.
    final sortedSchedules = schedules
        .map((s) => s.departureTime)
        .toList()
      ..sort((a, b) => timeFormat.parse(a).compareTo(timeFormat.parse(b)));
    final lastIndex = sortedSchedules.indexOf(lastDepartureTime.departureTime);

    if (lastIndex == -1 || lastIndex == sortedSchedules.length - 1) {
      return null; // No more departures.
    }

    final nextDepartureTime = sortedSchedules[lastIndex + 1];
    final nextDepartureDateTime = today.add(Duration(
      hours: timeFormat.parse(nextDepartureTime).hour,
      minutes: timeFormat.parse(nextDepartureTime).minute,
    ));
    return nextDepartureDateTime.difference(currentTime).inMinutes + etaOffset;
  }

  // Helper function to format minutes into a string (e.g., "現時開出", "6 分鐘", or "2 小時 10 分鐘").
  static String formatEta(int? minutes) {
    if (minutes == null || minutes < 0) {
      return '沒有服務';
    }

    if (minutes == 0) {
      return '即將開出';
    }

    if (minutes < 60) {
      return '$minutes 分鐘';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours 小時';
    }
    return '$hours 小時 $remainingMinutes 分鐘';
  }
}