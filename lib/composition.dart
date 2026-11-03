import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/data/auth/firebase_player_identity.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/shared/exceptions/async_error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/firebase/crashlytics_error_logger.dart';
import 'package:tic_tac_toe_app/shared/firebase/firebase_environment.dart';

/// Everything the app needs before its first frame, and the one place that picks the implementation behind each
/// contract. Integration tests start the app from it too.
Future<ProviderContainer> createAppContainer({FirebaseStartup firebase = const FirebaseStartup()}) async {
  final (onlinePlay, errorLogger) = await _start(firebase);

  return ProviderContainer(
    overrides: [errorLoggerProvider.overrideWithValue(errorLogger), ...bindGameProviders(onlinePlay: onlinePlay)],
    observers: [const AsyncErrorLogger()],
  );
}

/// Binds the contracts of `game_dependencies.dart`.
List<Override> bindGameProviders({required OnlinePlay onlinePlay}) => [
  localGameRepositoryProvider.overrideWith((ref) {
    final repository = InMemoryGameRepository();
    ref.onDispose(repository.dispose);
    return repository;
  }),
  onlinePlayProvider.overrideWithValue(onlinePlay),
];

/// Starts Firebase one step at a time: a step that fails leaves out only what depends on it, and is reported once the
/// error logger is known — through Crashlytics when that step went through.
Future<(OnlinePlay, ErrorLogger)> _start(FirebaseStartup firebase) async {
  const console = DeveloperErrorLogger();
  final options = firebase.options;
  if (options == null) return (const OnlinePlayUnavailable(OnlineUnavailableReason.notConfigured), console);

  try {
    await firebase.initializeApp(options);
  } catch (error, stackTrace) {
    // Crashlytics needs the app it failed to create: the console is the only place left to tell.
    console.log(error, stackTrace);
    return (const OnlinePlayUnavailable(OnlineUnavailableReason.failedToStart), console);
  }

  final onlinePlay = firebase.onlinePlay();
  if (firebase.usesEmulators) return (onlinePlay, console);

  final failures = <(Object, StackTrace)>[];
  Future<T?> attempt<T>(Future<T> Function() step) async {
    try {
      return await step();
    } catch (error, stackTrace) {
      failures.add((error, stackTrace));
      return null;
    }
  }

  final errorLogger = await attempt(firebase.enableCrashReports) ?? console;
  await attempt(firebase.activateAppCheck);
  for (final (error, stackTrace) in failures) {
    errorLogger.log(error, stackTrace);
  }
  return (onlinePlay, errorLogger);
}

/// The steps that start Firebase. A real project also gets crash reports and App Check; the emulators support neither.
class FirebaseStartup {
  const FirebaseStartup();

  FirebaseOptions? get options => FirebaseEnvironment.currentPlatform;

  bool get usesEmulators => FirebaseEnvironment.usesEmulators;

  Future<void> initializeApp(FirebaseOptions options) => FirebaseEnvironment.initialize(options);

  OnlinePlayAvailable onlinePlay() => OnlinePlayAvailable(
    identity: FirebasePlayerIdentity(auth: FirebaseAuth.instance),
    repository: FirestoreGameRepository(firestore: FirebaseFirestore.instance),
  );

  /// Collected from release builds only.
  Future<ErrorLogger> enableCrashReports() async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    return CrashlyticsErrorLogger(FirebaseCrashlytics.instance);
  }

  Future<void> activateAppCheck() => FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode ? const AppleDebugProvider() : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );
}
