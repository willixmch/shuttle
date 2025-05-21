import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shuttle/theme/theme.dart';
import 'package:shuttle/theme/util.dart';
import 'package:shuttle/pages/home.dart';
import 'package:shuttle/l10n/generated/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    TextTheme textTheme = createTextTheme(context, "Poppins", "Poppins");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      // Localization settings
      localizationsDelegates: const [
        AppLocalizations.delegate, // Generated delegate for translations
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('zh'), // Traditional Chinese
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Fallback to English if the device locale is not supported
        for (var supportedLocale in supportedLocales) {
          if (locale?.languageCode == supportedLocale.languageCode &&
              locale?.scriptCode == supportedLocale.scriptCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first; // Default to English
      },

      locale: const Locale('zh'),

      home: const Home(),
    );
  }
}