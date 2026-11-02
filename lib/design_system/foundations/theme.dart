import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/design_system/foundations/typography.dart';

/// Material 3 themes on black and white surfaces. The brand green reads on dark backgrounds only: on light ones, a
/// deeper green of the same hue keeps text at the 4.5:1 contrast WCAG asks for.
final class ThemeBuilder {
  static const _brandGreen = Color(0xFF00BB31);
  static const _deepGreen = Color(0xFF00731F);

  static ThemeData buildLightThemeData() => buildTheme(isDark: false);
  static ThemeData buildDarkThemeData() => buildTheme(isDark: true);

  static ThemeData buildTheme({required bool isDark}) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final (paper, ink) = isDark ? (Colors.black, Colors.white) : (Colors.white, Colors.black);

    final colorScheme = ColorScheme.fromSeed(seedColor: _brandGreen, brightness: brightness).copyWith(
      primary: isDark ? _brandGreen : _deepGreen,
      onPrimary: isDark ? Colors.black : Colors.white,
      inversePrimary: isDark ? _deepGreen : _brandGreen,
      surface: paper,
      onSurface: ink,
      inverseSurface: ink,
      onInverseSurface: paper,
    );
    final textTheme = buildTextTheme(ThemeData(brightness: brightness).textTheme, colorScheme.onSurface);

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainer,
        centerTitle: true,
        elevation: 0,
        foregroundColor: colorScheme.onSurfaceVariant,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.standardRadius)),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant, thickness: Dimens.thinDividerThickness),
    );
  }
}
