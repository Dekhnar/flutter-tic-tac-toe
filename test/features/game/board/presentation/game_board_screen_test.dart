// Every ProviderScope below is the root of its test tree, built through a helper the lint cannot follow.
// ignore_for_file: scoped_providers_should_specify_dependencies

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/design_system/components/data_display/base/card.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_local_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/presentation/game_board_screen.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/data/in_memory_store.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_displayer.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

import '../../../../shared/golden_test_utils/material_golden.dart';
import '../../../../shared/tic_tac_toe_widget_test_wrapper.dart';

void main() {
  setUpAll(() async => I18n.load(const Locale('fr')));

  group('Local game', () {
    testWidgets('two players finish a round and start another one', (tester) async {
      final r = _GameBoardScreenRobot(tester);

      await r.pumpOffline1v1(fromLabel: 'Jessy', toLabel: 'Mario');

      r.expectPlayersHeader(fromId: 'X:Jessy', toId: 'O:Mario');
      r.expectPlayerScore(0);

      await r.tapStartGame();

      // X wins with the top row: 0, 3, 1, 4, 2
      await r.tapCell(0);
      await r.tapCell(3);
      await r.tapCell(1);
      await r.tapCell(4);
      await r.tapCell(2);

      r.expectText(I18n.current.playerXWins);
      r.expectText(I18n.current.playAgain);

      await r.tapReplayButton();
      r.expectBoardCleared();
    });

    testWidgets('a second player named "Ai" plays their own moves', (tester) async {
      final r = _GameBoardScreenRobot(tester);

      await r.pumpOffline1v1(fromLabel: 'Jessy', toLabel: 'Ai');
      await r.tapStartGame();

      await r.tapCell(0);
      await r.tapCell(8);
      await tester.pump(const Duration(seconds: 1));

      r.expectCellHasMark(8, 'O');
      r.expectCellEmpty(4);
    });

    testWidgets('the AI answers the player', (tester) async {
      final r = _GameBoardScreenRobot(tester);

      await r.pumpOfflineVsAi(fromLabel: 'Jessy');

      r.expectPlayersHeader(fromId: 'X:Jessy', toId: 'O:Ai');

      await r.tapStartGame();

      await r.tapCell(0);

      await tester.pump(const Duration(seconds: 1));

      r.expectMarkedCellCount(2);
    });
  });

  group('Online game', () {
    testWidgets('a player cannot play out of turn', (tester) async {
      final harness = _FirestoreTestHarness(shareLink: 'ABCDEF');
      final r = _GameBoardScreenRobot(tester, harness: harness);

      await r.pumpOnline(label: 'Jessy', shareLink: 'ABCDEF');

      r.expectText(I18n.current.waitingForOpponent);

      await harness.opponent.joinGame(shareLink: 'ABCDEF', joinerUid: 'O:Luigi');
      await tester.pumpAndSettle();

      r.expectTextNotPresent(I18n.current.waitingForOpponent);
      r.expectPlayersHeader(fromId: 'X:Jessy', toId: 'O:Luigi');

      await r.tapStartGame();
      await tester.pumpAndSettle();

      await r.tapCell(0);
      await tester.pumpAndSettle();
      r.expectCellHasMark(0, 'X');

      await r.tapCell(1);
      await tester.pumpAndSettle();
      r.expectCellEmpty(1);

      await harness.opponent.makeMove(gameId: await harness.gameId(), playerId: 'O:Luigi', row: 1, col: 1);
      await tester.pumpAndSettle();
      r.expectCellHasMark(4, 'O');

      await r.tapCell(2);
      await tester.pumpAndSettle();
      r.expectCellHasMark(2, 'X');
    });

    testWidgets('a move refused by the server shows the retry message', (tester) async {
      final refusals = [
        MoveCellAlreadyTakenException(),
        MoveGameFinishedException(),
        MoveGameNotStartedException(),
        MoveOpponentMissingException(),
        MoveNotYourTurnException(),
      ];

      for (final refusal in refusals) {
        final harness = _FirestoreTestHarness(shareLink: 'ABCDEF');
        final r = _GameBoardScreenRobot(tester, harness: harness);

        await r.pumpStartedOnlineGame(label: 'Jessy', opponentLabel: 'Luigi', shareLink: 'ABCDEF');

        harness.beforeMakeMove = () => harness.seedForRefusal(refusal);
        await r.tapCell(0);
        await tester.pumpAndSettle();

        r.expectRetrySnackbar();

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    });

    testWidgets('the retry message shows again when the next move fails too', (tester) async {
      final harness = _FirestoreTestHarness(shareLink: 'ABCDEF');
      final r = _GameBoardScreenRobot(tester, harness: harness);

      await r.pumpStartedOnlineGame(label: 'Jessy', opponentLabel: 'Luigi', shareLink: 'ABCDEF');
      harness.beforeMakeMove = () async => throw Exception('network unreachable');

      await r.tapCell(0);
      await tester.pumpAndSettle();
      r.expectRetrySnackbar();

      await r.dismissSnackbar();
      await r.tapCell(0);
      await tester.pumpAndSettle();

      r.expectRetrySnackbar();
    });

    testWidgets('joining a game that does not exist shows a blocking error', (tester) async {
      final harness = _FirestoreTestHarness(shareLink: 'ABCDEF');
      final r = _GameBoardScreenRobot(tester, harness: harness);

      await r.pumpOnline(label: 'Luigi', shareLink: 'ABCDEF', shouldJoinGame: true);
      await tester.pumpAndSettle();

      r.expectBlockingErrorDialog(I18n.current.gameNotFound);
    });

    testWidgets('joining a game that already has two players shows a blocking error', (tester) async {
      final harness = _FirestoreTestHarness(shareLink: 'ABCDEF');
      final r = _GameBoardScreenRobot(tester, harness: harness);

      await harness.opponent.createGame(authorUid: 'X:Peach', shareLink: 'ABCDEF');
      await harness.opponent.joinGame(shareLink: 'ABCDEF', joinerUid: 'O:Luigi');

      await r.pumpOnline(label: 'Mario', shareLink: 'ABCDEF', shouldJoinGame: true);
      await tester.pumpAndSettle();

      r.expectBlockingErrorDialog(I18n.current.gameAlreadyFull);
      expect((await harness.game()).toId, 'O:Luigi');
    });
  });

  group('Game board goldens', () {
    screenTestGolden(
      'GameBoardScreen',
      tag: 'game_board_screen_setup',
      builder: () {
        final input = GameCreateInput.createOnlineLobby(fromLabel: 'Jessy', shareLink: 'ABCDEF');
        return ProviderScope(
          overrides: [
            gameNotifierProvider(gameCreateInput: input).overrideWith(() => _FakeGameNotifier(_buildSetupGame())),
          ],
          child: GameBoardScreen(input: input),
        );
      },
    );

    screenTestGolden(
      'GameBoardScreen',
      tag: 'game_board_screen_playing',
      builder: () {
        final input = GameCreateInput.offline(fromLabel: 'Jessy', toLabel: 'Luigi');
        return ProviderScope(
          overrides: [
            gameNotifierProvider(gameCreateInput: input).overrideWith(() => _FakeGameNotifier(_buildPlayingGame())),
          ],
          child: GameBoardScreen(input: input),
        );
      },
    );

    screenTestGolden(
      'GameBoardScreen',
      tag: 'game_board_screen_finished',
      builder: () {
        final input = GameCreateInput.offline(fromLabel: 'Jessy', toLabel: 'Luigi');
        return ProviderScope(
          overrides: [
            gameNotifierProvider(gameCreateInput: input).overrideWith(() => _FakeGameNotifier(_buildFinishedGame())),
          ],
          child: GameBoardScreen(input: input),
        );
      },
    );

    screenTestGolden(
      'GameBoardScreen',
      tag: 'game_board_screen_error',
      whilePerforming: (tester) async {
        final context = tester.element(find.byType(MessageDisplayer));
        final container = ProviderScope.containerOf(context);
        container.read(messageNotifierProvider.notifier).showMessage(InfoMessage.pleaseRetry);
        await tester.pumpAndSettle();
        return null;
      },
      builder: () {
        final input = GameCreateInput.offline(fromLabel: 'Jessy', toLabel: 'Luigi');
        return ProviderScope(
          overrides: [
            gameNotifierProvider(gameCreateInput: input).overrideWith(() => _FakeGameNotifier(_buildPlayingGame())),
          ],
          child: GameBoardScreen(input: input),
        );
      },
    );

    screenTestGolden(
      'GameBoardScreen',
      tag: 'game_board_screen_error_dialog',
      builder: () {
        final input = GameCreateInput.offline(fromLabel: 'Jessy', toLabel: 'Luigi');
        return ProviderScope(
          overrides: [
            gameNotifierProvider(
              gameCreateInput: input,
            ).overrideWith(() => _FakeGameNotifier(Future.error(GameCreationDataMissingException()))),
          ],
          child: GameBoardScreen(input: input),
        );
      },
    );
  });
}

/// Test DSL for the board screen: scenarios read as player actions, selectors live in one place.
/// See https://www.verygood.ventures/blog/robot-testing-in-flutter.
class _GameBoardScreenRobot {
  const _GameBoardScreenRobot(this.tester, {this.harness});

  final WidgetTester tester;
  final _FirestoreTestHarness? harness;

  static const _aiMoveDelay = Duration.zero;

  Future<void> pumpOffline1v1({required String fromLabel, required String toLabel}) async {
    await tester.pumpScreen(
      ProviderScope(
        overrides: [
          gameLocalRepositoryProvider.overrideWithValue(
            GameLocalRepository(stores: <String, InMemoryStore<Game>>{}, aiMoveDelay: _aiMoveDelay),
          ),
        ],
        child: GameBoardScreen(input: GameCreateInput.offline(fromLabel: fromLabel, toLabel: toLabel)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpOfflineVsAi({required String fromLabel}) async {
    await tester.pumpScreen(
      ProviderScope(
        overrides: [
          gameLocalRepositoryProvider.overrideWithValue(
            GameLocalRepository(stores: <String, InMemoryStore<Game>>{}, aiMoveDelay: _aiMoveDelay),
          ),
        ],
        child: GameBoardScreen(input: GameCreateInput.offlineVsAi(fromLabel: fromLabel)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpOnline({required String label, required String shareLink, bool shouldJoinGame = false}) async {
    await tester.pumpScreen(
      ProviderScope(
        overrides: [gameRepositoryProvider.overrideWith((ref) => harness!.appRepository())],
        child: GameBoardScreen(
          input: switch (shouldJoinGame) {
            false => GameCreateInput.createOnlineLobby(fromLabel: label, shareLink: shareLink),
            true => GameCreateInput.joinOnlineLobby(toLabel: label, shareLink: shareLink),
          },
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpStartedOnlineGame({
    required String label,
    required String opponentLabel,
    required String shareLink,
  }) async {
    await pumpOnline(label: label, shareLink: shareLink);
    await harness!.opponent.joinGame(shareLink: shareLink, joinerUid: 'O:$opponentLabel');
    await tester.pumpAndSettle();

    await tapStartGame();
    await tester.pumpAndSettle();
  }

  void expectPlayersHeader({required String fromId, required String toId}) {
    expect(find.text(fromId), findsOneWidget);
    expect(find.text(toId), findsOneWidget);
  }

  void expectPlayerScore(int score) => expect(find.text('$score'), findsWidgets);

  void expectText(String text) => expect(find.text(text), findsOneWidget);

  void expectTextNotPresent(String text) => expect(find.text(text), findsNothing);

  void expectBoardCleared() => expectMarkedCellCount(0);

  void expectCellHasMark(int index, String mark) {
    final cell = find.byType(BaseCardButton).at(index);
    expect(find.descendant(of: cell, matching: find.text(mark)), findsOneWidget);
  }

  void expectCellEmpty(int index) {
    final cell = find.byType(BaseCardButton).at(index);
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

  void expectBlockingErrorDialog(String message) {
    expect(find.text(I18n.current.errorTitle), findsOneWidget);
    expect(find.text(message), findsOneWidget);
    expect(find.text(I18n.current.quit), findsOneWidget);
  }

  void expectRetrySnackbar() {
    expect(find.text(I18n.current.pleaseRetry), findsOneWidget);
  }

  Future<void> tapCell(int index) async {
    final cell = find.byKey(Key('cell_$index'));
    expect(cell, findsOneWidget);
    await tester.tap(cell);
    await tester.pump();
  }

  Future<void> tapStartGame() async {
    final start = find.text(I18n.current.startGame);
    await tester.ensureVisible(start);
    expect(start, findsOneWidget);
    await tester.tap(start);
    await tester.pump();
  }

  Future<void> tapReplayButton() async {
    final replay = find.text(I18n.current.playAgain);
    expect(replay, findsOneWidget);
    await tester.tap(replay);
    await tester.pump();
  }

  Future<void> dismissSnackbar() async {
    tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger)).hideCurrentSnackBar();
    await tester.pumpAndSettle();
  }
}

class _FirestoreTestHarness {
  _FirestoreTestHarness({required this.shareLink});

  final String shareLink;
  final firestore = FakeFirebaseFirestore();

  AsyncCallback? beforeMakeMove;

  /// The other player's device, writing to the same database as the app under test.
  late final opponent = GameRepository(firestore: firestore);

  GameRepository appRepository() =>
      GameRepository(firestore: firestore, beforeMakeMove: () async => beforeMakeMove?.call());

  Future<String> gameId() async {
    final games = await firestore.collection('games').where('shareLink', isEqualTo: shareLink).get();
    return games.docs.single.id;
  }

  Future<Game> game() async {
    final snapshot = await firestore.collection('games').doc(await gameId()).get();
    final data = snapshot.data()!;
    return Game.fromJson({
      ...data,
      'id': snapshot.id,
      'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
      'updatedAt': (data['updatedAt'] as Timestamp).toDate().toIso8601String(),
      'lastPlayAt': (data['lastPlayAt'] as Timestamp?)?.toDate().toIso8601String(),
    });
  }

  /// Puts the stored game in the state the server would refuse a move for.
  Future<void> seedForRefusal(AppException refusal) async {
    final gameRef = firestore.collection('games').doc(await gameId());
    final game = (await gameRef.get()).data()!;

    switch (refusal) {
      case MoveGameFinishedException():
        await gameRef.update({'status': GameStatus.finished.name});
      case MoveGameNotStartedException():
        await gameRef.update({'status': GameStatus.setup.name});
      case MoveOpponentMissingException():
        await gameRef.update({'toId': null});
      case MoveNotYourTurnException():
        await gameRef.update({'currentPlayerId': game['toId']});
      case MoveCellAlreadyTakenException():
        await gameRef.collection('moves').doc('0:0').set({
          'playerId': game['toId'],
          'index': 0,
          'mark': CellMark.O.name,
          'round': 0,
          'turn': 0,
        });
      default:
        throw UnsupportedError('No seed for $refusal');
    }
  }
}

class _FakeGameNotifier extends GameNotifier {
  _FakeGameNotifier(this._result);

  final FutureOr<Game> _result;

  @override
  Future<Game> build({required GameCreateInput gameCreateInput}) async => await _result;
}

Game _buildSetupGame() => Game(
  id: 'golden-setup',
  fromId: 'X:Jessy',
  toId: null,
  status: GameStatus.setup,
  shareLink: 'ABCDEF',
  moves: const [],
  boardState: const BoardState(),
  currentPlayerId: 'X:Jessy',
  fromWinCount: 0,
  toWinCount: 0,
  currentRoundIndex: 0,
  currentWinnerId: null,
  lastPlayAt: null,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

Game _buildPlayingGame() => Game(
  id: 'golden-playing',
  fromId: 'X:Jessy',
  toId: 'O:Luigi',
  status: GameStatus.playing,
  shareLink: 'ABCDEF',
  moves: [
    Move(playerId: 'X:Jessy', index: 0, mark: CellMark.X, round: 0, turn: 0),
    Move(playerId: 'O:Luigi', index: 4, mark: CellMark.O, round: 0, turn: 1),
  ],
  boardState: const BoardState(row: [1, -1, 0], col: [1, -1, 0], diag: 0, anti: -1, moveCount: 2),
  currentPlayerId: 'X:Jessy',
  fromWinCount: 0,
  toWinCount: 0,
  currentRoundIndex: 0,
  currentWinnerId: null,
  lastPlayAt: null,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);

Game _buildFinishedGame() => Game(
  id: 'golden-finished',
  fromId: 'X:Jessy',
  toId: 'O:Luigi',
  status: GameStatus.finished,
  shareLink: 'ABCDEF',
  moves: [
    Move(playerId: 'X:Jessy', index: 0, mark: CellMark.X, round: 0, turn: 0),
    Move(playerId: 'O:Luigi', index: 3, mark: CellMark.O, round: 0, turn: 1),
    Move(playerId: 'X:Jessy', index: 1, mark: CellMark.X, round: 0, turn: 2),
    Move(playerId: 'O:Luigi', index: 4, mark: CellMark.O, round: 0, turn: 3),
    Move(playerId: 'X:Jessy', index: 2, mark: CellMark.X, round: 0, turn: 4),
  ],
  boardState: const BoardState(row: [3, -2, 0], col: [0, 0, 1], diag: 0, anti: 0, moveCount: 5),
  currentPlayerId: 'O:Luigi',
  fromWinCount: 1,
  toWinCount: 0,
  currentRoundIndex: 0,
  currentWinnerId: 'X:Jessy',
  lastPlayAt: null,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);
