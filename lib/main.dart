import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/shared/bootstrap/bootstrap_provider.dart';
import 'package:tic_tac_toe_app/shared/exceptions/async_error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/firebase/firebase_environment.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = false;

  const errorLoggerService = ErrorLoggerService();
  final isOnlineAvailable = await _initializeFirebase(errorLoggerService);

  final container = ProviderContainer(
    overrides: [isOnlineAvailableProvider.overrideWithValue(isOnlineAvailable)],
    observers: [const AsyncErrorLogger()],
  );
  try {
    await Future.wait([
      container.read(bootstrapServiceProvider.future),
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
    ]);
  } catch (e, st) {
    errorLoggerService.logError(e, st);
  }

  _registerErrorHandlers(errorLoggerService);
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

Future<bool> _initializeFirebase(ErrorLoggerService errorLogger) async {
  final options = FirebaseEnvironment.currentPlatform;
  if (options == null) return false;

  try {
    await Firebase.initializeApp(options: options);
    return true;
  } catch (e, st) {
    errorLogger.logError(e, st);
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
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red, title: Text('An error occurred')),
      body: Center(child: Text(details.toString())),
    );
  };
}
