// Every ProviderScope below is the root of its test tree.
// ignore_for_file: scoped_providers_should_specify_dependencies

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_providers.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/player_identity.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

import '../../../../shared/fakes/pending_local_game_repository.dart';
import '../../../../shared/golden_test_utils/devices.dart';

const _gameId = GameId('ABCDEF');
const _luigi = PlayerId('luigi-uid');

void main() {
  late InMemoryGameRepository games;

  setUp(() {
    games = InMemoryGameRepository();
    addTearDown(games.dispose);
  });

  testWidgets('the app opened on the address of a board, like a reloaded web page, shows the home screen', (
    tester,
  ) async {
    tester.binding.platformDispatcher.defaultRouteNameTestValue = '/game';
    addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);

    await _HomeRobot(tester).launch(localRepository: games);

    expect(find.text(I18n.current.local1v1), findsOneWidget);
  });

  testWidgets('choosing to play online without Firebase says it is unavailable, without asking for a name', (
    tester,
  ) async {
    final robot = _HomeRobot(tester);
    await robot.launch(localRepository: games);

    await robot.chooseMode(I18n.current.online1v1);

    robot.expectSnackBar(I18n.current.onlineUnavailable);
    expect(find.text(I18n.current.onlineGame), findsNothing);
  });

  testWidgets('a local game set up in the dialog opens on its board', (tester) async {
    final robot = _HomeRobot(tester);
    await robot.launch(localRepository: games);

    await robot.chooseMode(I18n.current.local1v1);
    await robot.enterNames(['Jessy', 'Mario']);
    await robot.tapText(I18n.current.start);

    expect(find.text('Jessy (X)'), findsOneWidget);
    expect(find.text('Mario (O)'), findsOneWidget);
    expect(find.text(I18n.current.startGame), findsOneWidget);
  });

  testWidgets('leaving the board of a local game forgets the game', (tester) async {
    final robot = _HomeRobot(tester);
    final recorded = PendingLocalGameRepository(games)..created.complete();
    await robot.launch(localRepository: recorded);
    await robot.chooseMode(I18n.current.local1v1);
    await robot.enterNames(['Jessy', 'Mario']);
    await robot.tapText(I18n.current.start);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text(I18n.current.local1v1), findsOneWidget);
    // The game streams run on real time: the test clock would never deliver a game that is still there.
    await tester.runAsync(
      () => expectLater(games.watchGame(recorded.createdGames.single).first, throwsA(isA<GameNotFoundException>())),
    );
  });

  testWidgets('the modes stay covered while the game is being created', (tester) async {
    final robot = _HomeRobot(tester);
    final pending = PendingLocalGameRepository(games);
    await robot.launch(localRepository: pending);

    await robot.chooseMode(I18n.current.soloVsAi);
    await robot.enterNames(['Jessy']);
    await tester.tap(find.text(I18n.current.start));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.bySemanticsLabel(I18n.current.loading), findsOneWidget);
    await tester.tap(find.text(I18n.current.soloVsAi), warnIfMissed: false);
    expect(pending.creations, 1);

    pending.created.complete();
    await tester.pumpAndSettle();
    expect(find.text('Jessy (X)'), findsOneWidget);
  });

  testWidgets('joining a game that already has two players says so and stays on the home screen', (tester) async {
    final firestore = FakeFirebaseFirestore();
    final server = FirestoreGameRepository(firestore: firestore);
    await server.createGame(_gameId, host: const PlayerId('jessy-uid'), hostName: 'Jessy');
    await server.joinGame(_gameId, guest: const PlayerId('wario-uid'), guestName: 'Wario');
    final robot = _HomeRobot(tester);
    await robot.launch(
      localRepository: games,
      online: [
        onlineGameRepositoryProvider.overrideWithValue(server),
        playerIdentityProvider.overrideWithValue(const _SignedIn(_luigi)),
      ],
    );

    await robot.joinOnlineGame(_gameId, guestName: 'Luigi');

    robot.expectSnackBar(I18n.current.gameAlreadyFull);
    expect(find.text(I18n.current.local1v1), findsOneWidget);
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
    for (final (index, name) in names.indexed) {
      await tester.enterText(find.byType(TextFormField).at(index), name);
    }
    await tester.pumpAndSettle();
  }

  Future<void> joinOnlineGame(GameId gameId, {required String guestName}) async {
    await chooseMode(I18n.current.online1v1);
    await tapText(I18n.current.join);
    await tester.enterText(find.byType(TextFormField).first, guestName);
    await tester.enterText(find.byType(TextFormField).last, gameId.value);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, I18n.current.join));
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
