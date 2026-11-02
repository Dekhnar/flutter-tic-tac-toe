import 'package:flutter/material.dart';

/// The screens every golden is rendered on; [name] is the suffix of the golden file.
enum GoldenScreen {
  iphone11(size: Size(414, 896), themeMode: ThemeMode.dark),
  a11y(size: Size(375, 667), themeMode: ThemeMode.dark, textScaleFactor: 2),
  light(size: Size(414, 896), themeMode: ThemeMode.light),
  semantic(size: Size(375, 667), themeMode: ThemeMode.dark, showSemantics: true);

  const GoldenScreen({
    required this.size,
    required this.themeMode,
    this.textScaleFactor = 1,
    this.showSemantics = false,
  });

  final Size size;
  final ThemeMode themeMode;
  final double textScaleFactor;
  final bool showSemantics;
}
