import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

part 'error_logger.g.dart';

/// Single entry point for error reporting: a crash reporter (e.g. Crashlytics) plugs in here.
class ErrorLoggerService {
  const ErrorLoggerService();

  static const _name = 'tic_tac_toe';
  static const _severe = 1000;
  static const _warning = 900;

  void log(Object error, StackTrace? stackTrace) => switch (error) {
    ExpectedException() => developer.log('$error', name: _name, level: _warning, error: error),
    _ => developer.log('Unexpected error', name: _name, level: _severe, error: error, stackTrace: stackTrace),
  };
}

@Riverpod(keepAlive: true)
ErrorLoggerService errorLoggerService(Ref ref) => const ErrorLoggerService();
