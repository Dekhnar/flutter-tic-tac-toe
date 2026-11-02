import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/composition.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = await createAppContainer();
  _registerErrorHandlers(container.read(errorLoggerProvider));
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

void _registerErrorHandlers(ErrorLogger errorLogger) {
  // * Register error handlers. For more info, see:
  // * https://docs.flutter.dev/testing/errors

  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    errorLogger.log(details.exception, details.stack);
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    errorLogger.log(error, stack);
    return true;
  };
  // * Show some error UI when any widget in the app fails to build
  ErrorWidget.builder = (FlutterErrorDetails details) => _BrokenWidget(details: details);
}

/// Replaces a widget that failed to build; the details only show in debug builds.
class _BrokenWidget extends StatelessWidget {
  const _BrokenWidget({required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final message = kDebugMode ? details.toString() : I18n.maybeOf(context)?.errorRetryLater ?? 'An error occurred.';

    return Material(
      color: colors.error,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimens.standardPadding),
          child: Text(message, style: TextStyle(color: colors.onError)),
        ),
      ),
    );
  }
}
