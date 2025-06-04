// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchHint => 'Search Estate...';

  @override
  String get noResult => 'No Results';

  @override
  String get upcomingEta => 'Upcoming ETA';

  @override
  String get minutes => 'Mins';

  @override
  String get hours => 'Hrs';

  @override
  String get routeDetails => 'Details';

  @override
  String get schedule => 'Schedules';

  @override
  String get pickUpStop => 'Pick Up Stop';

  @override
  String get stops => 'Stops(Drive Time)';

  @override
  String get residentFare => 'Resident Fare';

  @override
  String get visitorFare => 'Vistor Fare';

  @override
  String get workday => 'Mondays - Fridays(except Public Holidays)';

  @override
  String get saturday => 'Saturdays';

  @override
  String get sunday => 'Sundays';

  @override
  String get publicHoliday => 'Public Holidays';

  @override
  String get estateSwitch => 'Switch Estate';

  @override
  String get languageSwitch => '繁中';

  @override
  String get origin => 'Origin Stop';

  @override
  String get circular => 'Circular Route';

  @override
  String get noService => 'No Service';
}
