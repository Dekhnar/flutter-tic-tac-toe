import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/design_system/foundations/theme.dart';

part 'bootstrap_provider.g.dart';

class BootstrapData {
  final Locale locale;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;

  BootstrapData({required this.locale, this.theme, this.darkTheme, this.themeMode});
}

@Riverpod(keepAlive: true)
Future<BootstrapData> bootstrapService(Ref ref) async {
  final platformDispatcher = PlatformDispatcher.instance;
  final deviceLocale = platformDispatcher.locale;
  final appLocale = switch (deviceLocale.languageCode) {
    'fr' => const Locale('fr', 'FR'),
    _ => const Locale('en'),
  };

  final deviceBrightness = platformDispatcher.platformBrightness;

  final isDark = switch (deviceBrightness) {
    Brightness.dark => true,
    Brightness.light => false,
  };

  return BootstrapData(locale: appLocale, theme: ThemeBuilder.buildTheme(isDark: isDark));
}
