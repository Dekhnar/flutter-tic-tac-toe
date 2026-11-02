import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/design_system/foundations/theme.dart';

part 'bootstrap_provider.g.dart';

class BootstrapData {
  final ThemeData darkTheme;
  final ThemeData theme;

  const BootstrapData({required this.darkTheme, required this.theme});
}

@Riverpod(keepAlive: true)
Future<BootstrapData> bootstrapService(Ref ref) async =>
    BootstrapData(darkTheme: ThemeBuilder.buildDarkThemeData(), theme: ThemeBuilder.buildLightThemeData());
