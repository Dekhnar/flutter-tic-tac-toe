import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

/// Logs every provider failure once: a failed build, a stream error, an error state. Notifiers do not log their own.
final class AsyncErrorLogger extends ProviderObserver {
  const AsyncErrorLogger();

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    context.container.read(errorLoggerProvider).log(error, stackTrace);
  }
}
