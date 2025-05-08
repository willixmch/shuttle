import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// Enum to represent day types
enum DayType { workday, saturday, sunday, publicHoliday }

// Function to check the day type
Future<DayType> checkDayType(DateTime date) async {
  // Load and parse JSON data (assuming it's stored in assets or provideda file)
  // For this example, we'll use the provided JSON data directly
  final String jsonString = '''
  {
    "vcalendar": [{
      "vevent": [
        {
          "dtstart": ["20230102", {"value": "DATE"}],
          "dtend": ["20230103", {"value": "DATE"}],
          "summary": "The day following the first day of January"
        },
        {
          "dtstart": ["20230123", {"value": "DATE"}],
          "dtend": ["20230124", {"value": "DATE"}],
          "summary": "The second day of Lunar New Year"
        },
        {
          "dtstart": ["20230124", {"value": "DATE"}],
          "dtend": ["20230125", {"value": "DATE"}],
          "summary": "The third day of Lunar New Year"
        },
        {
          "dtstart": ["20230125", {"value": "DATE"}],
          "dtend": ["20230126", {"value": "DATE"}],
          "summary": "The fourth day of Lunar New Year"
        },
        {
          "dtstart": ["20230405", {"value": "DATE"}],
          "dtend": ["20230406", {"value": "DATE"}],
          "summary": "Ching Ming Festival"
        },
        {
          "dtstart": ["20230407", {"value": "DATE"}],
          "dtend": ["20230408", {"value": "DATE"}],
          "summary": "Good Friday"
        },
        {
          "dtstart": ["20230408", {"value": "DATE"}],
          "dtend": ["20230409", {"value": "DATE"}],
          "summary": "The day following Good Friday"
        },
        {
          "dtstart": ["20230410", {"value": "DATE"}],
          "dtend": ["20230411", {"value": "DATE"}],
          "summary": "Easter Monday"
        },
        {
          "dtstart": ["20230501", {"value": "DATE"}],
          "dtend": ["20230502", {"value": "DATE"}],
          "summary": "Labour Day"
        },
        {
          "dtstart": ["20230526", {"value": "DATE"}],
          "dtend": ["20230527", {"value": "DATE"}],
          "summary": "The Birthday of the Buddha"
        },
        {
          "dtstart": ["20230622", {"value": "DATE"}],
          "dtend": ["20230623", {"value": "DATE"}],
          "summary": "Tuen Ng Festival"
        },
        {
          "dtstart": ["20230701", {"value": "DATE"}],
          "dtend": ["20230702", {"value": "DATE"}],
          "summary": "Hong Kong Special Administrative Region Establishment Day"
        },
        {
          "dtstart": ["20230930", {"value": "DATE"}],
          "dtend": ["20231001", {"value": "DATE"}],
          "summary": "The day following the Chinese Mid-Autumn Festival"
        },
        {
          "dtstart": ["20231002", {"value": "DATE"}],
          "dtend": ["20231003", {"value": "DATE"}],
          "summary": "The day following National Day"
        },
        {
          "dtstart": ["20231023", {"value": "DATE"}],
          "dtend": ["20231024", {"value": "DATE"}],
          "summary": "Chung Yeung Festival"
        },
        {
          "dtstart": ["20231225", {"value": "DATE"}],
          "dtend": ["20231226", {"value": "DATE"}],
          "summary": "Christmas Day"
        },
        {
          "dtstart": ["20231226", {"value": "DATE"}],
          "dtend": ["20231227", {"value": "DATE"}],
          "summary": "The first weekday after Christmas Day"
        },
        {
          "dtstart": ["20240101", {"value": "DATE"}],
          "dtend": ["20240102", {"value": "DATE"}],
          "summary": "The first day of January"
        },
        {
          "dtstart": ["20240210", {"value": "DATE"}],
          "dtend": ["20240211", {"value": "DATE"}],
          "summary": "Lunar New Year’s Day"
        },
        {
          "dtstart": ["20240212", {"value": "DATE"}],
          "dtend": ["20240213", {"value": "DATE"}],
          "summary": "The third day of Lunar New Year"
        },
        {
          "dtstart": ["20240213", {"value": "DATE"}],
          "dtend": ["20240214", {"value": "DATE"}],
          "summary": "The fourth day of Lunar New Year"
        },
        {
          "dtstart": ["20240329", {"value": "DATE"}],
          "dtend": ["20240330", {"value": "DATE"}],
          "summary": "Good Friday"
        },
        {
          "dtstart": ["20240330", {"value": "DATE"}],
          "dtend": ["20240331", {"value": "DATE"}],
          "summary": "The day following Good Friday"
        },
        {
          "dtstart": ["20240401", {"value": "DATE"}],
          "dtend": ["20240402", {"value": "DATE"}],
          "summary": "Easter Monday"
        },
        {
          "dtstart": ["20240404", {"value": "DATE"}],
          "dtend": ["20240405", {"value": "DATE"}],
          "summary": "Ching Ming Festival"
        },
        {
          "dtstart": ["20240501", {"value": "DATE"}],
          "dtend": ["20240502", {"value": "DATE"}],
          "summary": "Labour Day"
        },
        {
          "dtstart": ["20240515", {"value": "DATE"}],
          "dtend": ["20240516", {"value": "DATE"}],
          "summary": "The Birthday of the Buddha"
        },
        {
          "dtstart": ["20240610", {"value": "DATE"}],
          "dtend": ["20240611", {"value": "DATE"}],
          "summary": "Tuen Ng Festival"
        },
        {
          "dtstart": ["20240701", {"value": "DATE"}],
          "dtend": ["20240702", {"value": "DATE"}],
          "summary": "Hong Kong Special Administrative Region Establishment Day"
        },
        {
          "dtstart": ["20240918", {"value": "DATE"}],
          "dtend": ["20240919", {"value": "DATE"}],
          "summary": "The day following the Chinese Mid-Autumn Festival"
        },
        {
          "dtstart": ["20241001", {"value": "DATE"}],
          "dtend": ["20241002", {"value": "DATE"}],
          "summary": "National Day"
        },
        {
          "dtstart": ["20241011", {"value": "DATE"}],
          "dtend": ["20241012", {"value": "DATE"}],
          "summary": "Chung Yeung Festival"
        },
        {
          "dtstart": ["20241225", {"value": "DATE"}],
          "dtend": ["20241226", {"value": "DATE"}],
          "summary": "Christmas Day"
        },
        {
          "dtstart": ["20241226", {"value": "DATE"}],
          "dtend": ["20241227", {"value": "DATE"}],
          "summary": "The first weekday after Christmas Day"
        },
        {
          "dtstart": ["20250101", {"value": "DATE"}],
          "dtend": ["20250102", {"value": "DATE"}],
          "summary": "The first day of January"
        },
        {
          "dtstart": ["20250129", {"value": "DATE"}],
          "dtend": ["20250130", {"value": "DATE"}],
          "summary": "Lunar New Year’s Day"
        },
        {
          "dtstart": ["20250130", {"value": "DATE"}],
          "dtend": ["20250131", {"value": "DATE"}],
          "summary": "The second day of Lunar New Year"
        },
        {
          "dtstart": ["20250131", {"value": "DATE"}],
          "dtend": ["20250201", {"value": "DATE"}],
          "summary": "The third day of Lunar New Year"
        },
        {
          "dtstart": ["20250404", {"value": "DATE"}],
          "dtend": ["20250405", {"value": "DATE"}],
          "summary": "Ching Ming Festival"
        },
        {
          "dtstart": ["20250418", {"value": "DATE"}],
          "dtend": ["20250419", {"value": "DATE"}],
          "summary": "Good Friday"
        },
        {
          "dtstart": ["20250419", {"value": "DATE"}],
          "dtend": ["20250420", {"value": "DATE"}],
          "summary": "The day following Good Friday"
        },
        {
          "dtstart": ["20250421", {"value": "DATE"}],
          "dtend": ["20250422", {"value": "DATE"}],
          "summary": "Easter Monday"
        },
        {
          "dtstart": ["20250501", {"value": "DATE"}],
          "dtend": ["20250502", {"value": "DATE"}],
          "summary": "Labour Day"
        },
        {
          "dtstart": ["20250505", {"value": "DATE"}],
          "dtend": ["20250506", {"value": "DATE"}],
          "summary": "The Birthday of the Buddha"
        },
        {
          "dtstart": ["20250531", {"value": "DATE"}],
          "dtend": ["20250601", {"value": "DATE"}],
          "summary": "Tuen Ng Festival"
        },
        {
          "dtstart": ["20250701", {"value": "DATE"}],
          "dtend": ["20250702", {"value": "DATE"}],
          "summary": "Hong Kong Special Administrative Region Establishment Day"
        },
        {
          "dtstart": ["20251001", {"value": "DATE"}],
          "dtend": ["20251002", {"value": "DATE"}],
          "summary": "National Day"
        },
        {
          "dtstart": ["20251007", {"value": "DATE"}],
          "dtend": ["20251008", {"value": "DATE"}],
          "summary": "The day following the Chinese Mid-Autumn Festival"
        },
        {
          "dtstart": ["20251029", {"value": "DATE"}],
          "dtend": ["20251030", {"value": "DATE"}],
          "summary": "Chung Yeung Festival"
        },
        {
          "dtstart": ["20251225", {"value": "DATE"}],
          "dtend": ["20251226", {"value": "DATE"}],
          "summary": "Christmas Day"
        },
        {
          "dtstart": ["20251226", {"value": "DATE"}],
          "dtend": ["20251227", {"value": "DATE"}],
          "summary": "The first weekday after Christmas Day"
        }
      ]
    }]
  }
  ''';

  final Map<String, dynamic> jsonData = jsonDecode(jsonString);
  final List<dynamic> events = jsonData['vcalendar'][0]['vevent'];

  // Extract holiday dates
  final List<DateTime> holidays = events.map((event) {
    final String dateStr = event['dtstart'][0];
    return DateTime.parse(dateStr);
  }).toList();

  // Format the input date to match holiday date format (YYYYMMDD)
  final String formattedDate = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  final DateTime parsedDate = DateTime.parse(formattedDate);

  // Check if the date is a public holiday
  bool isHoliday = holidays.any((overthrow) {
    return parsedDate.isAtSameMomentAs(overthrow) ||
        parsedDate.isBefore(overthrow) ||
        parsedDate.isAfter(overthrow);
  });

  if (isHoliday) {
    return DayType.publicHoliday;
  }

  // Check the day of the week
  switch (date.weekday) {
    case DateTime.saturday:
      return DayType.saturday;
    case DateTime.sunday:
      return DayType.sunday;
    default:
      return DayType.workday;
  }
}