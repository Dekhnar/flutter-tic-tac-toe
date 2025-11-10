import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_displayer.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';
import '../../../../shared/golden_test_utils/material_golden.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tic_tac_toe_app/design_system/components/data_display/base/card.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_local_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/presentation/game_board_screen.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/data/in_memory_store.dart';

import '../../../../shared/tic_tac_toe_widget_test_wrapper.dart';

void main() {
  setUpAll(() async => I18n.load(const Locale('fr')));

  group('GameBoardScreen', () {
    testWidgets('offline 1v1 : partie gagnée puis rejouer', (tester) async {
      final r = _GameBoardScreenRobot(tester);

      await r.pumpOffline1v1(fromLabel: 'Jessy', toLabel: 'Mario');

      r.expectPlayersHeader(fromId: 'X:Jessy', toId: 'O:Mario');
      r.expectPlayerScore(0);

      await r.tapStartGame();

      // X gagne: 0,3,1,4,2
      await r.tapCell(0); // X
      await r.tapCell(3); // O
      await r.tapCell(1); // X
      await r.tapCell(4); // O
      await r.tapCell(2); // X

      r.expectText(I18n.current.playerXWins);
      r.expectText(I18n.current.playAgain);

      await r.tapReplayButton();
      r.expectBoardCleared();
    });

    testWidgets('offline vs IA : le joueur joue et l\'IA répond', (tester) async {
      final r = _GameBoardScreenRobot(tester);

      await r.pumpOfflineVsAi(fromLabel: 'Jessy');

      r.expectPlayersHeader(fromId: 'X:Jessy', toId: 'O:Ai');

      await r.tapStartGame();

      await r.tapCell(0);

      await tester.pump(const Duration(seconds: 1));

      r.expectBoardHasAtLeast(2);
    });

    testWidgets('online : le joueur ne peut pas jouer si ce n’est pas son tour', (tester) async {
      final harness = _FireStoreTestHarness.create(shareLink: 'ABCDEF');

      final r = _GameBoardScreenRobot(tester, harness: harness);

      await r.pumpOnline(label: 'Jessy', shareLink: 'ABCDEF');

      r.expectText(I18n.current.waitingForOpponent);

      harness.emitOpponentJoin('Luigi');
      await tester.pumpAndSettle();

      r.expectTextNotPresent(I18n.current.waitingForOpponent);
      r.expectPlayersHeader(fromId: 'X:Jessy', toId: 'O:Luigi');

      await r.tapStartGame();
      harness.emitStartPlaying();
      await tester.pump();

      await r.tapCell(0);
      await tester.pump();
      r.expectCellHasMark(0, 'X');

      await r.tapCell(1);
      await tester.pump();
      r.expectCellEmpty(1); // je ne peux pas jouer si c'est pas mon tour

      harness.emitRemoteMove(playerId: 'O:Luigi', index: 4);
      await tester.pumpAndSettle();
      r.expectCellHasMark(4, 'O');

      await r.tapCell(2);
      await tester.pumpAndSettle();
      r.expectCellHasMark(2, 'X');
    });

    testWidgets('online: affiche le snackbar retry en cas d\'exceptions', (tester) async {
      final exceptions = [
        MoveCellAlreadyTakenException(),
        MoveGameFinishedException(),
        MoveGameNotStartedException(),
        MoveOpponentMissingException(),
        MoveNotYourTurnException(),
        MoveGameFinishedException(),
      ];
      await exceptions.fold<Future<void>>(Future.value(), (prev, exception) {
        return prev.then((_) async {
          final harness = _FireStoreTestHarness.create(shareLink: 'ABCDEF');

          final r = _GameBoardScreenRobot(tester, harness: harness);

          await r.pumpOnline(label: 'Jessy', shareLink: 'ABCDEF');

          r.expectText(I18n.current.waitingForOpponent);

          harness.emitOpponentJoin('Luigi');
          await tester.pumpAndSettle();

          await r.tapStartGame();
          harness.emitStartPlaying();
          await tester.pump();

          harness.beforeMakeMove = () async {
            return harness.seedForException(exception: exception);
          };
          await r.tapCell(0);

          await tester.pumpAndSettle();

          r.expectRetrySnackbar();

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        });
      });
    });

    testWidgets('online : affiche le dialog d’erreur quand la partie à rejoindre est introuvable', (tester) async {
      final harness = _FireStoreTestHarness.create(shareLink: 'ABCDEF');
      final r = _GameBoardScreenRobot(tester, harness: harness);

      await r.pumpOnline(label: "Luigi", shareLink: "ABCDEF", shouldJoinGame: true);

      await tester.pumpAndSettle();

      r.expectBlockingErrorDialog();
    });
  });

  group('GameBoardScreen Golden Tests', () {
    screenTestGolden(
      'GameBoardScreen',
      tag: 'game_board_screen_setup',
      skipTapTargetSizeGuideline: true,
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
      skipTapTargetSizeGuideline: true,
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
      skipTapTargetSizeGuideline: true,
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
      skipTapTargetSizeGuideline: true,
      whenWidgetPumped: (tester) async {
        final context = tester.element(find.byType(MessageDisplayer));
        final container = ProviderScope.containerOf(context);
        container.read(messageNotifierProvider.notifier).showMessage(InfoMessage.pleaseRetry);
        await tester.pumpAndSettle();
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
      skipTapTargetSizeGuideline: true,
      whenWidgetPumped: (tester) async {
        await tester.pumpAndSettle();
      },
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

class _GameBoardScreenRobot {
  const _GameBoardScreenRobot(this.tester, {this.harness});

  final WidgetTester tester;
  final _FireStoreTestHarness? harness;

  static const _aiMoveDelay = Duration.zero;

  Future<void> pumpOffline1v1({required String fromLabel, required String toLabel}) async {
    await tester.pumpWidgetBuilder(
      ProviderScope(
        overrides: [
          gameLocalRepositoryProvider.overrideWithValue(
            GameLocalRepository(stores: <String, InMemoryStore<Game>>{}, aiMoveDelay: _aiMoveDelay),
          ),
        ],
        child: GameBoardScreen(input: GameCreateInput.offline(fromLabel: fromLabel, toLabel: toLabel)),
      ),
      wrapper: (child) => TicTacToeMaterialApp(child: child),
      surfaceSize: Device.iphone11.size,
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpOfflineVsAi({required String fromLabel}) async {
    await tester.pumpWidgetBuilder(
      ProviderScope(
        overrides: [
          gameLocalRepositoryProvider.overrideWithValue(
            GameLocalRepository(stores: <String, InMemoryStore<Game>>{}, aiMoveDelay: _aiMoveDelay),
          ),
        ],
        child: GameBoardScreen(input: GameCreateInput.offlineVsAi(fromLabel: fromLabel)),
      ),
      wrapper: (child) => TicTacToeMaterialApp(child: child),
      surfaceSize: Device.iphone11.size,
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpOnline({required String label, required String shareLink, bool shouldJoinGame = false}) async {
    await tester.pumpWidgetBuilder(
      ProviderScope(
        overrides: [
          gameRepositoryProvider.overrideWith(
            (ref) => GameRepository(
              firestore: harness!.firestore,
              beforeMakeMove: () async {
                await harness?.beforeMakeMove?.call();
              },
            ),
          ),
        ],
        child: GameBoardScreen(
          input: switch (shouldJoinGame) {
            false => GameCreateInput.createOnlineLobby(fromLabel: label, shareLink: shareLink),
            true => GameCreateInput.joinOnlineLobby(toLabel: label, shareLink: shareLink),
          },
        ),
      ),
      wrapper: (child) => TicTacToeMaterialApp(child: child),
      surfaceSize: Device.iphone11.size,
    );
    await tester.pump();
  }

  void expectPlayersHeader({required String fromId, required String toId}) {
    expect(find.text(fromId), findsOneWidget);
    expect(find.text(toId), findsOneWidget);
  }

  void expectPlayerScore(int score) => expect(find.text('$score'), findsWidgets);

  void expectText(String text) => expect(find.text(text), findsOneWidget);

  void expectTextNotPresent(String text) => expect(find.text(text), findsNothing);

  void expectBoardCleared() {
    final cells = find.byType(BaseCardButton);
    expect(cells, findsNWidgets(9));
    for (var i = 0; i < 9; i++) {
      final cell = cells.at(i);
      expect(find.descendant(of: cell, matching: find.text('X')), findsNothing);
      expect(find.descendant(of: cell, matching: find.text('O')), findsNothing);
    }
  }

  void expectCellHasMark(int index, String mark) {
    final cell = find.byType(BaseCardButton).at(index);
    expect(find.descendant(of: cell, matching: find.text(mark)), findsOneWidget);
  }

  void expectCellEmpty(int index) {
    final cell = find.byType(BaseCardButton).at(index);
    expect(find.descendant(of: cell, matching: find.text('X')), findsNothing);
    expect(find.descendant(of: cell, matching: find.text('O')), findsNothing);
  }

  void expectBoardHasAtLeast(int minMarks) {
    final cells = find.byType(BaseCardButton);
    var count = 0;
    for (var i = 0; i < 9; i++) {
      final cell = cells.at(i);
      final x = find.descendant(of: cell, matching: find.text('X'));
      final o = find.descendant(of: cell, matching: find.text('O'));
      if (x.evaluate().isNotEmpty || o.evaluate().isNotEmpty) {
        count++;
      }
    }
    expect(count >= minMarks, isTrue);
  }

  void expectBlockingErrorDialog() {
    expect(find.text(I18n.current.errorTitle), findsOneWidget);
    expect(find.text(I18n.current.errorRetryLater), findsOneWidget);
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
}

class _FireStoreTestHarness {
  final FakeFirebaseFirestore firestore;
  final String shareLink;

  String? gameId;
  AsyncCallback? beforeMakeMove;

  _FireStoreTestHarness._({required this.firestore, required this.shareLink}) {
    // on écoute les créations de parties pour récupérer l'id réel créé par le repo
    firestore.collection('games').snapshots().listen((snap) {
      if (gameId != null) return;
      if (snap.docs.isEmpty) return;

      final withShare = snap.docs.where((d) {
        final data = d.data();
        return data['shareLink'] == shareLink;
      });

      if (withShare.isNotEmpty) {
        gameId = withShare.first.id;
      } else {
        gameId = snap.docs.first.id;
      }
    });
  }

  factory _FireStoreTestHarness.create({required String shareLink}) {
    final firestore = FakeFirebaseFirestore();
    return _FireStoreTestHarness._(firestore: firestore, shareLink: shareLink);
  }

  void emitOpponentJoin(String label) {
    final id = gameId;
    if (id == null) return;
    firestore.collection('games').doc(id).update({'toId': 'O:$label', 'updatedAt': Timestamp.fromDate(DateTime.now())});
  }

  void emitStartPlaying() {
    final id = gameId;
    if (id == null) return;
    firestore.collection('games').doc(id).update({
      'status': 'playing',
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  void emitRemoteMove({required String playerId, required int index}) {
    final id = gameId;
    if (id == null) return;
    final docRef = firestore.collection('games').doc(id);

    docRef.get().then((snap) async {
      final data = snap.data();
      if (data == null) return;

      final moves = List<Map<String, dynamic>>.from((data['moves'] as List?) ?? []);
      final round = (data['currentRoundIndex'] as int?) ?? 0;
      final turn = moves.length;
      final mark = playerId.startsWith('X:') ? 'X' : 'O';

      moves.add({'playerId': playerId, 'index': index, 'mark': mark, 'round': round, 'turn': turn});

      final boardState = _recomputeBoardState(moves);
      final nextPlayerId =
          playerId.startsWith('X:')
              ? (data['toId'] as String? ?? data['fromId'] as String)
              : (data['fromId'] as String);

      // on ajoute aussi la trace dans la sous-collection moves
      await firestore.collection('games').doc(id).collection('moves').doc('move-$turn').set({
        'playerId': playerId,
        'index': index,
        'mark': mark,
        'round': round,
        'turn': turn,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      await docRef.update({
        'moves': moves,
        'boardState': boardState,
        'currentPlayerId': nextPlayerId,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  /// reconstruit un boardState minimal compatible avec ton modèle
  static Map<String, dynamic> _recomputeBoardState(List<Map<String, dynamic>> moves) {
    final rows = [0, 0, 0];
    final cols = [0, 0, 0];
    var diag = 0;
    var anti = 0;

    for (final m in moves) {
      if (m['mark'] == 'X') {
        final index = m['index'] as int;
        final r = index ~/ 3;
        final c = index % 3;
        rows[r] += 1;
        cols[c] += 1;
        if (r == c) diag += 1;
        if (r + c == 2) anti += 1;
      }
    }

    return {'row': rows, 'col': cols, 'diag': diag, 'anti': anti, 'moveCount': moves.length};
  }

  Future<void> seedForException({required AppException exception}) async {
    // on doit d’abord avoir récupéré l’id de la partie créée par l’app
    final id = gameId;
    assert(id != null, 'Aucun gameId connu dans le harness – as-tu bien pump l’écran avant ?');

    final docRef = firestore.collection('games').doc(id!);
    final snap = await docRef.get();

    // cas spécial : on veut simuler "doc manquant"
    if (exception is GameCreationDataMissingException) {
      await docRef.delete();
      return;
    }

    // on part des données existantes (créées par l’app)
    final data = Map<String, dynamic>.from(snap.data() ?? {});

    // on récupère quelques champs utiles
    final fromId = data['fromId'] as String? ?? 'X:Jessy';
    final toId = data['toId'] as String?;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    // on adapte selon le type d’erreur qu’on veut provoquer
    if (exception is MoveGameFinishedException) {
      data['status'] = GameStatus.finished.name;
    } else if (exception is MoveGameNotStartedException) {
      data['status'] = GameStatus.setup.name;
    } else if (exception is MoveOpponentMissingException) {
      data['toId'] = null;
    } else if (exception is MoveNotYourTurnException) {
      data['currentPlayerId'] = toId ?? fromId;
    }

    // on réécrit le doc avec les modifs
    await docRef.set(data, SetOptions(merge: true));

    // case déjà prise -> on ajoute la sous-collection comme le repo le fait vraiment
    if (exception is MoveCellAlreadyTakenException) {
      await docRef.collection('moves').doc('0:0').set({
        'playerId': fromId,
        'index': 0,
        'mark': 'X',
        'round': 0,
        'turn': 0,
        'createdAt': Timestamp.fromDate(createdAt),
      });
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
  boardState: const BoardState(row: [1, 0, 0], col: [1, 0, 0], diag: 1, anti: 0, moveCount: 2),
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
  boardState: const BoardState(row: [3, 0, 0], col: [1, 1, 1], diag: 1, anti: 0, moveCount: 5),
  currentPlayerId: 'O:Luigi',
  fromWinCount: 1,
  toWinCount: 0,
  currentRoundIndex: 0,
  currentWinnerId: 'X:Jessy',
  lastPlayAt: null,
  createdAt: DateTime(2025, 1, 1),
  updatedAt: DateTime(2025, 1, 1),
);


/*
## Stratégie de tests

### 1. Tests d’harness (robot + environnement de test)

Pour les écrans/pages complets, on utilise un **harness de test** : c’est un petit wrapper qui monte tout l’environnement Flutter nécessaire (MaterialApp, ProviderScope/Riverpod, thème, nav, etc.) puis injecte la page à tester.

Par-dessus ce harness, on utilise un **robot** de test. Le robot est une classe qui encapsule les actions et les expect de test pour les rendre lisibles. Au lieu d’avoir du code de test bas niveau (`find`, `tap`, `pump`, …) dans chaque test, on écrit des scénarios métier.

**But :**
- factoriser le setup des tests UI,
- décrire les scénarios en langage métier,
- éviter de dupliquer les sélecteurs.

**Exemple de ce qu’on fait dans ces tests :**
- afficher une page avec un provider mocké,
- simuler une action utilisateur (tap, saisie),
- vérifier l’affichage d’un état (loading, erreur, succès).

### 2. Tests Golden (mock du top-level / provider de la page)

### 3. Tests de widget ciblés (mock des dépendances basses, ex. Firestore)

### 4. Résumé de la stratégie

- **Tests Golden**  
  → on monte un harness  
  → on injecte la page  
  → on mocke **le top-level** (provider de la page)  
  → on pilote via un **robot**

- **Tests de widget**  
  → on monte juste le widget  
  → on mocke **la dépendance directe** (Firestore, repo)  
  → on vérifie le rendu/comportement

- **Robots**  
  → servent de DSL de test  
  → centralisent les sélecteurs  
  → rendent les tests lisibles et maintenables

### 5. Référence

L’approche “robot testing” inspirée de l’article de Very Good Ventures :  
https://www.verygood.ventures/blog/robot-testing-in-flutter
*/