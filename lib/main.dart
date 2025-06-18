import 'package:flutter/material.dart';
import 'package:shuttle/theme/theme.dart';
import 'package:shuttle/theme/util.dart';
import 'package:shuttle/pages/home.dart';
import 'package:shuttle/pages/onboarding_estate_selection.dart';
import 'package:shuttle/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttle/utils/eta_calculator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  final ValueNotifier<String> _languageNotifier = ValueNotifier('en');
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    String languageCode = prefs.getString('languageCode') ?? await _getDeviceLanguage();
    setState(() {
      _isFirstLaunch = isFirstLaunch;
      _locale = Locale(languageCode);
      _languageNotifier.value = languageCode;
    });
    EtaCalculator.setLanguage(languageCode);
  }

  Future<String> _getDeviceLanguage() async {
    final deviceLocale = WidgetsBinding.instance.window.locale;
    return AppLocalizations.supportedLocales.any(
            (locale) => locale.languageCode == deviceLocale.languageCode)
        ? deviceLocale.languageCode
        : 'en';
  }

  Future<void> _toggleLanguage(VoidCallback onLanguageChanged) async {
    final prefs = await SharedPreferences.getInstance();
    final newLanguageCode = _languageNotifier.value == 'en' ? 'zh' : 'en';
    await prefs.setString('languageCode', newLanguageCode);
    setState(() {
      _locale = Locale(newLanguageCode);
      _languageNotifier.value = newLanguageCode;
    });
    EtaCalculator.setLanguage(newLanguageCode);
    onLanguageChanged();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _isFirstLaunch
          ? OnboardingEstateSelection(
              toggleLanguage: _toggleLanguage,
              languageNotifier: _languageNotifier,
            )
          : Home(
              toggleLanguage: _toggleLanguage,
              languageNotifier: _languageNotifier,
            ),
    );
  }
}