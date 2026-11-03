// Every ProviderScope below is the root of its test tree, built through a helper the lint cannot follow.
// ignore_for_file: scoped_providers_should_specify_dependencies

import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/design_system/components/data_display/base/card.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/data/dto/game_document.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_code.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/game_board_provider.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/game_board_screen.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/widgets/game_board_grid.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/widgets/game_header.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_refused_exception.dart';

import '../../../../shared/fakes/lagging_online_game_repository.dart';
import '../../../../shared/golden_test_utils/material_golden.dart';
import '../../../../shared/tic_tac_toe_widget_test_wrapper.dart';

const _gameId = GameId('ABCDEF');
const _jessy = PlayerId('jessy-uid');
const _luigi = PlayerId('luigi-uid');
const _onlineSession = GameSession.online(gameId: _gameId, me: _jessy);

/// The board renders in French (see MaterialGolden).
final i18n = lookupI18n(const Locale('fr'));

void main() {
  group('Local game', () {
    testWidgets('two players finish a round, then the other one starts the next', (tester) async {
      final robot = _GameBoardScreenRobot(tester);

      await robot.pumpLocalGame(guestName: 'Mario', hostName: 'Jessy');

      robot.expectText('Jessy (X)');
      robot.expectText('Mario (O)');

      // X wins with the top row: 0, 3, 1, 4, 2
      for (final cell in [0, 3, 1, 4, 2]) {
        await robot.tapCell(cell);
      }

      robot.expectText(i18n.playerWins('Jessy (X)'));
      expect(find.text('1'), findsOneWidget);

      await robot.tapReplayButton();

      robot.expectMarkedCellCount(0);
      robot.expectText(i18n.turnOf('Mario (O)'));
    });

    testWidgets('the AI answers the player', (tester) async {
      final robot = _GameBoardScreenRobot(tester);

      await robot.pumpLocalGame(hostName: 'Jessy', vsAi: true);

      robot.expectText('${i18n.ai} (O)');

      await robot.tapCell(0);
      await tester.pump(const Duration(seconds: 1));

      robot.expectMarkedCellCount(2);
    });

    testWidgets('two cells tapped at once against the AI make one move: the player never plays for the AI', (
      tester,
    ) async {
      final robot = _GameBoardScreenRobot(tester);
      await robot.pumpLocalGame(hostName: 'Jessy', vsAi: true);

      await robot.tapCellsAtOnce(0, 1);
      await tester.pump();

      robot.expectCellHasMark(0, 'X');
      robot.expectCellEmpty(1);
      expect(find.byType(SnackBar), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      robot.expectMarkedCellCount(2);
      robot.expectText(i18n.turnOf('Jessy (X)'));
    });
  });

  group('Online game', () {
    testWidgets('the host shares the game code until the opponent joins', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);

      await robot.pumpOnlineGameAsHost();

      robot.expectText(i18n.waitingForOpponent);
      robot.expectText(i18n.gameCodeValue(harness.gameId.value));

      await harness.opponentJoins();
      await tester.pumpAndSettle();

      robot.expectTextNotPresent(i18n.waitingForOpponent);
      robot.expectText('Luigi (O)');
    });

    testWidgets('a player can only play on their turn', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);

      await robot.pumpStartedOnlineGame();
      robot.expectText(i18n.yourTurn);

      await robot.tapCell(0);
      await tester.pumpAndSettle();
      robot.expectCellHasMark(0, 'X');
      robot.expectText(i18n.turnOf('Luigi (O)'));

      await robot.tapCell(1);
      await tester.pumpAndSettle();
      robot.expectCellEmpty(1);

      await harness.opponent.makeMove(gameId: harness.gameId, playerId: _luigi, cell: const Cell(4));
      await tester.pumpAndSettle();
      robot.expectCellHasMark(4, 'O');

      await robot.tapCell(2);
      await tester.pumpAndSettle();
      robot.expectCellHasMark(2, 'X');
    });

    testWidgets('a move refused by the server says why', (tester) async {
      final refusals = [
        (MoveCellAlreadyTakenException(), i18n.cellAlreadyTaken),
        (MoveGameFinishedException(), i18n.roundIsOver),
        (MoveGameNotStartedException(), i18n.gameNotStartedYet),
        (MoveNotYourTurnException(), i18n.notYourTurn),
        (GameOpponentMissingException(), i18n.opponentMustJoin),
      ];

      for (final (refusal, explanation) in refusals) {
        final harness = _FirestoreTestHarness();
        final robot = _GameBoardScreenRobot(tester, harness: harness);

        await robot.pumpStartedOnlineGame();

        harness.appRepository.beforeMakeMove = () => harness.seedForRefusal(refusal);
        await robot.tapCell(0);
        await tester.pumpAndSettle();

        robot.expectText(explanation);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    });

    testWidgets('the retry message shows again when the next move fails too', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);

      await robot.pumpStartedOnlineGame();
      harness.appRepository.beforeMakeMove = () async => throw Exception('network unreachable');

      await robot.tapCell(0);
      await tester.pumpAndSettle();
      robot.expectText(i18n.pleaseRetry);

      await robot.dismissSnackbar();
      await robot.tapCell(0);
      await tester.pumpAndSettle();

      robot.expectText(i18n.pleaseRetry);
    });

    testWidgets('a move the server cannot be reached for asks to check the connection', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);

      await robot.pumpStartedOnlineGame();
      harness.appRepository.beforeMakeMove = () async => throw ServerNotAnsweringException(Exception('offline'));
      await robot.tapCell(0);
      await tester.pumpAndSettle();

      robot.expectText(i18n.serverNotAnswering);
      robot.expectCellEmpty(0);
    });

    testWidgets('a move the server refuses for no reason of the game asks to update the app', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);

      await robot.pumpStartedOnlineGame();
      harness.appRepository.beforeMakeMove = () async => throw ServerRefusedException(Exception('App Check'));
      await robot.tapCell(0);
      await tester.pumpAndSettle();

      robot.expectText(i18n.serverRefused);
      robot.expectCellEmpty(0);
    });

    testWidgets('the tapped cell shows the move is on its way until the server answers', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      await robot.pumpStartedOnlineGame();
      final serverAnswer = Completer<void>();
      harness.appRepository.beforeMakeMove = () => serverAnswer.future;
      final semantics = tester.ensureSemantics();

      await robot.tapCell(4);

      expect(robot.spinnerIn(4), findsOneWidget);
      expect(find.bySemanticsLabel(i18n.boardCellPlaying(2, 2)), findsOneWidget);

      serverAnswer.complete();
      await tester.pumpAndSettle();
      robot.expectCellHasMark(4, 'X');
      expect(find.byType(CircularProgressIndicator), findsNothing);
      semantics.dispose();
    });

    testWidgets('a move the server does not answer in time is given up, and the board takes moves again', (
      tester,
    ) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      await robot.pumpStartedOnlineGame();
      harness.appRepository.beforeMakeMove = () => Completer<void>().future;

      await robot.tapCell(0);
      await tester.pump(GameBoardActionsNotifier.timeLimit);
      await tester.pumpAndSettle();

      robot.expectText(i18n.serverNotAnswering);
      robot.expectCellEmpty(0);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      harness.appRepository.beforeMakeMove = null;
      await robot.dismissSnackbar();
      await robot.tapCell(0);
      await tester.pumpAndSettle();
      robot.expectCellHasMark(0, 'X');
    });

    testWidgets('two cells tapped at once make one move, and only its cell shows it on its way', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      await robot.pumpStartedOnlineGame();
      final serverAnswer = Completer<void>();
      harness.appRepository.beforeMakeMove = () => serverAnswer.future;

      await robot.tapCellsAtOnce(0, 1);
      await tester.pump();
      expect(robot.spinnerIn(0), findsOneWidget);
      expect(robot.spinnerIn(1), findsNothing);

      serverAnswer.complete();
      await tester.pumpAndSettle();
      robot.expectCellHasMark(0, 'X');
      robot.expectCellEmpty(1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('a move the server took stays on its way until the board gets it, and the board takes no other', (
      tester,
    ) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      await robot.pumpStartedOnlineGame();
      harness.appRepository.lag();

      await robot.tapCell(0);
      await robot.tapCell(1);
      expect(robot.spinnerIn(0), findsOneWidget);
      robot.expectCellEmpty(0);

      harness.appRepository.catchUp();
      await tester.pumpAndSettle();
      robot.expectCellHasMark(0, 'X');
      robot.expectCellEmpty(1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a winning move whose game comes back already in the next round leaves no cell on its way', (
      tester,
    ) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      await robot.pumpStartedOnlineGame();
      for (final (mine, theirs) in [(0, 3), (1, 4)]) {
        await robot.tapCell(mine);
        await tester.pumpAndSettle();
        await harness.opponent.makeMove(gameId: harness.gameId, playerId: _luigi, cell: Cell(theirs));
        await tester.pumpAndSettle();
      }
      harness.appRepository.lag();

      await robot.tapCell(2);
      expect(robot.spinnerIn(2), findsOneWidget);
      await harness.opponent.startNewRound(gameId: harness.gameId);
      await tester.pump();
      expect(robot.spinnerIn(2), findsOneWidget);
      harness.appRepository.catchUp();
      await tester.pump();

      robot.expectMarkedCellCount(0);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('starting the game takes no other action until the board shows it started', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      await robot.pumpOnlineGameAsHost();
      await harness.opponentJoins();
      await tester.pumpAndSettle();
      harness.appRepository.lag();

      await robot.tapStartGame();
      await tester.pump();
      expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, i18n.startGame)).onPressed, isNull);

      harness.appRepository.catchUp();
      await tester.pumpAndSettle();
      robot.expectText(i18n.yourTurn);
    });

    testWidgets('an opponent who has not played for a minute shows as inactive, until they play', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      await robot.pumpStartedOnlineGame();
      await robot.tapCell(0);
      await tester.pumpAndSettle();
      final inactive = i18n.opponentInactive('Luigi (O)');

      await tester.pump(OpponentInactiveNotifier.inactiveAfter - const Duration(seconds: 1));
      robot.expectTextNotPresent(inactive);
      await tester.pump(const Duration(seconds: 1));
      robot.expectText(inactive);

      await harness.opponent.makeMove(gameId: harness.gameId, playerId: _luigi, cell: const Cell(4));
      await tester.pumpAndSettle();
      robot.expectTextNotPresent(inactive);
    });

    testWidgets('the board takes no other move while the server handles one', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      await robot.pumpStartedOnlineGame();
      final serverAnswer = Completer<void>();
      harness.appRepository.beforeMakeMove = () => serverAnswer.future;

      await robot.tapCell(0);
      await robot.tapCell(1);
      serverAnswer.complete();
      await tester.pumpAndSettle();

      robot.expectCellHasMark(0, 'X');
      robot.expectCellEmpty(1);
      robot.expectText(i18n.turnOf('Luigi (O)'));
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('an opponent who leaves ends the game: the board says so and takes no more moves', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      await robot.pumpStartedOnlineGame();

      await harness.opponentLeaves();
      await tester.pumpAndSettle();
      await robot.tapCell(0);
      await tester.pumpAndSettle();

      robot.expectText(i18n.opponentLeft);
      robot.expectCellEmpty(0);
    });

    testWidgets('a game deleted while being played says so in place of the board, and only offers to leave', (
      tester,
    ) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);

      await robot.pumpStartedOnlineGame();
      await harness.deleteGame();
      await tester.pumpAndSettle();

      robot.expectText(i18n.gameNotFound);
      robot.expectText(i18n.quit);
      robot.expectTextNotPresent(i18n.retry);
    });
  });

  group('A game that cannot load', () {
    testWidgets('in time says the server is not answering, and loads on retry', (tester) async {
      final harness = _FirestoreTestHarness();
      final robot = _GameBoardScreenRobot(tester, harness: harness);
      harness.appRepository.lag();

      await robot.pumpOnlineGameAsHost();
      robot.expectText(i18n.serverNotAnswering);

      harness.appRepository.catchUp();
      await tester.tap(find.text(i18n.retry));
      await tester.pumpAndSettle();
      robot.expectText(i18n.waitingForOpponent);
    });

    testWidgets('can be loaded again', (tester) async {
      var attempts = 0;
      final robot = _GameBoardScreenRobot(tester);

      await robot.pumpWithGame(() {
        attempts++;
        return attempts == 1 ? Stream.error(Exception('offline')) : Stream.value(_buildPlayingGame());
      });
      robot.expectText(i18n.errorRetryLater);

      await tester.tap(find.text(i18n.retry));
      await tester.pumpAndSettle();

      robot.expectTextNotPresent(i18n.errorRetryLater);
      robot.expectCellHasMark(0, 'X');
    });
  });

  group('Layout', () {
    /// The host's board until an opponent joins: the header holds the game code and its copy and share buttons.
    Future<void> pumpWaitingBoard(WidgetTester tester, Size size) async {
      await tester.pumpScreen(
        ProviderScope(
          overrides: [gameProvider(_onlineSession).overrideWith((ref) => Stream.value(_buildSetupGame()))],
          child: const GameBoardScreen(session: _onlineSession),
        ),
      );
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
    }

    for (final size in const [Size(560, 520), Size(600, 560), Size(640, 600)]) {
      testWidgets(
        'a window barely wider than tall shows the whole header above the board (${size.width}×${size.height})',
        (tester) async {
          await pumpWaitingBoard(tester, size);

          expect(
            tester.getBottomLeft(find.byType(GameHeader)).dy,
            lessThanOrEqualTo(tester.getTopLeft(find.byType(GameBoardGrid)).dy),
          );
          expect(tester.getRect(find.byTooltip(i18n.share)).right, lessThanOrEqualTo(size.width));
        },
      );
    }

    testWidgets('a landscape phone shows the header beside the board', (tester) async {
      await pumpWaitingBoard(tester, const Size(844, 390));

      expect(
        tester.getTopRight(find.byType(GameHeader)).dx,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(GameBoardGrid)).dx),
      );
      expect(
        tester.getRect(find.byTooltip(i18n.share)).right,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(GameBoardGrid)).dx),
      );
    });
  });

  group('Game board goldens', () {
    screenTestGolden(
      'The board while waiting for an opponent',
      fileName: 'game_board_screen_setup',
      builder: () => _goldenBoard(() => Stream.value(_buildSetupGame())),
    );

    screenTestGolden(
      'The board during a round',
      fileName: 'game_board_screen_playing',
      builder: () => _goldenBoard(() => Stream.value(_buildPlayingGame())),
    );

    screenTestGolden(
      'The board once a player won',
      fileName: 'game_board_screen_finished',
      builder: () => _goldenBoard(() => Stream.value(_buildFinishedGame())),
    );

    screenTestGolden(
      'The board with a retry message',
      fileName: 'game_board_screen_error',
      whilePerforming: (tester) async {
        await tester.tap(find.byKey(const Key('cell_1')));
        await tester.pumpAndSettle();
        return null;
      },
      builder: () => _goldenBoard(() => Stream.value(_buildPlayingGame())),
    );

    screenTestGolden(
      'The board when the game cannot load',
      fileName: 'game_board_screen_unavailable',
      builder: () => _goldenBoard(() => Stream.error(GameNotFoundException())),
    );
  });
}

