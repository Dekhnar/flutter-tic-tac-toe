import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/composition.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session_starter.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/firebase/firebase_environment.dart';

import 'shared/golden_test_utils/devices.dart';

const _jessy = PlayerId('jessy-uid');

/// The app follows the device language, English in tests.
final i18n = lookupI18n(const Locale('en'));

void main() {
  group('Without Firebase options', () {
    testWidgets('the app starts, and its online mode says the build does not offer it', (tester) async {
      await _openOnlineMode(tester, const FirebaseStartup());

      expect(find.text(i18n.onlineUnavailable), findsOneWidget);
    });

    test('local games start, and online ones are refused for that reason', () async {
      final starter = (await _container(const FirebaseStartup())).read(gameSessionStarterProvider);

      expect(
        await starter.start(GameCreateInput.local(guestName: 'Mario', hostName: 'Jessy')),
        isA<LocalGameSession>(),
      );
      await expectLater(
        starter.start(GameCreateInput.createOnline(hostName: 'Jessy')),
        throwsA(
          isA<OnlineUnavailableException>().having((e) => e.reason, 'reason', OnlineUnavailableReason.notConfigured),
        ),
      );
    });
  });

  group('With Firebase options', () {
    testWidgets('when Firebase fails to start, the online mode says it could not start', (tester) async {
      await _openOnlineMode(tester, _FakeStartup(initializeAppFails: true));

      expect(find.text(i18n.onlineFailedToStart), findsOneWidget);
    });

    test('online games are created with the services Firebase started', () async {
      final firestore = FakeFirebaseFirestore();
      final container = await _container(_FakeStartup(firestore: firestore));

      final session = await _createOnlineGame(container);

      expect(session.me, _jessy);
      expect((await firestore.collection('games').doc(session.gameId.value).get()).exists, isTrue);
    });

    test('App Check failing to start leaves online play on, and is reported as a crash report', () async {
      final crashReports = _RecordingLogger();
      final container = await _container(_FakeStartup(appCheckFails: true, crashReports: crashReports));

      expect(await _createOnlineGame(container), isA<OnlineGameSession>());
      expect(crashReports.errors, [isA<_AppCheckFailure>()]);
    });

    test('crash reports failing to start leave online play on, and errors go to the console', () async {
      final container = await _container(_FakeStartup(crashReportsFail: true));

      expect(await _createOnlineGame(container), isA<OnlineGameSession>());
      expect(container.read(errorLoggerProvider), isA<DeveloperErrorLogger>());
    });
  });
}

Future<ProviderContainer> _container(FirebaseStartup firebase) async {
  final container = await createAppContainer(firebase: firebase);
  addTearDown(container.dispose);
  return container;
}

Future<GameSession> _createOnlineGame(ProviderContainer container) =>
    container.read(gameSessionStarterProvider).start(GameCreateInput.createOnline(hostName: 'Jessy'));

Future<void> _openOnlineMode(WidgetTester tester, FirebaseStartup firebase) async {
  tester.view.physicalSize = GoldenScreen.iphone11.size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = await _container(firebase);

  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const App()));
  await tester.pumpAndSettle();
  await tester.tap(find.text(i18n.online1v1));
  await tester.pumpAndSettle();
}

/// Firebase as a build with options starts it, each step able to fail.
final class _FakeStartup extends FirebaseStartup {
  _FakeStartup({
    this.appCheckFails = false,
    this.crashReports = const DeveloperErrorLogger(),
    this.crashReportsFail = false,
    FakeFirebaseFirestore? firestore,
    this.initializeAppFails = false,
  }) : _firestore = firestore ?? FakeFirebaseFirestore();

  final bool appCheckFails;
  final ErrorLogger crashReports;
  final bool crashReportsFail;
  final bool initializeAppFails;
  final FakeFirebaseFirestore _firestore;

  @override
  FirebaseOptions get options => FirebaseEnvironment.emulatorOptions;

  @override
  bool get usesEmulators => false;

  @override
  Future<void> initializeApp(FirebaseOptions options) async {
    if (initializeAppFails) throw FirebaseException(plugin: 'core', message: 'invalid options');
  }

  @override
  OnlinePlayAvailable onlinePlay() => OnlinePlayAvailable(
    identity: const _SignedIn(_jessy),
    repository: FirestoreGameRepository(firestore: _firestore),
  );

  @override
  Future<ErrorLogger> enableCrashReports() async =>
      crashReportsFail ? throw FirebaseException(plugin: 'crashlytics') : crashReports;

  @override
  Future<void> activateAppCheck() async {
    if (appCheckFails) throw _AppCheckFailure();
  }
}

final class _AppCheckFailure implements Exception {}

final class _RecordingLogger implements ErrorLogger {
  final errors = <Object>[];

  @override
  void log(Object error, StackTrace? stackTrace, {bool fatal = false}) => errors.add(error);
}

final class _SignedIn implements PlayerIdentity {
  const _SignedIn(this._player);

  final PlayerId _player;

  @override
  Future<PlayerId> signIn() async => _player;
}
