import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/features/game/board/data/dto/commands.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/main.dart' as app;
import 'package:tic_tac_toe_app/shared/firebase/firebase_environment.dart';
import 'package:uuid/uuid.dart';

/// Runs the real app on a device. The online scenarios need the emulators (see README):
/// `flutter test integration_test --dart-define-from-file=firebase_emulator.json`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final online = FirebaseEnvironment.usesEmulators;

  group('Local game', () {
    testWidgets('two players play a round, then the loser starts the next one', (tester) async {
      final robot = _AppRobot(tester);
      await robot.launch();

      await robot.chooseMode(I18n.current.local1v1);
      await robot.enterNames(['Jessy', 'Mario']);
      await robot.tapText(I18n.current.start);
      await robot.tapText(I18n.current.startGame);

      await robot.play([0, 3, 1, 4, 2]);
      await robot.waitFor(find.text(I18n.current.playerWins('Jessy (X)')));

      await robot.tapText(I18n.current.playAgain);
      await robot.waitFor(find.text(I18n.current.turnOf('Mario (O)')));
    });

    testWidgets('the AI answers the player', (tester) async {
      final robot = _AppRobot(tester);
      await robot.launch();

      await robot.chooseMode(I18n.current.soloVsAi);
      await robot.enterNames(['Jessy']);
      await robot.tapText(I18n.current.start);
      await robot.tapText(I18n.current.startGame);

      await robot.play([0]);
      await robot.waitFor(find.text('O'));
      await robot.waitFor(find.text(I18n.current.turnOf('Jessy (X)')));
    });
  });

  group('Online game', () {
    late _Device opponent;
    late _Device cheater;
    late _Device latecomer;

    setUpAll(() async {
      if (!online) return;

      // Secondary apps need the default one, which the app under test initializes the same way.
      await FirebaseEnvironment.initialize(FirebaseEnvironment.emulatorOptions);
      opponent = await _Device.signIn('opponent');
      cheater = await _Device.signIn('cheater');
      latecomer = await _Device.signIn('latecomer');
    });

    testWidgets('the host plays a full round against another device', (tester) async {
      final robot = _AppRobot(tester);
      await robot.launch();

      final gameId = await robot.createOnlineGame(hostName: 'Jessy');
      await robot.waitFor(find.text(I18n.current.waitingForOpponent));

      await opponent.repository.joinGame(gameId, guest: opponent.id, guestName: 'Luigi');
      await robot.waitFor(find.text('Luigi (O)'));
      await robot.tapText(I18n.current.startGame);
      await robot.waitFor(find.text(I18n.current.yourTurn));

      for (final (mine, theirs) in [(0, 3), (1, 4)]) {
        await robot.play([mine]);
        await robot.waitFor(find.text(I18n.current.turnOf('Luigi (O)')));
        await opponent.repository.makeMove(gameId: gameId, playerId: opponent.id, row: theirs ~/ 3, col: theirs % 3);
        await robot.waitFor(find.text(I18n.current.yourTurn));
      }
      await robot.play([2]);

      await robot.waitFor(find.text(I18n.current.playerWins('Jessy (X)')));
    }, skip: !online);

    testWidgets('joining a game that does not exist stays on the home screen and says so', (tester) async {
      final robot = _AppRobot(tester);
      await robot.launch();

      await robot.joinOnlineGame(const GameId('no-such-game'), guestName: 'Luigi');

      await robot.waitFor(find.text(I18n.current.gameNotFound));
      expect(find.text(I18n.current.local1v1), findsOneWidget);
    }, skip: !online);

    testWidgets('joining a game that already has two players stays on the home screen and says so', (tester) async {
      final gameId = GameId(const Uuid().v4());
      await opponent.repository.createGame(gameId, host: opponent.id, hostName: 'Luigi');
      await cheater.repository.joinGame(gameId, guest: cheater.id, guestName: 'Wario');
      final robot = _AppRobot(tester);
      await robot.launch();

      await robot.joinOnlineGame(gameId, guestName: 'Jessy');

      await robot.waitFor(find.text(I18n.current.gameAlreadyFull));
    }, skip: !online);

    test('both players pressing the same button at once start the game, then the next round, once each', () async {
      final gameId = GameId(const Uuid().v4());
      await opponent.repository.createGame(gameId, host: opponent.id, hostName: 'Luigi');
      await cheater.repository.joinGame(gameId, guest: cheater.id, guestName: 'Wario');

      await Future.wait([opponent.repository.startGame(gameId: gameId), cheater.repository.startGame(gameId: gameId)]);
      for (final (turn, cell) in [0, 3, 1, 4, 2].indexed) {
        final device = turn.isEven ? opponent : cheater;
        await device.repository.makeMove(gameId: gameId, playerId: device.id, row: cell ~/ 3, col: cell % 3);
      }
      await Future.wait([
        opponent.repository.startNewRound(gameId: gameId),
        cheater.repository.startNewRound(gameId: gameId),
      ]);

      final game = (await opponent.gameRef(gameId).get()).data();
      expect((game?['currentRoundIndex'], game?['status'], game?['fromWinCount']), (1, 'playing', 1));
    }, skip: !online);

    test('two players joining at once: one takes the seat, the other is told the game is full', () async {
      final gameId = GameId(const Uuid().v4());
      await opponent.repository.createGame(gameId, host: opponent.id, hostName: 'Luigi');

      Future<Object?> join(_Device device, String name) => device.repository
          .joinGame(gameId, guest: device.id, guestName: name)
          .then<Object?>((_) => device.id, onError: (Object error) => error);
      final outcomes = await Future.wait([join(cheater, 'Wario'), join(latecomer, 'Waluigi')]);

      final seated = (await opponent.gameRef(gameId).get()).data()?['toId'];
      expect(outcomes.where((outcome) => outcome is PlayerId && outcome.value == seated), hasLength(1));
      expect(outcomes.whereType<GameAlreadyFullException>(), hasLength(1));
    }, skip: !online);

    group('The security rules refuse', () {
      late GameId gameId;

      setUp(() async {
        if (!online) return;

        gameId = GameId(const Uuid().v4());
        await opponent.repository.createGame(gameId, host: opponent.id, hostName: 'Luigi');
      });

      Future<void> expectDenied(Future<void> write) =>
          expectLater(write, throwsA(isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied')));

      test('listing the games, which would reveal their codes', () async {
        await expectDenied(cheater.firestore.collection('games').get());
      }, skip: !online);

      test('taking the seat of a player who already joined', () async {
        await cheater.repository.joinGame(gameId, guest: cheater.id, guestName: 'Wario');

        await expectDenied(opponent.gameRef(gameId).update({'toId': opponent.id.value, 'toName': 'Luigi'}));
      }, skip: !online);

      test('a move out of turn, a fake victory and an inflated score', () async {
        await cheater.repository.joinGame(gameId, guest: cheater.id, guestName: 'Wario');
        await opponent.repository.startGame(gameId: gameId);

        // The guest (O) writes a move while the host (X) is to play.
        await expectDenied(cheater.writeMove(gameId, index: 4, mark: 'O', turn: 0, board: _boardAfter([(4, -1)])));

        // The host claims a win on its first move.
        await expectDenied(
          opponent.writeMove(
            gameId,
            index: 0,
            mark: 'X',
            turn: 0,
            board: _boardAfter([(0, 1)]),
            outcome: {'status': 'finished', 'currentWinnerId': opponent.id.value, 'fromWinCount': 1},
          ),
        );

        // The same move without the claim goes through: the refusals above come from the cheats, not the write.
        await opponent.writeMove(
          gameId,
          index: 0,
          mark: 'X',
          turn: 0,
          board: _boardAfter([(0, 1)]),
          outcome: {'currentPlayerId': cheater.id.value},
        );

        // A score edit outside any move is refused.
        await expectDenied(opponent.gameRef(gameId).update({'fromWinCount': 5}));
      }, skip: !online);

      test('a game with a field the app never writes, or that would outlive its 30 days', () async {
        final created =
            CreateGameCommand(
              expiresAt: DateTime.timestamp().add(FirestoreGameRepository.lifetime),
              host: cheater.id,
              hostName: 'Wario',
            ).toFirestore();
        final forever = Timestamp.fromDate(DateTime.timestamp().add(const Duration(days: 3650)));

        await expectDenied(cheater.gameRef(GameId(const Uuid().v4())).set({...created, 'vsAi': true}));
        await expectDenied(cheater.gameRef(GameId(const Uuid().v4())).set({...created, 'expiresAt': forever}));

        // The game as the app writes it goes through: the refusals above come from the extra field and the expiry.
        await cheater.gameRef(GameId(const Uuid().v4())).set(created);
      }, skip: !online);

      test('deleting a game', () async {
        await expectDenied(opponent.gameRef(gameId).delete());
      }, skip: !online);
    });
  });
}

/// Board counters after the given (cell, sign) moves, as the rules compute them.
Map<String, Object> _boardAfter(List<(int, int)> moves) {
  final row = [0, 0, 0];
  final col = [0, 0, 0];
  var diag = 0;
  var anti = 0;
  for (final (cell, sign) in moves) {
    row[cell ~/ 3] += sign;
    col[cell % 3] += sign;
    if (cell ~/ 3 == cell % 3) diag += sign;
    if (cell ~/ 3 + cell % 3 == 2) anti += sign;
  }
  return {'anti': anti, 'col': col, 'diag': diag, 'moveCount': moves.length, 'row': row};
}

/// Another device: its own Firebase app and anonymous account, on the same emulators.
final class _Device {
  _Device._(this.firestore, this.id) : repository = FirestoreGameRepository(firestore: firestore);

  final FirebaseFirestore firestore;
  final PlayerId id;
  final FirestoreGameRepository repository;

  static Future<_Device> signIn(String name) async {
    final firebaseApp = await Firebase.initializeApp(name: name, options: FirebaseEnvironment.emulatorOptions);
    await FirebaseEnvironment.useEmulators(firebaseApp);
    final credential = await FirebaseAuth.instanceFor(app: firebaseApp).signInAnonymously();

    return _Device._(FirebaseFirestore.instanceFor(app: firebaseApp), PlayerId(credential.user?.uid ?? ''));
  }

  DocumentReference<Map<String, dynamic>> gameRef(GameId gameId) => firestore.collection('games').doc(gameId.value);

  /// Writes a move and its game update together, as the app does, without the app's checks.
  Future<void> writeMove(
    GameId gameId, {
    required int index,
    required String mark,
    required int turn,
    required Map<String, Object> board,
    Map<String, Object?> outcome = const {},
  }) async {
    final game = await gameRef(gameId).get();
    final batch = firestore.batch();
    batch.set(gameRef(gameId).collection('moves').doc('0:$index'), {
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': game.data()?['expiresAt'],
      'index': index,
      'mark': mark,
      'playerId': id.value,
      'round': 0,
      'turn': turn,
    });
    batch.update(gameRef(gameId), {'boardState': board, 'lastMoveIndex': index, ...outcome});
    return batch.commit();
  }
}

class _AppRobot {
  _AppRobot(this.tester);

  final WidgetTester tester;

  Future<void> launch() async {
    await tester.pumpWidget(UncontrolledProviderScope(container: await app.createAppContainer(), child: const App()));
    await tester.pumpAndSettle();
  }

  Future<void> chooseMode(String title) => tapText(title);

  Future<void> enterNames(List<String> names) async {
    for (final (index, name) in names.indexed) {
      await tester.enterText(find.byType(TextFormField).at(index), name);
    }
    await tester.pumpAndSettle();
  }

  Future<GameId> createOnlineGame({required String hostName}) async {
    await chooseMode(I18n.current.online1v1);
    await tester.enterText(find.byType(TextFormField).first, hostName);
    final gameId = GameId(tester.widget<TextFormField>(find.byType(TextFormField).last).controller?.text ?? '');
    await tapText(I18n.current.createGame);
    return gameId;
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

  Future<void> play(List<int> cells) async {
    for (final cell in cells) {
      await waitFor(find.byKey(Key('cell_$cell')));
      await tester.tap(find.byKey(Key('cell_$cell')));
      await tester.pumpAndSettle();
    }
  }

  Future<void> tapText(String text) async {
    await waitFor(find.text(text));
    await tester.tap(find.text(text).last);
    await tester.pumpAndSettle();
  }

  /// Pumps until [finder] matches: online updates arrive from the emulators in real time.
  Future<void> waitFor(Finder finder, {Duration timeout = const Duration(seconds: 10)}) async {
    final deadline = DateTime.timestamp().add(timeout);
    while (finder.evaluate().isEmpty) {
      if (DateTime.timestamp().isAfter(deadline)) {
        throw TestFailure('Timed out waiting for $finder');
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
}
