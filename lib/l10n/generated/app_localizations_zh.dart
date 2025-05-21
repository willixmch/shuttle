// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get searchHint => '搜尋屋苑...';

  @override
  String get noResult => '沒有結果';

  @override
  String get upcomingEta => '稍後班次';

  @override
  String get minutes => '分鐘';

  @override
  String get routeDetails => '路線詳情';

  @override
  String get schedule => '時間表';
}
