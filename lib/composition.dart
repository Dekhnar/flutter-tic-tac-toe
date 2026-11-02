import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tic_tac_toe_app/features/game/data/auth/firebase_player_identity.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_providers.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';
import 'package:tic_tac_toe_app/shared/exceptions/async_error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/firebase/crashlytics_error_logger.dart';
import 'package:tic_tac_toe_app/shared/firebase/firebase_environment.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

/// The services online play needs, available once Firebase is initialized.
typedef OnlineServices = ({OnlineGameRepositoryInterface repository, PlayerIdentity identity});

/// Everything the app needs before its first frame, and the one place that picks the implementation behind each
/// contract. Integration tests start the app from it too.
Future<ProviderContainer> createAppContainer() async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final firebase = await _initializeFirebase();
  final errorLogger = switch (firebase) {
    _Firebase.project => CrashlyticsErrorLogger(FirebaseCrashlytics.instance),
    _Firebase.emulators || _Firebase.none => const DeveloperErrorLogger(),
  };
  final online = switch (firebase) {
    _Firebase.none => null,
    _Firebase.emulators || _Firebase.project => (
      repository: FirestoreGameRepository(firestore: FirebaseFirestore.instance),
      identity: FirebasePlayerIdentity(auth: FirebaseAuth.instance),
    ),
  };

  return ProviderContainer(
    overrides: [errorLoggerProvider.overrideWithValue(errorLogger), ...bindGameProviders(online: online)],
    observers: [const AsyncErrorLogger()],
  );
}

/// Binds the contracts of `game_providers.dart`. Without [online] services, the online ones stay unbound and the
/// online mode tells the player it is unavailable.
List<Override> bindGameProviders({required OnlineServices? online}) => [
  isOnlineAvailableProvider.overrideWithValue(online != null),
  localGameRepositoryProvider.overrideWith((ref) {
    final repository = InMemoryGameRepository();
    ref.onDispose(repository.dispose);
    return repository;
  }),
  if (online != null) ...[
    onlineGameRepositoryProvider.overrideWithValue(online.repository),
    playerIdentityProvider.overrideWithValue(online.identity),
  ],
];

enum _Firebase { none, emulators, project }

/// A real project also gets crash reports and App Check; the emulators support neither.
Future<_Firebase> _initializeFirebase() async {
  final options = FirebaseEnvironment.currentPlatform;
  if (options == null) return _Firebase.none;

  try {
    await FirebaseEnvironment.initialize(options);
    if (FirebaseEnvironment.usesEmulators) return _Firebase.emulators;

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode ? const AppleDebugProvider() : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );
    return _Firebase.project;
  } catch (error, stackTrace) {
    const DeveloperErrorLogger().log(error, stackTrace);
    return _Firebase.none;
  }
}
