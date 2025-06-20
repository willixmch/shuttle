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
  String get hours => '小時';

  @override
  String get routeDetails => '路線詳情';

  @override
  String get schedule => '時間表';

  @override
  String get pickUpStop => '上客點';

  @override
  String get stops => '途經車站（車程）';

  @override
  String get residentFare => '住戶收費';

  @override
  String get visitorFare => '訪客收費';

  @override
  String get workday => '星期一至五（公眾假期除外）';

  @override
  String get saturday => '星期六';

  @override
  String get sunday => '星期日';

  @override
  String get publicHoliday => '公眾假期';

  @override
  String get estateSwitch => '選擇屋苑';

  @override
  String get languageSwitch => 'En';

  @override
  String get origin => '起始站';

  @override
  String get circular => '循環線';

  @override
  String get noService => '沒有服務';

  @override
  String get selectEstate => '選擇屋苑';

  @override
  String get locationPermissionText => '開啟位置權限以便尋找最接近你的車站';

  @override
  String get showClosestStop => '顯示最近車站';

  @override
  String get notNow => '暫時不要';
}
