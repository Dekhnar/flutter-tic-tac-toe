import 'dart:async';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(() async {
    await loadAppFonts();
    GoogleFonts.config.allowRuntimeFetching = false;
    await testMain();
  }, config: GoldenToolkitConfiguration(enableRealShadows: true));
}
