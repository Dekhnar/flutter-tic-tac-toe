import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Google fonts constant setting: https://fonts.google.com/
TextTheme buildTextTheme(TextTheme baseTextTheme, Color textColor) {
  return GoogleFonts.ralewayTextTheme(
    TextTheme(
      displayLarge: baseTextTheme.displayLarge?.copyWith(color: textColor),
      displayMedium: baseTextTheme.displayMedium?.copyWith(color: textColor),
      displaySmall: baseTextTheme.displaySmall?.copyWith(color: textColor),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: textColor),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: textColor),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: textColor),
      titleLarge: baseTextTheme.titleLarge?.copyWith(color: textColor),
      titleMedium: baseTextTheme.titleMedium?.copyWith(color: textColor),
      titleSmall: baseTextTheme.titleSmall?.copyWith(color: textColor),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: textColor),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: textColor),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: textColor),
      labelLarge: baseTextTheme.labelLarge?.copyWith(color: textColor),
      labelMedium: baseTextTheme.labelMedium?.copyWith(color: textColor),
      labelSmall: baseTextTheme.labelSmall?.copyWith(color: textColor),
    ),
  );
}
