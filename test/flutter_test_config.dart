import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  // CI goldens only: their text is rendered as blocks, so the images are identical on every OS and machine.
  return AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(platformGoldensConfig: PlatformGoldensConfig(enabled: false)),
    run: testMain,
  );
}
