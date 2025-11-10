import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/design_system/foundations/typography.dart';

final class ThemeBuilder {
  static ThemeData buildLightThemeData() => buildTheme(isDark: false);
  static ThemeData buildDarkThemeData() => buildTheme(isDark: true);

  static ThemeData buildTheme({required bool isDark}) {
    final baseTheme = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData(useMaterial3: true);

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,

      primary: const Color(0xFF00BB31),
      onPrimary: Colors.white,

      secondary: Colors.blue,
      onSecondary: Colors.white,

      error: Colors.red,
      onError: Colors.white,

      surface: isDark ? Colors.black : Colors.white,
      onSurface: isDark ? Colors.white : Colors.black,

      inverseSurface: isDark ? Colors.white : Colors.black,
      onInverseSurface: isDark ? Colors.black : Colors.white,
    );

    final textTheme = buildTextTheme(baseTheme.textTheme, colorScheme.onSurface);

    final textButtonStyle = ButtonStyle(
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.largeRadius))),
      padding: WidgetStatePropertyAll(
        const EdgeInsets.symmetric(vertical: Dimens.halfPadding, horizontal: Dimens.standardPadding),
      ),
      backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
      foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
      overlayColor: WidgetStatePropertyAll(colorScheme.onPrimary.withValues(alpha: 0.1)),
      minimumSize: WidgetStatePropertyAll(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStatePropertyAll(textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
    );

    final outlinedButtonStyle = textButtonStyle.copyWith(
      side: WidgetStatePropertyAll(BorderSide(color: colorScheme.primary)),
      backgroundColor: WidgetStatePropertyAll(null),
      foregroundColor: WidgetStatePropertyAll(colorScheme.primary),
      overlayColor: WidgetStatePropertyAll(colorScheme.primary.withValues(alpha: 0.08)),
    );

    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurfaceVariant,
        actionsIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: Dimens.standardAssetSize),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        margin: EdgeInsets.zero,
        surfaceTintColor: isDark ? Colors.white.withValues(alpha: 0.08) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimens.standardRadius)),
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      dividerColor: colorScheme.outline,
      dividerTheme: baseTheme.dividerTheme.copyWith(color: colorScheme.outline, thickness: Dimens.thinDividerThickness),

      buttonTheme: baseTheme.buttonTheme.copyWith(
        buttonColor: colorScheme.surface,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),

      highlightColor: colorScheme.primary.withValues(alpha: 0.32),

      textButtonTheme: TextButtonThemeData(style: textButtonStyle),

      outlinedButtonTheme: OutlinedButtonThemeData(style: outlinedButtonStyle),
    );
  }
}