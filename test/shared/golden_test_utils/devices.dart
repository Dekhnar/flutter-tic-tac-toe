import 'package:flutter/material.dart';

/// The screens every golden is rendered on; [name] is the suffix of the golden file.
enum GoldenScreen {
  a11y(size: Size(375, 667), textScaleFactor: 2, themeMode: ThemeMode.dark),
  iphone11(size: Size(414, 896), themeMode: ThemeMode.dark),
  light(size: Size(414, 896), themeMode: ThemeMode.light),
  semantic(showSemantics: true, size: Size(375, 667), themeMode: ThemeMode.dark);

  const GoldenScreen({
    this.showSemantics = false,
    required this.size,
    this.textScaleFactor = 1,
    required this.themeMode,
  });

  final bool showSemantics;
  final Size size;
  final double textScaleFactor;
  final ThemeMode themeMode;
}
