// Every ProviderScope below is the root of its test tree.
// ignore_for_file: scoped_providers_should_specify_dependencies

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_name.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

import '../../../../shared/fakes/pending_local_game_repository.dart';
import '../../../../shared/golden_test_utils/devices.dart';

const _jessy = PlayerId('jessy-uid');
const _luigi = PlayerId('luigi-uid');

/// The app follows the device language, English in tests.
final i18n = lookupI18n(const Locale('en'));

void main() {
  late InMemoryGameRepository games;

  setUp(() {
    games = InMemoryGameRepository();
    addTearDown(games.dispose);
  });

  for (final brightness in Brightness.values) {
    testWidgets('the home screen and its dialogs meet the accessibility guidelines in ${brightness.name} mode', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final semantics = tester.ensureSemantics();
      final robot = _HomeRobot(tester);
      await robot.launch(
        localRepository: games,
        online: [playerIdentityProvider.overrideWithValue(const _SignedIn(_luigi))],
      );

      Future<void> expectAccessible() async {
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      }

      await expectAccessible();
      for (final mode in [i18n.local1v1, i18n.online1v1]) {
        await robot.chooseMode(mode);
        await expectAccessible();
        await tester.tapAt(const Offset(4, 4));
        await tester.pumpAndSettle();
      }
      semantics.dispose();
    });
  }

  testWidgets('the creation dialogs fit a landscape phone with its keyboard open', (tester) async {
    final robot = _HomeRobot(tester);
    await robot.launch(
      localRepository: games,
      online: [playerIdentityProvider.overrideWithValue(const _SignedIn(_luigi))],
    );
    tester.view.physicalSize = const Size(844, 390);
    tester.view.viewInsets = const FakeViewPadding(bottom: 160);
    await tester.pumpAndSettle();

    for (final mode in [i18n.local1v1, i18n.online1v1]) {
      await robot.chooseMode(mode);
      expect(tester.takeException(), isNull, reason: mode);
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
    }
  });

  testWidgets('the app opened on the address of a board, like a reloaded web page, shows the home screen', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/game';
    addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);

    await _HomeRobot(tester).launch(localRepository: games);

    expect(find.text(i18n.local1v1), findsOneWidget);
  });

  testWidgets('choosing to play online without Firebase says it is unavailable, without asking for a name', (
    tester,
  ) async {
    final robot = _HomeRobot(tester);
    await robot.launch(localRepository: games);

    await robot.chooseMode(i18n.online1v1);

    robot.expectSnackBar(i18n.onlineUnavailable);
    expect(find.text(i18n.onlineGame), findsNothing);
  });

  testWidgets('a local game set up in the dialog opens on its board, ready to play', (tester) async {
    final robot = _HomeRobot(tester);
    await robot.launch(localRepository: games);

    await robot.chooseMode(i18n.local1v1);
    await robot.enterNames(['Jessy', 'Mario']);
    await robot.tapText(i18n.start);

    expect(find.text('Jessy (X)'), findsOneWidget);
    expect(find.text('Mario (O)'), findsOneWidget);
    expect(find.text(i18n.turnOf('Jessy (X)')), findsOneWidget);
  });

  testWidgets('leaving the board of a local game forgets the game', (tester) async {
    final robot = _HomeRobot(tester);
    final recorded = PendingLocalGameRepository(games)..created.complete();
    await robot.launch(localRepository: recorded);
    await robot.chooseMode(i18n.local1v1);
    await robot.enterNames(['Jessy', 'Mario']);
    await robot.tapText(i18n.start);

    await robot.goBack();

    expect(find.text(i18n.local1v1), findsOneWidget);
    // The game streams run on real time: the test clock would never deliver a game that is still there.
    await tester.runAsync(
      () => expectLater(games.watchGame(recorded.createdGames.single).first, throwsA(isA<GameNotFoundException>())),
    );
  });

  group('Leaving an online game', () {
    late FakeFirebaseFirestore firestore;
    late FirestoreGameRepository opponent;
    late _HomeRobot robot;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      opponent = FirestoreGameRepository(firestore: firestore);
    });

    /// The host's board, in the real app, once the game is created and the opponent sat down if [joined].
    Future<GameId> openBoard(WidgetTester tester, {required bool joined}) async {
      robot = _HomeRobot(tester);
      await robot.launch(
        localRepository: games,
        online: [
          onlineGameRepositoryProvider.overrideWithValue(FirestoreGameRepository(firestore: firestore)),
          playerIdentityProvider.overrideWithValue(const _SignedIn(_jessy)),
        ],
      );
      final gameId = await robot.createOnlineGame(hostName: 'Jessy');
      if (joined) {
        await opponent.joinGame(gameId, guest: _luigi, guestName: 'Luigi');
        await tester.pumpAndSettle();
      }
      return gameId;
    }

    /// The game as the opponent's device sees it; the fake database answers in real time.
    Future<Game?> seenByOpponent(WidgetTester tester, GameId gameId) =>
        tester.runAsync(() => opponent.watchGame(gameId).first.timeout(const Duration(seconds: 1)));

    testWidgets('with an opponent asks first, and staying keeps the game going', (tester) async {
      final gameId = await openBoard(tester, joined: true);

      await robot.goBack();
      expect(find.text(i18n.leaveGameTitle), findsOneWidget);
      await robot.tapText(i18n.stay);

      expect(find.text('Luigi (O)'), findsOneWidget);
      expect((await seenByOpponent(tester, gameId))?.status, GameStatus.setup);
    });

    testWidgets('with an opponent, once confirmed, ends it for them', (tester) async {
      final gameId = await openBoard(tester, joined: true);

      await robot.goBack();
      await robot.tapText(i18n.leave);

      expect(find.text(i18n.local1v1), findsOneWidget);
      expect((await seenByOpponent(tester, gameId))?.status, GameStatus.abandoned);
    });

    testWidgets('nobody joined yet needs no confirmation, and nobody can join it any more', (tester) async {
      final gameId = await openBoard(tester, joined: false);

      await robot.goBack();

      expect(find.text(i18n.leaveGameTitle), findsNothing);
      expect(find.text(i18n.local1v1), findsOneWidget);
      expect((await seenByOpponent(tester, gameId))?.status, GameStatus.abandoned);
    });
  });

  testWidgets('the modes stay covered while the game is being created', (tester) async {
    final robot = _HomeRobot(tester);
    final pending = PendingLocalGameRepository(games);
    await robot.launch(localRepository: pending);

    await robot.chooseMode(i18n.soloVsAi);
    await robot.enterNames(['Jessy']);
    await tester.tap(find.text(i18n.start));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.bySemanticsLabel(i18n.loading), findsOneWidget);
    await tester.tap(find.text(i18n.soloVsAi), warnIfMissed: false);
    expect(pending.creations, 1);

    pending.created.complete();
    await tester.pumpAndSettle();
    expect(find.text('Jessy (X)'), findsOneWidget);
  });

  testWidgets('a name the server would refuse is refused in the form, before anything is created', (tester) async {
    final robot = _HomeRobot(tester);
    await robot.launch(localRepository: games);
    await robot.chooseMode(i18n.local1v1);

    // Six flags are six characters on screen, but 24 UTF-16 code units for the server.
    await robot.enterNames(['🇫🇷🇫🇷🇫🇷🇫🇷🇫🇷🇫🇷', 'Mario']);
    await robot.tapText(i18n.start);

    expect(find.text(i18n.nameTooLong(PlayerName.maxLength)), findsOneWidget);
    expect(find.text('Mario (O)'), findsNothing);
  });

  testWidgets('joining a game that already has two players says so and stays on the home screen', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final server = FirestoreGameRepository(firestore: firestore);
    final gameId = await server.createGame(host: const PlayerId('jessy-uid'), hostName: 'Jessy');
    await server.joinGame(gameId, guest: const PlayerId('wario-uid'), guestName: 'Wario');
    final robot = _HomeRobot(tester);
    await robot.launch(
      localRepository: games,
      online: [
        onlineGameRepositoryProvider.overrideWithValue(server),
        playerIdentityProvider.overrideWithValue(const _SignedIn(_luigi)),
      ],
    );

    // Codes are case-insensitive for the player.
    await robot.joinOnlineGame(GameId(gameId.value.toLowerCase()), guestName: 'Luigi');

    robot.expectSnackBar(i18n.gameAlreadyFull);
    expect(find.text(i18n.local1v1), findsOneWidget);
  });
}

