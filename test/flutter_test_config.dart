import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/design_system/foundations/theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Tests render with a placeholder font unless the app's own is loaded: every test lays text out as the app does.
  await (FontLoader(ThemeBuilder.fontFamily)..addFont(rootBundle.load('assets/fonts/Raleway-Regular.ttf'))).load();

  // A single set of goldens with the real text. Text rasterization differs between OSes: regenerate them on macOS.
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      ciGoldensConfig: CiGoldensConfig(
        filePathResolver: (fileName, _) => 'goldens/$fileName.png',
        obscureText: false,
        renderShadows: true,
      ),
      platformGoldensConfig: const PlatformGoldensConfig(enabled: false),
    ),
    run: testMain,
  );
}
