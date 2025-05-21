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
  String get noResult => 'No estates found';

  @override
  String get upcomingEta => 'Upcoming ETA';

  @override
  String get minutes => 'Minutes';

  @override
  String get routeDetails => 'Details';

  @override
  String get schedule => 'Schedules';
}
