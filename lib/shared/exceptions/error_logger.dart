import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

part 'error_logger.g.dart';

/// Where every error ends up: the global error handlers and the provider observer use the one instance the
/// composition binds.
abstract interface class ErrorLogger {
  void log(Object error, StackTrace? stackTrace);
}

/// Writes errors to the developer console, where debug builds show them: refusals the player was told about as
/// warnings, anything else as severe.
final class DeveloperErrorLogger implements ErrorLogger {
  const DeveloperErrorLogger();

  static const _name = 'tic_tac_toe';
  static const _severe = 1000;
  static const _warning = 900;

  @override
  void log(Object error, StackTrace? stackTrace) => switch (error) {
    ExpectedException() => developer.log('$error', name: _name, level: _warning, error: error),
    _ => developer.log('Unexpected error', name: _name, level: _severe, error: error, stackTrace: stackTrace),
  };
}

@Riverpod(keepAlive: true)
ErrorLogger errorLogger(Ref ref) => const DeveloperErrorLogger();
