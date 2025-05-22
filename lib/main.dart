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
  Locale? _locale; // Initialize to null to use device locale initially
  final ValueNotifier<String> _languageNotifier = ValueNotifier('en'); // Notify language changes

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      setState(() {
        _locale = Locale(languageCode);
      });
      _languageNotifier.value = languageCode;
      EtaCalculator.setLanguage(languageCode);
    } else {
      // Use device locale on first launch
      final deviceLocale = WidgetsBinding.instance.window.locale;
      final resolvedLanguageCode = AppLocalizations.supportedLocales.any(
              (locale) => locale.languageCode == deviceLocale.languageCode)
          ? deviceLocale.languageCode
          : 'en';
      _languageNotifier.value = resolvedLanguageCode;
      EtaCalculator.setLanguage(resolvedLanguageCode);
    }
  }

  Future<void> _toggleLanguage(VoidCallback onLanguageChanged) async {
    final prefs = await SharedPreferences.getInstance();
    final newLanguageCode = _locale?.languageCode == 'en' ? 'zh' : 'en';
    await prefs.setString('languageCode', newLanguageCode);
    setState(() {
      _locale = Locale(newLanguageCode);
    });
    EtaCalculator.setLanguage(newLanguageCode);
    _languageNotifier.value = newLanguageCode;
    onLanguageChanged(); // Notify Home after all updates
  }

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      locale: _locale, // Null initially to use device locale
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale != null) {
          return _locale; // Use stored locale if set
        }
        if (locale == null) {
          return const Locale('en'); // Fallback to English if no device locale
        }
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en'); // Fallback to English if device locale not supported
      },
      home: Home(
        toggleLanguage: _toggleLanguage,
        languageNotifier: _languageNotifier,
      ),
    );
  }
}