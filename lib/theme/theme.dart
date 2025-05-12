import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static MaterialScheme lightScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278216575),
      surfaceTint: Color(4278216575),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4281708497),
      onPrimaryContainer: Color(4278196513),
      secondary: Color(4282279025),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4291029754),
      onSecondaryContainer: Color(4280831579),
      tertiary: Color(4283261290),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4287406506),
      onTertiaryContainer: Color(4278194713),
      error: Color(4290386458),
      onError: Color(4294967295),
      errorContainer: Color(4294957782),
      onErrorContainer: Color(4282449922),
      background: Color(4294376189),
      onBackground: Color(4279704606),
      surface: Color(4294376189),
      onSurface: Color(4279704606),
      surfaceVariant: Color(4292469994),
      onSurfaceVariant: Color(4282271821),
      outline: Color(4285430142),
      outlineVariant: Color(4290627790),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086259),
      inverseOnSurface: Color(4293784052),
      inversePrimary: Color(4284863736),
      primaryFixed: Color(4290178047),
      onPrimaryFixed: Color(4278198056),
      primaryFixedDim: Color(4284863736),
      onPrimaryFixedVariant: Color(4278210144),
      secondaryFixed: Color(4290963960),
      onSecondaryFixed: Color(4278198056),
      secondaryFixedDim: Color(4289121500),
      onSecondaryFixedVariant: Color(4280699992),
      tertiaryFixed: Color(4291880688),
      onTertiaryFixed: Color(4278787621),
      tertiaryFixedDim: Color(4290038484),
      onTertiaryFixedVariant: Color(4281748050),
      surfaceDim: Color(4292271069),
      surfaceBright: Color(4294376189),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293981431),
      surfaceContainer: Color(4293586673),
      surfaceContainerHigh: Color(4293192171),
      surfaceContainerHighest: Color(4292862950),
    );
  }

  ThemeData light() {
    return theme(lightScheme().toColorScheme());
  }

  static MaterialScheme lightMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278208859),
      surfaceTint: Color(4278216575),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4278222748),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4280371284),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4283792008),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4281484878),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4284708992),
      onTertiaryContainer: Color(4294967295),
      error: Color(4287365129),
      onError: Color(4294967295),
      errorContainer: Color(4292490286),
      onErrorContainer: Color(4294967295),
      background: Color(4294376189),
      onBackground: Color(4279704606),
      surface: Color(4294376189),
      onSurface: Color(4279704606),
      surfaceVariant: Color(4292469994),
      onSurfaceVariant: Color(4282008649),
      outline: Color(4283851110),
      outlineVariant: Color(4285627521),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086259),
      inverseOnSurface: Color(4293784052),
      inversePrimary: Color(4284863736),
      primaryFixed: Color(4278222748),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278216060),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4283792008),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4282147182),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4284708992),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4283129703),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292271069),
      surfaceBright: Color(4294376189),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293981431),
      surfaceContainer: Color(4293586673),
      surfaceContainerHigh: Color(4293192171),
      surfaceContainerHighest: Color(4292862950),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme lightHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.light,
      primary: Color(4278199857),
      surfaceTint: Color(4278216575),
      onPrimary: Color(4294967295),
      primaryContainer: Color(4278208859),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4278199857),
      onSecondary: Color(4294967295),
      secondaryContainer: Color(4280371284),
      onSecondaryContainer: Color(4294967295),
      tertiary: Color(4279248172),
      onTertiary: Color(4294967295),
      tertiaryContainer: Color(4281484878),
      onTertiaryContainer: Color(4294967295),
      error: Color(4283301890),
      onError: Color(4294967295),
      errorContainer: Color(4287365129),
      onErrorContainer: Color(4294967295),
      background: Color(4294376189),
      onBackground: Color(4279704606),
      surface: Color(4294376189),
      onSurface: Color(4278190080),
      surfaceVariant: Color(4292469994),
      onSurfaceVariant: Color(4279969066),
      outline: Color(4282008649),
      outlineVariant: Color(4282008649),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4281086259),
      inverseOnSurface: Color(4294967295),
      inversePrimary: Color(4291883519),
      primaryFixed: Color(4278208859),
      onPrimaryFixed: Color(4294967295),
      primaryFixedDim: Color(4278202686),
      onPrimaryFixedVariant: Color(4294967295),
      secondaryFixed: Color(4280371284),
      onSecondaryFixed: Color(4294967295),
      secondaryFixedDim: Color(4278464829),
      onSecondaryFixedVariant: Color(4294967295),
      tertiaryFixed: Color(4281484878),
      onTertiaryFixed: Color(4294967295),
      tertiaryFixedDim: Color(4279971639),
      onTertiaryFixedVariant: Color(4294967295),
      surfaceDim: Color(4292271069),
      surfaceBright: Color(4294376189),
      surfaceContainerLowest: Color(4294967295),
      surfaceContainerLow: Color(4293981431),
      surfaceContainer: Color(4293586673),
      surfaceContainerHigh: Color(4293192171),
      surfaceContainerHighest: Color(4292862950),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme().toColorScheme());
  }

  static MaterialScheme darkScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4284863736),
      surfaceTint: Color(4284863736),
      onPrimary: Color(4278203715),
      primaryContainer: Color(4278222748),
      onPrimaryContainer: Color(4294967295),
      secondary: Color(4289121500),
      onSecondary: Color(4278859073),
      secondaryContainer: Color(4280108112),
      onSecondaryContainer: Color(4289977065),
      tertiary: Color(4290038484),
      onTertiary: Color(4280234811),
      tertiaryContainer: Color(4284708992),
      onTertiaryContainer: Color(4294967295),
      error: Color(4294948011),
      onError: Color(4285071365),
      errorContainer: Color(4287823882),
      onErrorContainer: Color(4294957782),
      background: Color(4279178262),
      onBackground: Color(4292862950),
      surface: Color(4279178262),
      onSurface: Color(4292862950),
      surfaceVariant: Color(4282271821),
      onSurfaceVariant: Color(4290627790),
      outline: Color(4287074968),
      outlineVariant: Color(4282271821),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292862950),
      inverseOnSurface: Color(4281086259),
      inversePrimary: Color(4278216575),
      primaryFixed: Color(4290178047),
      onPrimaryFixed: Color(4278198056),
      primaryFixedDim: Color(4284863736),
      onPrimaryFixedVariant: Color(4278210144),
      secondaryFixed: Color(4290963960),
      onSecondaryFixed: Color(4278198056),
      secondaryFixedDim: Color(4289121500),
      onSecondaryFixedVariant: Color(4280699992),
      tertiaryFixed: Color(4291880688),
      onTertiaryFixed: Color(4278787621),
      tertiaryFixedDim: Color(4290038484),
      onTertiaryFixedVariant: Color(4281748050),
      surfaceDim: Color(4279178262),
      surfaceBright: Color(4281678396),
      surfaceContainerLowest: Color(4278849297),
      surfaceContainerLow: Color(4279704606),
      surfaceContainer: Color(4279967779),
      surfaceContainerHigh: Color(4280691501),
      surfaceContainerHighest: Color(4281349688),
    );
  }

  ThemeData dark() {
    return theme(darkScheme().toColorScheme());
  }

  static MaterialScheme darkMediumContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4285192444),
      surfaceTint: Color(4284863736),
      onPrimary: Color(4278196513),
      primaryContainer: Color(4279475647),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4289384928),
      onSecondary: Color(4278196513),
      secondaryContainer: Color(4285634213),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4290367192),
      onTertiary: Color(4278458656),
      tertiaryContainer: Color(4286551197),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294949553),
      onError: Color(4281794561),
      errorContainer: Color(4294923337),
      onErrorContainer: Color(4278190080),
      background: Color(4279178262),
      onBackground: Color(4292862950),
      surface: Color(4279178262),
      onSurface: Color(4294441982),
      surfaceVariant: Color(4282271821),
      onSurfaceVariant: Color(4290891218),
      outline: Color(4288259498),
      outlineVariant: Color(4286219658),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292862950),
      inverseOnSurface: Color(4280691501),
      inversePrimary: Color(4278210402),
      primaryFixed: Color(4290178047),
      onPrimaryFixed: Color(4278195226),
      primaryFixedDim: Color(4284863736),
      onPrimaryFixedVariant: Color(4278205514),
      secondaryFixed: Color(4290963960),
      onSecondaryFixed: Color(4278195226),
      secondaryFixedDim: Color(4289121500),
      onSecondaryFixedVariant: Color(4279384903),
      tertiaryFixed: Color(4291880688),
      onTertiaryFixed: Color(4278195227),
      tertiaryFixedDim: Color(4290038484),
      onTertiaryFixedVariant: Color(4280629569),
      surfaceDim: Color(4279178262),
      surfaceBright: Color(4281678396),
      surfaceContainerLowest: Color(4278849297),
      surfaceContainerLow: Color(4279704606),
      surfaceContainer: Color(4279967779),
      surfaceContainerHigh: Color(4280691501),
      surfaceContainerHighest: Color(4281349688),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme().toColorScheme());
  }

  static MaterialScheme darkHighContrastScheme() {
    return const MaterialScheme(
      brightness: Brightness.dark,
      primary: Color(4294376703),
      surfaceTint: Color(4284863736),
      onPrimary: Color(4278190080),
      primaryContainer: Color(4285192444),
      onPrimaryContainer: Color(4278190080),
      secondary: Color(4294376703),
      onSecondary: Color(4278190080),
      secondaryContainer: Color(4289384928),
      onSecondaryContainer: Color(4278190080),
      tertiary: Color(4294376703),
      onTertiary: Color(4278190080),
      tertiaryContainer: Color(4290367192),
      onTertiaryContainer: Color(4278190080),
      error: Color(4294965753),
      onError: Color(4278190080),
      errorContainer: Color(4294949553),
      onErrorContainer: Color(4278190080),
      background: Color(4279178262),
      onBackground: Color(4292862950),
      surface: Color(4279178262),
      onSurface: Color(4294967295),
      surfaceVariant: Color(4282271821),
      onSurfaceVariant: Color(4294376703),
      outline: Color(4290891218),
      outlineVariant: Color(4290891218),
      shadow: Color(4278190080),
      scrim: Color(4278190080),
      inverseSurface: Color(4292862950),
      inverseOnSurface: Color(4278190080),
      inversePrimary: Color(4278202171),
      primaryFixed: Color(4290965247),
      onPrimaryFixed: Color(4278190080),
      primaryFixedDim: Color(4285192444),
      onPrimaryFixedVariant: Color(4278196513),
      secondaryFixed: Color(4291227133),
      onSecondaryFixed: Color(4278190080),
      secondaryFixedDim: Color(4289384928),
      onSecondaryFixedVariant: Color(4278196513),
      tertiaryFixed: Color(4292143860),
      onTertiaryFixed: Color(4278190080),
      tertiaryFixedDim: Color(4290367192),
      onTertiaryFixedVariant: Color(4278458656),
      surfaceDim: Color(4279178262),
      surfaceBright: Color(4281678396),
      surfaceContainerLowest: Color(4278849297),
      surfaceContainerLow: Color(4279704606),
      surfaceContainer: Color(4279967779),
      surfaceContainerHigh: Color(4280691501),
      surfaceContainerHighest: Color(4281349688),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme().toColorScheme());
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
      color: Color(4278218269),
      onColor: Color(4294967295),
      colorContainer: Color(4280534850),
      onColorContainer: Color(4278200325),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(4278218269),
      onColor: Color(4294967295),
      colorContainer: Color(4280534850),
      onColorContainer: Color(4278200325),
    ),
    lightHighContrast: ColorFamily(
      color: Color(4278218269),
      onColor: Color(4294967295),
      colorContainer: Color(4280534850),
      onColorContainer: Color(4278200325),
    ),
    dark: ColorFamily(
      color: Color(4283032154),
      onColor: Color(4278204682),
      colorContainer: Color(4278235188),
      onColorContainer: Color(4278191873),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(4283032154),
      onColor: Color(4278204682),
      colorContainer: Color(4278235188),
      onColorContainer: Color(4278191873),
    ),
    darkHighContrast: ColorFamily(
      color: Color(4283032154),
      onColor: Color(4278204682),
      colorContainer: Color(4278235188),
      onColorContainer: Color(4278191873),
    ),
  );


  List<ExtendedColor> get extendedColors => [
    success,
  ];
}