/// The board of [game], on a device that cannot reach the server: a move fails and asks to retry.
Widget _goldenBoard(Stream<Game> Function() game) => ProviderScope(
  overrides: [
    gameProvider(_onlineSession).overrideWith((ref) => game()),
    onlineGameRepositoryProvider.overrideWithValue(
      LaggingOnlineGameRepository(FirestoreGameRepository(firestore: FakeFirebaseFirestore()))
        ..beforeMakeMove = () async => throw Exception('network unreachable'),
    ),
  ],
  child: const GameBoardScreen(session: _onlineSession),
);

/// Test DSL for the board screen: scenarios read as player actions, selectors live in one place.
/// See https://www.verygood.ventures/blog/robot-testing-in-flutter.
class _GameBoardScreenRobot {
  _GameBoardScreenRobot(this.tester, {this.harness});

  final WidgetTester tester;
  final _FirestoreTestHarness? harness;

  _FirestoreTestHarness get _harness => harness ?? (throw StateError('Online scenarios need a Firestore harness'));

  final localRepository = InMemoryGameRepository();

  Future<GameSession> pumpLocalGame({String guestName = '', required String hostName, bool vsAi = false}) async {
    addTearDown(localRepository.dispose);
    final gameId = await localRepository.createGame(guestName: guestName, hostName: hostName);
    final session = GameSession.local(gameId: gameId, vsAi: vsAi);

    await tester.pumpScreen(
      ProviderScope(
        overrides: [localGameRepositoryProvider.overrideWithValue(localRepository)],
        child: GameBoardScreen(session: session),
      ),
    );
    await tester.pumpAndSettle();
    return session;
  }

