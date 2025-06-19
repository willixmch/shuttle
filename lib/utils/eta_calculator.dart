import 'package:intl/intl.dart';
import 'package:shuttle/utils/day_type_checker.dart';
import 'package:shuttle/models/schedule.dart';
import 'package:shuttle/models/stop.dart';

class EtaCalculator {
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

  // Method to update the language
  static void setLanguage(String languageCode) {
    if (_localizedStrings.containsKey(languageCode)) {
      _languageCode = languageCode;
    } else {
      _languageCode = 'en'; // Fallback to English
    }
  }

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
      // Round up to the nearest minute
      final difference = (departureDateTime.difference(currentTime).inSeconds / 60).ceil() + etaOffset;
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
        // Round up to the nearest minute for comparison
        final difference = (departureDateTime.difference(currentTime).inSeconds / 60).ceil();
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
    // Round up to the nearest minute
    return (nextDepartureDateTime.difference(currentTime).inSeconds / 60).ceil() + etaOffset;
  }

  // Helper function to format minutes into a string (e.g., "Now Departing", "6 minutes", or "2 hours 10 minutes").
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
}