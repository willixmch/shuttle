import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DayTypeChecker {
  static List<DateTime>? _holidays;

  // Initialize holiday data by loading and parsing the JSON file
  static Future<void> initialize() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/assets/hk_public_holiday.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> events = jsonData['vcalendar'][0]['vevent'];

      // Extract holiday dates
      _holidays = events.map((event) {
        final String dateStr = event['dtstart'][0];
        return DateTime.parse(dateStr);
      }).toList();
    } catch (e) {
      print('Error loading holiday data: $e');
      _holidays = [];
    }
  }

  // Synchronous function to check the day type
  static String getDayType(DateTime date) {
    if (_holidays == null) {
      throw Exception('DayTypeChecker not initialized. Call initialize() first.');
    }

    // Format the input date to match holiday date format (YYYYMMDD)
    final String formattedDate = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final DateTime parsedDate = DateTime.parse(formattedDate);

    // Check if the date is a public holiday
    bool isHoliday = _holidays!.any((holiday) => parsedDate.isAtSameMomentAs(holiday));

    if (isHoliday) {
      return 'public_holiday';
    }

    // Check the day of the week
    switch (date.weekday) {
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return 'workday';
    }
  }
}