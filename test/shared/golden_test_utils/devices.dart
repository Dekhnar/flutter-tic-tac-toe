import 'package:flutter/material.dart';

/// The screens every golden is rendered on; [name] is the suffix of the golden file.
enum GoldenScreen {
  a11y(size: Size(375, 667), textScaleFactor: 2, themeMode: ThemeMode.dark),
  iphone11(safeArea: _iphone11SafeArea, size: _iphone11Size, themeMode: ThemeMode.dark),
  light(safeArea: _iphone11SafeArea, size: _iphone11Size, themeMode: ThemeMode.light),
  semantic(showSemantics: true, size: Size(375, 667), themeMode: ThemeMode.dark);

  const GoldenScreen({
    this.safeArea = EdgeInsets.zero,
    this.showSemantics = false,
    required this.size,
    this.textScaleFactor = 1,
    required this.themeMode,
  });

  final EdgeInsets safeArea;
  final bool showSemantics;
  final Size size;
  final double textScaleFactor;
  final ThemeMode themeMode;
}

const _iphone11SafeArea = EdgeInsets.only(top: 44, bottom: 34);
const _iphone11Size = Size(414, 896);