/// Test DSL for the home screen, driven through the real app and its router.
class _HomeRobot {
  const _HomeRobot(this.tester);

  final WidgetTester tester;

  Future<void> launch({required LocalGameRepositoryInterface localRepository, List<Override> online = const []}) async {
    tester.view.physicalSize = GoldenScreen.iphone11.size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isOnlineAvailableProvider.overrideWithValue(online.isNotEmpty),
          localGameRepositoryProvider.overrideWithValue(localRepository),
          ...online,
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> chooseMode(String title) => tapText(title);

  Future<void> enterNames(List<String> names) async {
    final labels = [i18n.playerOneFirstName, i18n.playerTwoFirstName];
    for (final (index, name) in names.indexed) {
      await tester.enterText(find.widgetWithText(TextFormField, labels[index]), name);
    }
    await tester.pumpAndSettle();
  }

  /// Creates a game from the app, and reads its code where the board shows it to share.
  Future<GameId> createOnlineGame({required String hostName}) async {
    await chooseMode(i18n.online1v1);
    await tester.enterText(find.widgetWithText(TextFormField, i18n.playerFirstName), hostName);
    await tapText(i18n.createGame);

    final codeLabel = i18n.gameCodeValue('');
    return GameId(tester.widget<Text>(find.textContaining(codeLabel)).data?.substring(codeLabel.length) ?? '');
  }

  Future<void> goBack() async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  Future<void> joinOnlineGame(GameId gameId, {required String guestName}) async {
    await chooseMode(i18n.online1v1);
    await tapText(i18n.join);
    await tester.enterText(find.widgetWithText(TextFormField, i18n.playerFirstName), guestName);
    await tester.enterText(find.widgetWithText(TextFormField, i18n.gameCode), gameId.value);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, i18n.join));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(String text) async {
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  void expectSnackBar(String message) =>
      expect(find.descendant(of: find.byType(SnackBar), matching: find.text(message)), findsOneWidget);
}

final class _SignedIn implements PlayerIdentity {
  const _SignedIn(this._player);

  final PlayerId _player;

  @override
  Future<PlayerId> signIn() async => _player;
}
