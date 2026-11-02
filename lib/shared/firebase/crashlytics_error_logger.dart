import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

/// Reports unexpected errors to Crashlytics; refusals the player was told about only become breadcrumbs of the next
/// report. Debug builds show both in the console too, Crashlytics collecting nothing from them.
final class CrashlyticsErrorLogger implements ErrorLogger {
  const CrashlyticsErrorLogger(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  void log(Object error, StackTrace? stackTrace) {
    const DeveloperErrorLogger().log(error, stackTrace);

    switch (error) {
      case ExpectedException():
        unawaited(_crashlytics.log('$error'));
      default:
        unawaited(_crashlytics.recordError(error, stackTrace));
    }
  }
}
