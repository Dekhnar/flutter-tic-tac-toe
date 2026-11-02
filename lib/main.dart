import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/exceptions/async_error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/firebase/firebase_environment.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const errorLoggerService = ErrorLoggerService();
  final container = await createAppContainer(errorLogger: errorLoggerService);

  _registerErrorHandlers(errorLoggerService);
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

/// The providers wired as `main` runs the app, minus the global error handlers: integration tests use it as is.
Future<ProviderContainer> createAppContainer({ErrorLoggerService errorLogger = const ErrorLoggerService()}) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final isOnlineAvailable = await _initializeFirebase(errorLogger);

  final container = ProviderContainer(
    overrides: [isOnlineAvailableProvider.overrideWithValue(isOnlineAvailable)],
    observers: [const AsyncErrorLogger()],
  );
  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  } catch (error, stackTrace) {
    errorLogger.logError(error, stackTrace);
  }

  return container;
}

Future<bool> _initializeFirebase(ErrorLoggerService errorLogger) async {
  final options = FirebaseEnvironment.currentPlatform;
  if (options == null) return false;

  try {
    await FirebaseEnvironment.initialize(options);
    return true;
  } catch (error, stackTrace) {
    errorLogger.logError(error, stackTrace);
    return false;
  }
}

void _registerErrorHandlers(ErrorLoggerService errorLogger) {
  // * Register error handlers. For more info, see:
  // * https://docs.flutter.dev/testing/errors

  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    errorLogger.logError(details.exception, details.stack);
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    errorLogger.logError(error, stack);
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
    final message = kReleaseMode ? I18n.maybeOf(context)?.errorRetryLater ?? 'An error occurred.' : details.toString();

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
