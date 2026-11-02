import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase options read from `--dart-define-from-file=firebase_options.json`, or the local emulators with
/// `--dart-define-from-file=firebase_emulator.json`.
///
/// [currentPlatform] is null when the build carries no options for the current platform: the app then runs without
/// the online mode instead of failing to compile or to start.
abstract final class FirebaseEnvironment {
  static const _androidApiKey = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const _androidAppId = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
  static const _appleApiKey = String.fromEnvironment('FIREBASE_APPLE_API_KEY');
  static const _appleAppId = String.fromEnvironment('FIREBASE_APPLE_APP_ID');
  static const _appleBundleId = String.fromEnvironment('FIREBASE_APPLE_BUNDLE_ID');
  static const _emulatorHost = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
  static const _messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  static const authEmulatorPort = 9099;
  static const firestoreEmulatorPort = 8080;

  /// The emulators accept any `demo-` project without credentials; the native SDK still checks the API key format.
  static const emulatorOptions = FirebaseOptions(
    apiKey: 'AIzaSyDemoLocalEmulatorsOnly00000000000',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-tic-tac-toe',
  );

  static bool get usesEmulators => _emulatorHost.isNotEmpty;

  static FirebaseOptions? get currentPlatform {
    if (usesEmulators) return emulatorOptions;
    if (kIsWeb || _projectId.isEmpty) return null;

    final (apiKey, appId) = switch (defaultTargetPlatform) {
      TargetPlatform.android => (_androidApiKey, _androidAppId),
      TargetPlatform.iOS || TargetPlatform.macOS => (_appleApiKey, _appleAppId),
      _ => ('', ''),
    };

    if (apiKey.isEmpty || appId.isEmpty) return null;

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      iosBundleId: _appleBundleId.isEmpty ? null : _appleBundleId,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
    );
  }

  /// Initializes the default app, pointed at the emulators when the build asks for them.
  static Future<void> initialize(FirebaseOptions options) async {
    if (Firebase.apps.isNotEmpty) return;

    final app = await Firebase.initializeApp(options: options);
    if (usesEmulators) await useEmulators(app);
  }

  static Future<void> useEmulators(FirebaseApp app) async {
    await FirebaseAuth.instanceFor(app: app).useAuthEmulator(_hostOfEmulators, authEmulatorPort);
    FirebaseFirestore.instanceFor(app: app).useFirestoreEmulator(_hostOfEmulators, firestoreEmulatorPort);
  }

  /// The Android emulator reaches the host machine at 10.0.2.2, not at its own localhost.
  static String get _hostOfEmulators =>
      defaultTargetPlatform == TargetPlatform.android && _emulatorHost == 'localhost' ? '10.0.2.2' : _emulatorHost;
}
