import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Raleway ships as plain assets, not as declared fonts: it has to be loaded before the first golden renders.
  GoogleFonts.ralewayTextTheme();
  await GoogleFonts.pendingFonts();

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
