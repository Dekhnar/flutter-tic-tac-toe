import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/design_system/foundations/theme.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Tests render with a placeholder font unless the app's own is loaded: every test lays text out as the app does.
  await (FontLoader(ThemeBuilder.fontFamily)..addFont(rootBundle.load('assets/fonts/Raleway-Regular.ttf'))).load();

  // Two sets of goldens. `goldens/macos/` shows the real text; text rasterizes differently on each OS, so they are
  // checked on macOS only. `goldens/ci/` draws text as boxes, the same on every OS.
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(platformGoldensConfig: PlatformGoldensConfig(platforms: {HostPlatform.macOS})),
    run: testMain,
  );
}
