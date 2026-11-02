import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

/// The one place that logs provider failures: a failed build, an error in a stream, and an async notifier whose state
/// becomes an error. Notifiers do not log what they put in their state.
final class AsyncErrorLogger extends ProviderObserver {
  const AsyncErrorLogger();

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    context.container.read(errorLoggerProvider).log(error, stackTrace);
  }
}
