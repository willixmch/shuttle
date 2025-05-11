import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff1b6b51),
      surfaceTint: Color(0xff1b6b51),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffa6f2d1),
      onPrimaryContainer: Color(0xff00513b),
      secondary: Color(0xff4c6359),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcfe9db),
      onSecondaryContainer: Color(0xff354b41),
      tertiary: Color(0xff3e6374),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc2e8fd),
      onTertiaryContainer: Color(0xff264b5c),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff5fbf5),
      onSurface: Color(0xff171d1a),
      onSurfaceVariant: Color(0xff404944),
      outline: Color(0xff707974),
      outlineVariant: Color(0xffbfc9c2),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8bd6b6),
      primaryFixed: Color(0xffa6f2d1),
      onPrimaryFixed: Color(0xff002116),
      primaryFixedDim: Color(0xff8bd6b6),
      onPrimaryFixedVariant: Color(0xff00513b),
      secondaryFixed: Color(0xffcfe9db),
      onSecondaryFixed: Color(0xff092017),
      secondaryFixedDim: Color(0xffb3ccbf),
      onSecondaryFixedVariant: Color(0xff354b41),
      tertiaryFixed: Color(0xffc2e8fd),
      onTertiaryFixed: Color(0xff001f2a),
      tertiaryFixedDim: Color(0xffa6cce0),
      onTertiaryFixedVariant: Color(0xff264b5c),
      surfaceDim: Color(0xffd6dbd6),
      surfaceBright: Color(0xfff5fbf5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f0),
      surfaceContainer: Color(0xffe9efea),
      surfaceContainerHigh: Color(0xffe4eae4),
      surfaceContainerHighest: Color(0xffdee4df),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003f2d),
      surfaceTint: Color(0xff1b6b51),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff2e7a5f),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff243b31),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff5b7267),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff123a4a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff4d7284),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf5),
      onSurface: Color(0xff0d1210),
      onSurfaceVariant: Color(0xff2f3834),
      outline: Color(0xff4b554f),
      outlineVariant: Color(0xff666f6a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8bd6b6),
      primaryFixed: Color(0xff2e7a5f),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff096148),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff5b7267),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff435a4f),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff4d7284),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff35596a),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c8c3),
      surfaceBright: Color(0xfff5fbf5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f0),
      surfaceContainer: Color(0xffe4eae4),
      surfaceContainerHigh: Color(0xffd8ded9),
      surfaceContainerHighest: Color(0xffcdd3ce),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003324),
      surfaceTint: Color(0xff1b6b51),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff00543d),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff1a3027),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff374e44),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff033040),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff284e5e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff5fbf5),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252e2a),
      outlineVariant: Color(0xff424b46),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c322e),
      inversePrimary: Color(0xff8bd6b6),
      primaryFixed: Color(0xff00543d),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff003b2a),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff374e44),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff21372e),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff284e5e),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff0d3747),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4bab5),
      surfaceBright: Color(0xfff5fbf5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2ed),
      surfaceContainer: Color(0xffdee4df),
      surfaceContainerHigh: Color(0xffd0d6d1),
      surfaceContainerHighest: Color(0xffc2c8c3),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff8bd6b6),
      surfaceTint: Color(0xff8bd6b6),
      onPrimary: Color(0xff003828),
      primaryContainer: Color(0xff00513b),
      onPrimaryContainer: Color(0xffa6f2d1),
      secondary: Color(0xffb3ccbf),
      onSecondary: Color(0xff1e352b),
      secondaryContainer: Color(0xff354b41),
      onSecondaryContainer: Color(0xffcfe9db),
      tertiary: Color(0xffa6cce0),
      onTertiary: Color(0xff093544),
      tertiaryContainer: Color(0xff264b5c),
      onTertiaryContainer: Color(0xffc2e8fd),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0f1512),
      onSurface: Color(0xffdee4df),
      onSurfaceVariant: Color(0xffbfc9c2),
      outline: Color(0xff89938d),
      outlineVariant: Color(0xff404944),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4df),
      inversePrimary: Color(0xff1b6b51),
      primaryFixed: Color(0xffa6f2d1),
      onPrimaryFixed: Color(0xff002116),
      primaryFixedDim: Color(0xff8bd6b6),
      onPrimaryFixedVariant: Color(0xff00513b),
      secondaryFixed: Color(0xffcfe9db),
      onSecondaryFixed: Color(0xff092017),
      secondaryFixedDim: Color(0xffb3ccbf),
      onSecondaryFixedVariant: Color(0xff354b41),
      tertiaryFixed: Color(0xffc2e8fd),
      onTertiaryFixed: Color(0xff001f2a),
      tertiaryFixedDim: Color(0xffa6cce0),
      onTertiaryFixedVariant: Color(0xff264b5c),
      surfaceDim: Color(0xff0f1512),
      surfaceBright: Color(0xff343b37),
      surfaceContainerLowest: Color(0xff0a0f0d),
      surfaceContainerLow: Color(0xff171d1a),
      surfaceContainer: Color(0xff1b211e),
      surfaceContainerHigh: Color(0xff252b28),
      surfaceContainerHighest: Color(0xff303633),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffa0eccb),
      surfaceTint: Color(0xff8bd6b6),
      onPrimary: Color(0xff002c1f),
      primaryContainer: Color(0xff559e82),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc8e2d5),
      onSecondary: Color(0xff132a21),
      secondaryContainer: Color(0xff7e968a),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffbce2f6),
      onTertiary: Color(0xff002938),
      tertiaryContainer: Color(0xff7196a9),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1512),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd5dfd8),
      outline: Color(0xffabb4ae),
      outlineVariant: Color(0xff89938d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4df),
      inversePrimary: Color(0xff00533c),
      primaryFixed: Color(0xffa6f2d1),
      onPrimaryFixed: Color(0xff00150d),
      primaryFixedDim: Color(0xff8bd6b6),
      onPrimaryFixedVariant: Color(0xff003f2d),
      secondaryFixed: Color(0xffcfe9db),
      onSecondaryFixed: Color(0xff01150d),
      secondaryFixedDim: Color(0xffb3ccbf),
      onSecondaryFixedVariant: Color(0xff243b31),
      tertiaryFixed: Color(0xffc2e8fd),
      onTertiaryFixed: Color(0xff00131c),
      tertiaryFixedDim: Color(0xffa6cce0),
      onTertiaryFixedVariant: Color(0xff123a4a),
      surfaceDim: Color(0xff0f1512),
      surfaceBright: Color(0xff404642),
      surfaceContainerLowest: Color(0xff040806),
      surfaceContainerLow: Color(0xff191f1c),
      surfaceContainer: Color(0xff232926),
      surfaceContainerHigh: Color(0xff2e3431),
      surfaceContainerHighest: Color(0xff393f3c),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb7ffdf),
      surfaceTint: Color(0xff8bd6b6),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff87d2b2),
      onPrimaryContainer: Color(0xff000e08),
      secondary: Color(0xffdcf6e8),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffafc8bb),
      onSecondaryContainer: Color(0xff000e08),
      tertiary: Color(0xffdff3ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffa2c8dc),
      onTertiaryContainer: Color(0xff000d14),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0f1512),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe9f2eb),
      outlineVariant: Color(0xffbbc5be),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdee4df),
      inversePrimary: Color(0xff00533c),
      primaryFixed: Color(0xffa6f2d1),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff8bd6b6),
      onPrimaryFixedVariant: Color(0xff00150d),
      secondaryFixed: Color(0xffcfe9db),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb3ccbf),
      onSecondaryFixedVariant: Color(0xff01150d),
      tertiaryFixed: Color(0xffc2e8fd),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffa6cce0),
      onTertiaryFixedVariant: Color(0xff00131c),
      surfaceDim: Color(0xff0f1512),
      surfaceBright: Color(0xff4b514e),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b211e),
      surfaceContainer: Color(0xff2c322e),
      surfaceContainerHigh: Color(0xff373d39),
      surfaceContainerHighest: Color(0xff424845),
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
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );

  /// Success
  static const success = ExtendedColor(
    seed: Color(0xff2e9470),
    value: Color(0xff2e9470),
    light: ColorFamily(
      color: Color(0xff1d6b50),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffa7f2d0),
      onColorContainer: Color(0xff00513a),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff1d6b50),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffa7f2d0),
      onColorContainer: Color(0xff00513a),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff1d6b50),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffa7f2d0),
      onColorContainer: Color(0xff00513a),
    ),
    dark: ColorFamily(
      color: Color(0xff8cd5b4),
      onColor: Color(0xff003827),
      colorContainer: Color(0xff00513a),
      onColorContainer: Color(0xffa7f2d0),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xff8cd5b4),
      onColor: Color(0xff003827),
      colorContainer: Color(0xff00513a),
      onColorContainer: Color(0xffa7f2d0),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xff8cd5b4),
      onColor: Color(0xff003827),
      colorContainer: Color(0xff00513a),
      onColorContainer: Color(0xffa7f2d0),
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
