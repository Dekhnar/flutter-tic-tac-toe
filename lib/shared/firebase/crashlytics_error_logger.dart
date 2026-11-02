import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

/// Reports to Crashlytics: errors nothing caught as fatal crashes, other unexpected errors as non-fatal ones, and
/// refusals the player was told about only as breadcrumbs of the next report. Debug builds show them in the console
/// too, Crashlytics collecting nothing from them.
final class CrashlyticsErrorLogger implements ErrorLogger {
  const CrashlyticsErrorLogger(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  void log(Object error, StackTrace? stackTrace, {bool fatal = false}) {
    const DeveloperErrorLogger().log(error, stackTrace, fatal: fatal);

    switch (error) {
      case ExpectedException() when !fatal:
        unawaited(_crashlytics.log('$error'));
      default:
        unawaited(_crashlytics.recordError(error, stackTrace, fatal: fatal));
    }
  }
}