  Future<void> pumpOnlineGameAsHost() async {
    _harness.gameId = await _harness.host.createGame(host: _jessy, hostName: 'Jessy');
    await tester.pumpScreen(
      ProviderScope(
        overrides: [onlineGameRepositoryProvider.overrideWithValue(_harness.appRepository)],
        child: GameBoardScreen(session: GameSession.online(gameId: _harness.gameId, me: _jessy)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpStartedOnlineGame() async {
    await pumpOnlineGameAsHost();
    await _harness.opponentJoins();
    await tester.pumpAndSettle();

    await tapStartGame();
    await tester.pumpAndSettle();
  }

  Future<void> pumpWithGame(Stream<Game> Function() game) async {
    await tester.pumpScreen(
      ProviderScope(
        overrides: [gameProvider(_onlineSession).overrideWith((ref) => game())],
        child: const GameBoardScreen(session: _onlineSession),
      ),
    );
    await tester.pumpAndSettle();
  }

  void expectText(String text) => expect(find.text(text), findsOneWidget);

  void expectTextNotPresent(String text) => expect(find.text(text), findsNothing);

  void expectCellHasMark(int index, String mark) {
    final cell = find.byKey(Key('cell_$index'));
    expect(find.descendant(of: cell, matching: find.text(mark)), findsOneWidget);
  }

  void expectCellEmpty(int index) {
    final cell = find.byKey(Key('cell_$index'));
    expect(find.descendant(of: cell, matching: find.text('X')), findsNothing);
    expect(find.descendant(of: cell, matching: find.text('O')), findsNothing);
  }

  void expectMarkedCellCount(int count) {
    final cells = find.byType(BaseCardButton);
    expect(cells, findsNWidgets(9));

    final markedCells = List.generate(9, cells.at).where((cell) {
      final mark = find.descendant(of: cell, matching: find.byWidgetPredicate((w) => w is Text && w.data != null));
      return mark.evaluate().isNotEmpty;
    });
    expect(markedCells, hasLength(count));
  }

  Finder spinnerIn(int index) =>
      find.descendant(of: find.byKey(Key('cell_$index')), matching: find.byType(CircularProgressIndicator));

  /// Two fingers land on two cells and lift before the next frame, so both taps reach the handlers of the same frame.
  Future<void> tapCellsAtOnce(int first, int second) async {
    final fingers = [
      for (final (pointer, index) in [(11, first), (12, second)])
        await tester.startGesture(tester.getCenter(find.byKey(Key('cell_$index'))), pointer: pointer),
    ];
    for (final finger in fingers) {
      await finger.up();
    }
  }

  Future<void> tapCell(int index) async {
    final cell = find.byKey(Key('cell_$index'));
    expect(cell, findsOneWidget);
    await tester.tap(cell);
    await tester.pump();
  }

  Future<void> tapStartGame() async {
    final start = find.text(i18n.startGame);
    await tester.ensureVisible(start);
    expect(start, findsOneWidget);
    await tester.tap(start);
    await tester.pump();
  }

  Future<void> tapReplayButton() async {
    final replay = find.text(i18n.playAgain);
    expect(replay, findsOneWidget);
    await tester.tap(replay);
    await tester.pumpAndSettle();
  }

  Future<void> dismissSnackbar() async {
    tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger)).hideCurrentSnackBar();
    await tester.pumpAndSettle();
  }
}

class _FirestoreTestHarness {
  final firestore = FakeFirebaseFirestore();

  /// The host's own device, creating the game before the board opens.
  late final host = FirestoreGameRepository(firestore: firestore);

  /// The other player's device, writing to the same database as the app under test.
  late final opponent = FirestoreGameRepository(firestore: firestore);

  /// The repository of the board under test.
  late final appRepository = LaggingOnlineGameRepository(FirestoreGameRepository(firestore: firestore));

  /// The game the host created.
  late GameCode gameId;

  Future<void> opponentJoins() => opponent.joinGame(gameId, guest: _luigi, guestName: 'Luigi');

  Future<void> opponentLeaves() => opponent.leaveGame(gameId);

  Future<void> deleteGame() => firestore.collection('games').doc(gameId.value).delete();

  /// Puts the stored game in the state the server would refuse a move for.
  Future<void> seedForRefusal(GameException refusal) async {
    final gameRef = firestore.collection('games').doc(gameId.value);

    switch (refusal) {
      case MoveGameFinishedException():
        await gameRef.update({GameField.status.name: GameStatus.finished.name});
      case MoveGameNotStartedException():
        await gameRef.update({GameField.status.name: GameStatus.setup.name});
      case GameOpponentMissingException():
        await gameRef.update({GameField.guestId.name: null});
      case MoveNotYourTurnException():
        await gameRef.update({GameField.currentPlayerId.name: _luigi.value});
      case MoveCellAlreadyTakenException():
        await gameRef.update({
          GameField.board.name: [CellMark.O.name, '', '', '', '', '', '', '', ''],
        });
      default:
        throw UnsupportedError('No seed for $refusal');
    }
  }
}

const _jessyHosting = Player(id: _jessy, name: 'Jessy');
const _luigiJoined = Player(id: _luigi, name: 'Luigi');

Game _buildSetupGame() =>
    const Game(currentPlayerId: _jessy, host: _jessyHosting, id: _gameId, status: GameStatus.setup);

Game _buildPlayingGame() => Game(
  board: _board(x: [0], o: [4]),
  currentPlayerId: _jessy,
  guest: _luigiJoined,
  host: _jessyHosting,
  id: _gameId,
  status: GameStatus.playing,
);

Game _buildFinishedGame() => Game(
  board: _board(x: [0, 1, 2], o: [3, 4]),
  currentPlayerId: _jessy,
  currentWinnerId: _jessy,
  guest: _luigiJoined,
  host: _jessyHosting.copyWith(wins: 1),
  id: _gameId,
  status: GameStatus.finished,
);

Board _board({required List<int> x, required List<int> o}) => [
  for (final cell in x) (Cell(cell), CellMark.X),
  for (final cell in o) (Cell(cell), CellMark.O),
].fold(Board.empty, (board, move) => board.play(move.$1, move.$2));
