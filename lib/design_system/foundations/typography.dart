import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Google fonts constant setting: https://fonts.google.com/
TextTheme buildTextTheme(TextTheme baseTextTheme, Color textColor) {
  final typography = Typography.material2021(platform: defaultTargetPlatform).englishLike;
  return GoogleFonts.ralewayTextTheme(
    TextTheme(
      displayLarge: baseTextTheme.displayLarge?.copyWith(color: textColor, fontSize: typography.displayLarge?.fontSize),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: textColor,
        fontSize: typography.displayMedium?.fontSize,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(color: textColor, fontSize: typography.displaySmall?.fontSize),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: textColor,
        fontSize: typography.headlineLarge?.fontSize,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: textColor,
        fontSize: typography.headlineMedium?.fontSize,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: textColor,
        fontSize: typography.headlineSmall?.fontSize,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(color: textColor, fontSize: typography.titleLarge?.fontSize),
      titleMedium: baseTextTheme.titleMedium?.copyWith(color: textColor, fontSize: typography.titleMedium?.fontSize),
      titleSmall: baseTextTheme.titleSmall?.copyWith(color: textColor, fontSize: typography.titleSmall?.fontSize),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textColor, fontSize: typography.bodyLarge?.fontSize),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textColor, fontSize: typography.bodyMedium?.fontSize),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: textColor, fontSize: typography.bodySmall?.fontSize),
      labelLarge: baseTextTheme.labelLarge?.copyWith(color: textColor, fontSize: typography.labelLarge?.fontSize),
      labelMedium: baseTextTheme.labelMedium?.copyWith(color: textColor, fontSize: typography.labelMedium?.fontSize),
      labelSmall: baseTextTheme.labelSmall?.copyWith(color: textColor, fontSize: typography.labelSmall?.fontSize),
    ),
  );
}
