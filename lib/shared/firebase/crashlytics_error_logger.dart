import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

/// Reports uncaught errors to Crashlytics as fatal, other unexpected errors as non-fatal, and refusals the player was
/// told about as breadcrumbs. Everything also goes to the console.
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
