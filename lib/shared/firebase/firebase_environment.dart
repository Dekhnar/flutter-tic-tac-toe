import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// The Firebase project a build targets: `--dart-define-from-file=firebase_options.json`, or the local emulators with
/// `--dart-define-from-file=firebase_emulator.json`.
final class FirebaseEnvironment {
  const FirebaseEnvironment({
    this.androidApiKey = '',
    this.androidAppId = '',
    this.appleApiKey = '',
    this.appleAppId = '',
    this.appleBundleId = '',
    this.emulatorHost = '',
    this.messagingSenderId = '',
    this.projectId = '',
    this.storageBucket = '',
  });

  /// What this build was compiled with.
  static const current = FirebaseEnvironment(
    androidApiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    androidAppId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
    appleApiKey: String.fromEnvironment('FIREBASE_APPLE_API_KEY'),
    appleAppId: String.fromEnvironment('FIREBASE_APPLE_APP_ID'),
    appleBundleId: String.fromEnvironment('FIREBASE_APPLE_BUNDLE_ID'),
    emulatorHost: String.fromEnvironment('FIREBASE_EMULATOR_HOST'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
  );

  static const authEmulatorPort = 9099;
  static const firestoreEmulatorPort = 8080;

  /// The emulators accept any `demo-` project without credentials; the native SDK still checks the API key format.
  static const emulatorOptions = FirebaseOptions(
    apiKey: 'AIzaSyDemoLocalEmulatorsOnly00000000000',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'demo-tic-tac-toe',
  );

  final String androidApiKey;
  final String androidAppId;
  final String appleApiKey;
  final String appleAppId;
  final String appleBundleId;
  final String emulatorHost;
  final String messagingSenderId;
  final String projectId;
  final String storageBucket;

  bool get usesEmulators => emulatorHost.isNotEmpty;

  /// Null when the build carries no options for [platform]: the app then runs without online play.
  FirebaseOptions? optionsFor(TargetPlatform platform, {bool isWeb = kIsWeb}) {
    if (usesEmulators) return emulatorOptions;
    if (isWeb || projectId.isEmpty) return null;

    final (apiKey, appId) = switch (platform) {
      TargetPlatform.android => (androidApiKey, androidAppId),
      TargetPlatform.iOS || TargetPlatform.macOS => (appleApiKey, appleAppId),
      _ => ('', ''),
    };
    if (apiKey.isEmpty || appId.isEmpty) return null;

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      iosBundleId: appleBundleId.isEmpty ? null : appleBundleId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket.isEmpty ? null : storageBucket,
    );
  }

  /// The Android emulator reaches the host machine at 10.0.2.2, not at its own localhost.
  String emulatorHostFor(TargetPlatform platform) =>
      platform == TargetPlatform.android && emulatorHost == 'localhost' ? '10.0.2.2' : emulatorHost;

  /// Initializes the default app, pointed at the emulators when the build asks for them.
  Future<void> initialize(FirebaseOptions options) async {
    if (Firebase.apps.isNotEmpty) return;

    final app = await Firebase.initializeApp(options: options);
    if (usesEmulators) await useEmulators(app);
  }

  Future<void> useEmulators(FirebaseApp app) async {
    final host = emulatorHostFor(defaultTargetPlatform);
    await FirebaseAuth.instanceFor(app: app).useAuthEmulator(host, authEmulatorPort);
    FirebaseFirestore.instanceFor(app: app).useFirestoreEmulator(host, firestoreEmulatorPort);
  }
}
