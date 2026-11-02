import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase options read from `--dart-define-from-file=firebase_options.json`.
///
/// Returns null when the build carries no options for the current platform: the app then runs without the online
/// mode instead of failing to compile or to start.
abstract final class FirebaseEnvironment {
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const _storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const _androidApiKey = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const _androidAppId = String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
  static const _appleApiKey = String.fromEnvironment('FIREBASE_APPLE_API_KEY');
  static const _appleAppId = String.fromEnvironment('FIREBASE_APPLE_APP_ID');
  static const _appleBundleId = String.fromEnvironment('FIREBASE_APPLE_BUNDLE_ID');

  static FirebaseOptions? get currentPlatform {
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
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
      iosBundleId: _appleBundleId.isEmpty ? null : _appleBundleId,
    );
  }
}