class MaterialScheme {
  const MaterialScheme({
    required this.brightness,
    required this.primary, 
    required this.surfaceTint, 
    required this.onPrimary, 
    required this.primaryContainer, 
    required this.onPrimaryContainer, 
    required this.secondary, 
    required this.onSecondary, 
    required this.secondaryContainer, 
    required this.onSecondaryContainer, 
    required this.tertiary, 
    required this.onTertiary, 
    required this.tertiaryContainer, 
    required this.onTertiaryContainer, 
    required this.error, 
    required this.onError, 
    required this.errorContainer, 
    required this.onErrorContainer, 
    required this.background, 
    required this.onBackground, 
    required this.surface, 
    required this.onSurface, 
    required this.surfaceVariant, 
    required this.onSurfaceVariant, 
    required this.outline, 
    required this.outlineVariant, 
    required this.shadow, 
    required this.scrim, 
    required this.inverseSurface, 
    required this.inverseOnSurface, 
    required this.inversePrimary, 
    required this.primaryFixed, 
    required this.onPrimaryFixed, 
    required this.primaryFixedDim, 
    required this.onPrimaryFixedVariant, 
    required this.secondaryFixed, 
    required this.onSecondaryFixed, 
    required this.secondaryFixedDim, 
    required this.onSecondaryFixedVariant, 
    required this.tertiaryFixed, 
    required this.onTertiaryFixed, 
    required this.tertiaryFixedDim, 
    required this.onTertiaryFixedVariant, 
    required this.surfaceDim, 
    required this.surfaceBright, 
    required this.surfaceContainerLowest, 
    required this.surfaceContainerLow, 
    required this.surfaceContainer, 
    required this.surfaceContainerHigh, 
    required this.surfaceContainerHighest, 
  });

  final Brightness brightness;
  final Color primary;
  final Color surfaceTint;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color background;
  final Color onBackground;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color shadow;
  final Color scrim;
  final Color inverseSurface;
  final Color inverseOnSurface;
  final Color inversePrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;
  final Color primaryFixedDim;
  final Color onPrimaryFixedVariant;
  final Color secondaryFixed;
  final Color onSecondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color onTertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryFixedVariant;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
}

extension MaterialSchemeUtils on MaterialScheme {
  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
    );
  }
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
