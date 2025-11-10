import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

class AsyncErrorLogger extends ProviderObserver {
  const AsyncErrorLogger();
  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue, Object? newValue, ProviderContainer container) {
    final errorLogger = container.read(errorLoggerServiceProvider);
    switch (newValue) {
      case AsyncError(:final error, :final stackTrace):
        switch (error) {
          case AppException():
            errorLogger.logAppException(error);
          default:
            errorLogger.logError(error, stackTrace);
        }
    }
  }
}
