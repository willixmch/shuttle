import 'package:flutter/material.dart';
import 'package:shuttle/theme/theme.dart';
import 'package:shuttle/theme/util.dart';
import 'package:shuttle/pages/home.dart';
import 'package:shuttle/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttle/utils/eta_calculator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default to English
  final ValueNotifier<String> _languageNotifier = ValueNotifier('en'); // Notify language changes

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageCode') ?? await _getDeviceLanguage();
    setState(() {
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
    onLanguageChanged(); // Notify Home after all updates
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.light(), // Use light theme for simplicity
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Home(
        toggleLanguage: _toggleLanguage,
        languageNotifier: _languageNotifier,
      ),
    );
  }
}