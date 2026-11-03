import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

part 'error_logger.g.dart';

/// Receives every error, from the global error handlers and the provider observer alike.
abstract interface class ErrorLogger {
  /// A [fatal] error is one nothing caught: the app may be in a broken state.
  void log(Object error, StackTrace? stackTrace, {bool fatal = false});
}

/// Writes refusals the player was told about as warnings, anything else as severe.
final class DeveloperErrorLogger implements ErrorLogger {
  const DeveloperErrorLogger();

  static const _name = 'tic_tac_toe';
  static const _severe = 1000;
  static const _warning = 900;

  @override
  void log(Object error, StackTrace? stackTrace, {bool fatal = false}) => switch (error) {
    ExpectedException() when !fatal => developer.log('$error', name: _name, level: _warning, error: error),
    _ => developer.log(
      fatal ? 'Uncaught error' : 'Unexpected error',
      name: _name,
      level: _severe,
      error: error,
      stackTrace: stackTrace,
    ),
  };
}

@Riverpod(keepAlive: true)
ErrorLogger errorLogger(Ref ref) => const DeveloperErrorLogger();
