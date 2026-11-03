import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/shared/firebase/firebase_environment.dart';

const _project = FirebaseEnvironment(
  androidApiKey: 'android-key',
  androidAppId: 'android-app',
  appleApiKey: 'apple-key',
  appleAppId: 'apple-app',
  appleBundleId: 'com.example.tictactoe',
  messagingSenderId: '1234',
  projectId: 'tic-tac-toe',
  storageBucket: 'tic-tac-toe.appspot.com',
);

void main() {
  test('a build without options runs without online play, on every platform', () {
    for (final platform in TargetPlatform.values) {
      expect(const FirebaseEnvironment().optionsFor(platform, isWeb: false), isNull, reason: platform.name);
    }
  });

  test('each mobile and desktop platform gets the app it is registered as', () {
    final android = _project.optionsFor(TargetPlatform.android, isWeb: false);
    final iOS = _project.optionsFor(TargetPlatform.iOS, isWeb: false);
    final macOS = _project.optionsFor(TargetPlatform.macOS, isWeb: false);

    expect((android?.apiKey, android?.appId, android?.projectId), ('android-key', 'android-app', 'tic-tac-toe'));
    expect((iOS?.apiKey, iOS?.appId, iOS?.iosBundleId), ('apple-key', 'apple-app', 'com.example.tictactoe'));
    expect(macOS, iOS);
    expect(android?.storageBucket, 'tic-tac-toe.appspot.com');
  });

  test('a platform the project registered no app for runs without online play', () {
    for (final platform in [TargetPlatform.linux, TargetPlatform.windows, TargetPlatform.fuchsia]) {
      expect(_project.optionsFor(platform, isWeb: false), isNull, reason: platform.name);
    }
    expect(_project.optionsFor(TargetPlatform.android, isWeb: true), isNull);
  });

  test('options missing the key or the app of a platform leave that platform without online play', () {
    const noAndroidKey = FirebaseEnvironment(androidAppId: 'android-app', projectId: 'tic-tac-toe');
    const noAppleApp = FirebaseEnvironment(appleApiKey: 'apple-key', projectId: 'tic-tac-toe');

    expect(noAndroidKey.optionsFor(TargetPlatform.android, isWeb: false), isNull);
    expect(noAppleApp.optionsFor(TargetPlatform.iOS, isWeb: false), isNull);
  });

  test('optional settings left out are not sent as empty values', () {
    const minimal = FirebaseEnvironment(androidApiKey: 'key', androidAppId: 'app', projectId: 'tic-tac-toe');

    final options = minimal.optionsFor(TargetPlatform.android, isWeb: false);

    expect((options?.iosBundleId, options?.storageBucket), (null, null));
  });

  group('A build for the emulators', () {
    const emulators = FirebaseEnvironment(emulatorHost: 'localhost');

    test('uses the demo project on every platform, the web included', () {
      expect(emulators.usesEmulators, isTrue);
      expect(emulators.optionsFor(TargetPlatform.android, isWeb: true), FirebaseEnvironment.emulatorOptions);
      expect(emulators.optionsFor(TargetPlatform.iOS, isWeb: false), FirebaseEnvironment.emulatorOptions);
    });

    test('reaches them on the host machine, which the Android emulator sees at 10.0.2.2', () {
      expect(emulators.emulatorHostFor(TargetPlatform.android), '10.0.2.2');
      expect(emulators.emulatorHostFor(TargetPlatform.iOS), 'localhost');
      expect(
        const FirebaseEnvironment(emulatorHost: '192.168.1.20').emulatorHostFor(TargetPlatform.android),
        '192.168.1.20',
      );
    });
  });
}
