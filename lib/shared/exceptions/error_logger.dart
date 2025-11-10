import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

part 'error_logger.g.dart';

class ErrorLoggerService {
  const ErrorLoggerService();

  void logError(Object error, StackTrace? stackTrace) => debugPrint('$error, $stackTrace');
  void logAppException(AppException exception) => debugPrint('$exception');
}

@riverpod
ErrorLoggerService errorLoggerService(Ref ref) => const ErrorLoggerService();
