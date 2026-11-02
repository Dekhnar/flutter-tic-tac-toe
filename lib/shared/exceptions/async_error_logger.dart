import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

/// Logs every provider that fails to build, an async one included (a failed future, an error in a stream).
final class AsyncErrorLogger extends ProviderObserver {
  const AsyncErrorLogger();

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    context.container.read(errorLoggerServiceProvider).log(error, stackTrace);
  }
}
