import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF00677F),
      surfaceTint: Color(0xFF00677F),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF35AFD1),
      onPrimaryContainer: Color(0xFF001921),
      secondary: Color(0xFF3E6471),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFC3EAFA),
      onSecondaryContainer: Color(0xFF284E5B),
      tertiary: Color(0xFF4D616A),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF8CA1AA),
      onTertiaryContainer: Color(0xFF001219),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      background: Color(0xFFF6FAFD),
      onBackground: Color(0xFF171C1E),
      surface: Color(0xFFF6FAFD),
      onSurface: Color(0xFF171C1E),
      surfaceVariant: Color(0xFFD9E4EA),
      onSurfaceVariant: Color(0xFF3E484D),
      outline: Color(0xFF6E797E),
      outlineVariant: Color(0xFFBDC8CE),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2C3133),
      onInverseSurface: Color(0xFFEDF1F4),
      inversePrimary: Color(0xFF65D4F8),
      primaryFixed: Color(0xFFB6EBFF),
      onPrimaryFixed: Color(0xFF001F28),
      primaryFixedDim: Color(0xFF65D4F8),
      onPrimaryFixedVariant: Color(0xFF004E60),
      secondaryFixed: Color(0xFFC2E9F8),
      onSecondaryFixed: Color(0xFF001F28),
      secondaryFixedDim: Color(0xFFA6CCDC),
      onSecondaryFixedVariant: Color(0xFF264C58),
      tertiaryFixed: Color(0xFFD0E6F0),
      onTertiaryFixed: Color(0xFF091E25),
      tertiaryFixedDim: Color(0xFFB4CAD4),
      onTertiaryFixedVariant: Color(0xFF364A52),
      surfaceDim: Color(0xFFD6DBDD),
      surfaceBright: Color(0xFFF6FAFD),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF0F4F7),
      surfaceContainer: Color(0xFFEAEEF1),
      surfaceContainerHigh: Color(0xFFE4E9EB),
      surfaceContainerHighest: Color(0xFFDFE3E6),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF00495B),
      surfaceTint: Color(0xFF00677F),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF007F9C),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFF214854),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF557A88),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFF32464E),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF637880),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFF8C0009),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFDA342E),
      onErrorContainer: Color(0xFFFFFFFF),
      background: Color(0xFFF6FAFD),
      onBackground: Color(0xFF171C1E),
      surface: Color(0xFFF6FAFD),
      onSurface: Color(0xFF171C1E),
      surfaceVariant: Color(0xFFD9E4EA),
      onSurfaceVariant: Color(0xFF3A4449),
      outline: Color(0xFF566166),
      outlineVariant: Color(0xFF717C81),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2C3133),
      onInverseSurface: Color(0xFFEDF1F4),
      inversePrimary: Color(0xFF65D4F8),
      primaryFixed: Color(0xFF007F9C),
      onPrimaryFixed: Color(0xFFFFFFFF),
      primaryFixedDim: Color(0xFF00657C),
      onPrimaryFixedVariant: Color(0xFFFFFFFF),
      secondaryFixed: Color(0xFF557A88),
      onSecondaryFixed: Color(0xFFFFFFFF),
      secondaryFixedDim: Color(0xFF3C616E),
      onSecondaryFixedVariant: Color(0xFFFFFFFF),
      tertiaryFixed: Color(0xFF637880),
      onTertiaryFixed: Color(0xFFFFFFFF),
      tertiaryFixedDim: Color(0xFF4B5F67),
      onTertiaryFixedVariant: Color(0xFFFFFFFF),
      surfaceDim: Color(0xFFD6DBDD),
      surfaceBright: Color(0xFFF6FAFD),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF0F4F7),
      surfaceContainer: Color(0xFFEAEEF1),
      surfaceContainerHigh: Color(0xFFE4E9EB),
      surfaceContainerHighest: Color(0xFFDFE3E6),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF002631),
      surfaceTint: Color(0xFF00677F),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF00495B),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFF002631),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFF214854),
      onSecondaryContainer: Color(0xFFFFFFFF),
      tertiary: Color(0xFF10252C),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF32464E),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFF4E0002),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFF8C0009),
      onErrorContainer: Color(0xFFFFFFFF),
      background: Color(0xFFF6FAFD),
      onBackground: Color(0xFF171C1E),
      surface: Color(0xFFF6FAFD),
      onSurface: Color(0xFF000000),
      surfaceVariant: Color(0xFFD9E4EA),
      onSurfaceVariant: Color(0xFF1B252A),
      outline: Color(0xFF3A4449),
      outlineVariant: Color(0xFF3A4449),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF2C3133),
      onInverseSurface: Color(0xFFFFFFFF),
      inversePrimary: Color(0xFFD0F1FF),
      primaryFixed: Color(0xFF00495B),
      onPrimaryFixed: Color(0xFFFFFFFF),
      primaryFixedDim: Color(0xFF00313E),
      onPrimaryFixedVariant: Color(0xFFFFFFFF),
      secondaryFixed: Color(0xFF214854),
      onSecondaryFixed: Color(0xFFFFFFFF),
      secondaryFixedDim: Color(0xFF04313D),
      onSecondaryFixedVariant: Color(0xFFFFFFFF),
      tertiaryFixed: Color(0xFF32464E),
      onTertiaryFixed: Color(0xFFFFFFFF),
      tertiaryFixedDim: Color(0xFF1B2F37),
      onTertiaryFixedVariant: Color(0xFFFFFFFF),
      surfaceDim: Color(0xFFD6DBDD),
      surfaceBright: Color(0xFFF6FAFD),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF0F4F7),
      surfaceContainer: Color(0xFFEAEEF1),
      surfaceContainerHigh: Color(0xFFE4E9EB),
      surfaceContainerHighest: Color(0xFFDFE3E6),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF65D4F8),
      surfaceTint: Color(0xFF65D4F8),
      onPrimary: Color(0xFF003543),
      primaryContainer: Color(0xFF007F9C),
      onPrimaryContainer: Color(0xFFFFFFFF),
      secondary: Color(0xFFA6CCDC),
      onSecondary: Color(0xFF0A3541),
      secondaryContainer: Color(0xFF1D4450),
      onSecondaryContainer: Color(0xFFB3DAE9),
      tertiary: Color(0xFFB4CAD4),
      onTertiary: Color(0xFF1F333B),
      tertiaryContainer: Color(0xFF637880),
      onTertiaryContainer: Color(0xFFFFFFFF),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      background: Color(0xFF0F1416),
      onBackground: Color(0xFFDFE3E6),
      surface: Color(0xFF0F1416),
      onSurface: Color(0xFFDFE3E6),
      surfaceVariant: Color(0xFF3E484D),
      onSurfaceVariant: Color(0xFFBDC8CE),
      outline: Color(0xFF879298),
      outlineVariant: Color(0xFF3E484D),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFDFE3E6),
      onInverseSurface: Color(0xFF2C3133),
      inversePrimary: Color(0xFF00677F),
      primaryFixed: Color(0xFFB6EBFF),
      onPrimaryFixed: Color(0xFF001F28),
      primaryFixedDim: Color(0xFF65D4F8),
      onPrimaryFixedVariant: Color(0xFF004E60),
      secondaryFixed: Color(0xFFC2E9F8),
      onSecondaryFixed: Color(0xFF001F28),
      secondaryFixedDim: Color(0xFFA6CCDC),
      onSecondaryFixedVariant: Color(0xFF264C58),
      tertiaryFixed: Color(0xFFD0E6F0),
      onTertiaryFixed: Color(0xFF091E25),
      tertiaryFixedDim: Color(0xFFB4CAD4),
      onTertiaryFixedVariant: Color(0xFF364A52),
      surfaceDim: Color(0xFF0F1416),
      surfaceBright: Color(0xFF353A3C),
      surfaceContainerLowest: Color(0xFF0A0F11),
      surfaceContainerLow: Color(0xFF171C1E),
      surfaceContainer: Color(0xFF1B2023),
      surfaceContainerHigh: Color(0xFF262B2D),
      surfaceContainerHighest: Color(0xFF303638),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFD3C1FF),
      surfaceTint: Color(0xFFCFBDFE),
      onPrimary: Color(0xFF1B0942),
      primaryContainer: Color(0xFF9887C5),
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFFD3C1FF),
      onSecondary: Color(0xFF1B0942),
      secondaryContainer: Color(0xFF9887C5),
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFFFFB7CD),
      onTertiary: Color(0xFF330218),
      tertiaryContainer: Color(0xFFC57B93),
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFFFB9B3),
      onError: Color(0xFF330405),
      errorContainer: Color(0xFFCC7B74),
      onErrorContainer: Color(0xFF000000),
      background: Color(0xFF141218),
      onBackground: Color(0xFFE6E0E9),
      surface: Color(0xFF141218),
      onSurface: Color(0xFFFFF9FF),
      surfaceVariant: Color(0xFF49454E),
      onSurfaceVariant: Color(0xFFCEC8D4),
      outline: Color(0xFFA6A1AB),
      outlineVariant: Color(0xFF86818B),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE6E0E9),
      onInverseSurface: Color(0xFF2B292F),
      inversePrimary: Color(0xFF4E3F77),
      primaryFixed: Color(0xFFE9DDFF),
      onPrimaryFixed: Color(0xFF16033D),
      primaryFixedDim: Color(0xFFCFBDFE),
      onPrimaryFixedVariant: Color(0xFF3C2D63),
      secondaryFixed: Color(0xFFE9DDFF),
      onSecondaryFixed: Color(0xFF16033D),
      secondaryFixedDim: Color(0xFFCFBDFE),
      onSecondaryFixedVariant: Color(0xFF3C2D63),
      tertiaryFixed: Color(0xFFFFD9E3),
      onTertiaryFixed: Color(0xFF2B0013),
      tertiaryFixedDim: Color(0xFFFFB0C9),
      onTertiaryFixedVariant: Color(0xFF5B2238),
      surfaceDim: Color(0xFF141218),
      surfaceBright: Color(0xFF3B383E),
      surfaceContainerLowest: Color(0xFF0F0D13),
      surfaceContainerLow: Color(0xFF1D1B20),
      surfaceContainer: Color(0xFF211F24),
      surfaceContainerHigh: Color(0xFF2B292F),
      surfaceContainerHighest: Color(0xFF36343A),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFFFF9FF),
      surfaceTint: Color(0xFFCFBDFE),
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFFD3C1FF),
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFFFFF9FF),
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFFD3C1FF),
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFFFFF9F9),
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFFFFB7CD),
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFFFF9F9),
      onError: Color(0xFF000000),
      errorContainer: Color(0xFFFFB9B3),
      onErrorContainer: Color(0xFF000000),
      background: Color(0xFF141218),
      onBackground: Color(0xFFE6E0E9),
      surface: Color(0xFF141218),
      onSurface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFF49454E),
      onSurfaceVariant: Color(0xFFFFF9FF),
      outline: Color(0xFFCEC8D4),
      outlineVariant: Color(0xFFCEC8D4),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE6E0E9),
      onInverseSurface: Color(0xFF000000),
      inversePrimary: Color(0xFF2F2056),
      primaryFixed: Color(0xFFEDE2FF),
      onPrimaryFixed: Color(0xFF000000),
      primaryFixedDim: Color(0xFFD3C1FF),
      onPrimaryFixedVariant: Color(0xFF1B0942),
      secondaryFixed: Color(0xFFEDE2FF),
      onSecondaryFixed: Color(0xFF000000),
      secondaryFixedDim: Color(0xFFD3C1FF),
      onSecondaryFixedVariant: Color(0xFF1B0942),
      tertiaryFixed: Color(0xFFFFDFE7),
      onTertiaryFixed: Color(0xFF000000),
      tertiaryFixedDim: Color(0xFFFFB7CD),
      onTertiaryFixedVariant: Color(0xFF330218),
      surfaceDim: Color(0xFF141218),
      surfaceBright: Color(0xFF3B383E),
      surfaceContainerLowest: Color(0xFF0F0D13),
      surfaceContainerLow: Color(0xFF1D1B20),
      surfaceContainer: Color(0xFF211F24),
      surfaceContainerHigh: Color(0xFF2B292F),
      surfaceContainerHighest: Color(0xFF36343A),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.background,
     canvasColor: colorScheme.surface,
  );

  /// Success
  static const success = ExtendedColor(
    seed: Color(4278237751),
    value: Color(4278237751),
    light: ColorFamily(
      color: Color(0xFF006E1D),
      onColor: Color(0xFFFFFFFF),
      colorContainer: Color(0xFF23C742),
      onColorContainer: Color(0xFF002805),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xFFFFFFFF),
      onColor: Color(0xFFFFFFFF),
      colorContainer: Color(0xFFFFFFFF),
      onColorContainer: Color(0xFFFFFFFF),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xFF006E1D),
      onColor: Color(0xFFFFFFFF),
      colorContainer: Color(0xFF23C742),
      onColorContainer: Color(0xFF002805),
    ),
    dark: ColorFamily(
      color: Color(0xFF49E25A),
      onColor: Color(0xFF00390A),
      colorContainer: Color(0xFF00B034),
      onColorContainer: Color(0xFF000701),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xFFFFFFFF),
      onColor: Color(0xFFFFFFFF),
      colorContainer: Color(0xFFFFFFFF),
      onColorContainer: Color(0xFFFFFFFF),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xFFFFFFFF),
      onColor: Color(0xFFFFFFFF),
      colorContainer: Color(0xFFFFFFFF),
      onColorContainer: Color(0xFFFFFFFF),
    ),
  );

  List<ExtendedColor> get extendedColors => [
    success,
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}