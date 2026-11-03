import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tic_tac_toe_app/app.dart';
import 'package:tic_tac_toe_app/composition.dart';
import 'package:tic_tac_toe_app/features/game/data/dto/game_document.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_code.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_refused_exception.dart';
import 'package:tic_tac_toe_app/shared/firebase/firebase_environment.dart';

/// Runs the real app on a device. The online scenarios need the emulators (see README):
/// `flutter test integration_test --dart-define-from-file=firebase_emulator.json`.
/// The strings in the language the device runs the app in, read once the app launched.
late I18n i18n;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final online = FirebaseEnvironment.current.usesEmulators;

  group('Local game', () {
    testWidgets('two players play a round, then the other one starts the next', (tester) async {
      final robot = _AppRobot(tester);
      await robot.launch();

      await robot.chooseMode(i18n.local1v1);
      await robot.enterNames(['Jessy', 'Mario']);
      await robot.tapText(i18n.start);

      await robot.play([0, 3, 1, 4, 2]);
      await robot.waitFor(find.text(i18n.playerWins('Jessy (X)')));

      await robot.tapText(i18n.playAgain);
      await robot.waitFor(find.text(i18n.turnOf('Mario (O)')));
    });

    testWidgets('the AI answers the player', (tester) async {
      final robot = _AppRobot(tester);
      await robot.launch();

      await robot.chooseMode(i18n.soloVsAi);
      await robot.enterNames(['Jessy']);
      await robot.tapText(i18n.start);

      await robot.play([0]);
      await robot.waitFor(find.text('O'));
      await robot.waitFor(find.text(i18n.turnOf('Jessy (X)')));
    });
  });

  group('Online game', () {
    late _Device opponent;
    late _Device cheater;
    late _Device latecomer;

    setUpAll(() async {
      if (!online) return;

      // Secondary apps need the default one, which the app under test initializes the same way.
      await FirebaseEnvironment.current.initialize(FirebaseEnvironment.emulatorOptions);
      opponent = await _Device.signIn('opponent');
      cheater = await _Device.signIn('cheater');
      latecomer = await _Device.signIn('latecomer');
    });

    testWidgets('the host plays a full round against another device', (tester) async {
      final robot = _AppRobot(tester);
      await robot.launch();

      final gameId = await robot.createOnlineGame(hostName: 'Jessy');
      await robot.waitFor(find.text(i18n.waitingForOpponent));

      await opponent.repository.joinGame(gameId, guest: opponent.id, guestName: 'Luigi');
      await robot.waitFor(find.text('Luigi (O)'));
      await robot.tapText(i18n.startGame);
      await robot.waitFor(find.text(i18n.yourTurn));

      for (final (mine, theirs) in [(0, 3), (1, 4)]) {
        await robot.play([mine]);
        await robot.waitFor(find.text(i18n.turnOf('Luigi (O)')));
        await opponent.repository.makeMove(gameId: gameId, playerId: opponent.id, cell: Cell(theirs));
        await robot.waitFor(find.text(i18n.yourTurn));
      }
      await robot.play([2]);

      await robot.waitFor(find.text(i18n.playerWins('Jessy (X)')));
    }, skip: !online);

    testWidgets('joining with a code no game uses stays on the home screen and says so', (tester) async {
      final robot = _AppRobot(tester);
      await robot.launch();

      await robot.joinOnlineGame('ZZ9ZZ9', guestName: 'Luigi');

      await robot.waitFor(find.text(i18n.gameNotFound));
      expect(find.text(i18n.local1v1), findsOneWidget);
    }, skip: !online);

    testWidgets('joining a game that already has two players stays on the home screen and says so', (tester) async {
      final gameId = await opponent.repository.createGame(host: opponent.id, hostName: 'Luigi');
      await cheater.repository.joinGame(gameId, guest: cheater.id, guestName: 'Wario');
      final robot = _AppRobot(tester);
      await robot.launch();

      await robot.joinOnlineGame(gameId.value, guestName: 'Jessy');

      await robot.waitFor(find.text(i18n.gameAlreadyFull));
    }, skip: !online);

    test('both players pressing the same button at once start the game, then the next round, once each', () async {
      final gameId = await opponent.repository.createGame(host: opponent.id, hostName: 'Luigi');
      await cheater.repository.joinGame(gameId, guest: cheater.id, guestName: 'Wario');

      await Future.wait([opponent.repository.startGame(gameId: gameId), cheater.repository.startGame(gameId: gameId)]);
      for (final (turn, cell) in [0, 3, 1, 4, 2].indexed) {
        final device = turn.isEven ? opponent : cheater;
        await device.repository.makeMove(gameId: gameId, playerId: device.id, cell: Cell(cell));
      }
      await Future.wait([
        opponent.repository.startNewRound(gameId: gameId),
        cheater.repository.startNewRound(gameId: gameId),
      ]);

      final game = (await opponent.gameRef(gameId).get()).data();
      expect((game?['currentRoundIndex'], game?['status'], game?['hostWinCount']), (1, 'playing', 1));
    }, skip: !online);

    test('two players joining at once: one takes the seat, the other is told the game is full', () async {
      final gameId = await opponent.repository.createGame(host: opponent.id, hostName: 'Luigi');

      Future<Object?> join(_Device device, String name) => device.repository
          .joinGame(gameId, guest: device.id, guestName: name)
          .then<Object?>((_) => device.id, onError: (Object error) => error);
      final outcomes = await Future.wait([join(cheater, 'Wario'), join(latecomer, 'Waluigi')]);

      final seated = (await opponent.gameRef(gameId).get()).data()?['guestId'];
      expect(outcomes.where((outcome) => outcome is PlayerId && outcome.value == seated), hasLength(1));
      expect(outcomes.whereType<GameAlreadyFullException>(), hasLength(1));
    }, skip: !online);

    group('The security rules refuse', () {
      late GameCode gameId;

      setUp(() async {
        if (!online) return;

        gameId = await opponent.repository.createGame(host: opponent.id, hostName: 'Luigi');
      });

      /// A direct write fails with Firestore's own error; the app's repository reports the same refusal as its own.
      Future<void> expectDenied(Future<void> write) => expectLater(
        write,
        throwsA(
          anyOf(
            isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied'),
            isA<ServerRefusedException>(),
          ),
        ),
      );

      test('listing the games, which would reveal their codes', () async {
        await expectDenied(cheater.firestore.collection('games').get());
      }, skip: !online);

      test('taking the seat of a player who already joined', () async {
        await cheater.repository.joinGame(gameId, guest: cheater.id, guestName: 'Wario');

        await expectDenied(opponent.gameRef(gameId).update({'guestId': opponent.id.value, 'guestName': 'Luigi'}));
      }, skip: !online);

      test('a name longer than 20 UTF-16 code units, which a few flags reach', () async {
        await expectDenied(
          cheater.repository.joinGame(gameId, guest: cheater.id, guestName: '🇫🇷🇫🇷🇫🇷🇫🇷🇫🇷🇫🇷'),
        );
      }, skip: !online);

      test('joining a game its host left, or under a blank name', () async {
        await expectDenied(cheater.repository.joinGame(gameId, guest: cheater.id, guestName: '   '));

        await opponent.repository.leaveGame(gameId);
        await expectDenied(
          cheater.gameRef(gameId).update({
            GameField.guestId.name: cheater.id.value,
            GameField.guestName.name: 'Wario',
            GameField.updatedAt.name: FieldValue.serverTimestamp(),
          }),
        );
      }, skip: !online);

      test('leaving a game one does not play, and leaving a game twice', () async {
        await expectDenied(cheater.repository.leaveGame(gameId));

        // The host leaves: the refusal above comes from the stranger, not the write.
        await opponent.repository.leaveGame(gameId);
        await expectDenied(
          opponent.gameRef(gameId).update({
            GameField.status.name: GameStatus.abandoned.name,
            GameField.updatedAt.name: FieldValue.serverTimestamp(),
          }),
        );
      }, skip: !online);

      test('a write that forges its time', () async {
        await cheater.repository.joinGame(gameId, guest: cheater.id, guestName: 'Wario');
        await opponent.repository.startGame(gameId: gameId);

        await expectDenied(
          opponent.play(gameId, _board(x: [0]), {
            GameField.currentPlayerId: cheater.id.value,
            GameField.updatedAt: 'now',
          }),
        );
        await expectDenied(
          opponent.play(gameId, _board(x: [0]), {
            GameField.currentPlayerId: cheater.id.value,
            GameField.lastPlayAt: Timestamp.fromDate(DateTime.utc(2000)),
          }),
        );

        // The same move with the server's time goes through.
        await opponent.play(gameId, _board(x: [0]), {GameField.currentPlayerId: cheater.id.value});
      }, skip: !online);

      test('a move out of turn, a fake victory, an overwritten cell and an inflated score', () async {
        await cheater.repository.joinGame(gameId, guest: cheater.id, guestName: 'Wario');
        await opponent.repository.startGame(gameId: gameId);

        // The guest (O) plays while the host (X) is to play.
        await expectDenied(cheater.play(gameId, _board(o: [4]), {GameField.currentPlayerId: opponent.id.value}));

        // The host claims a win on its first move.
        await expectDenied(
          opponent.play(gameId, _board(x: [0]), {
            GameField.status: GameStatus.finished.name,
            GameField.currentWinnerId: opponent.id.value,
            GameField.hostWinCount: 1,
          }),
        );

        // The same move without the claim goes through: the refusals above come from the cheats, not the write.
        await opponent.play(gameId, _board(x: [0]), {GameField.currentPlayerId: cheater.id.value});

        // The guest marks the host's cell instead of an empty one.
        await expectDenied(cheater.play(gameId, _board(o: [0]), {GameField.currentPlayerId: opponent.id.value}));

        // A score edit outside any move is refused.
        await expectDenied(opponent.gameRef(gameId).update({GameField.hostWinCount.name: 5}));
      }, skip: !online);

      test('a game with a field the app never writes, or that would outlive its 30 days', () async {
        final created = GameDocument.write(
          GameWrite.create,
          Game(
            currentPlayerId: cheater.id,
            host: Player(id: cheater.id, name: 'Wario'),
            id: gameId,
            status: GameStatus.setup,
          ),
          expiresAt: DateTime.timestamp().add(FirestoreGameRepository.lifetime),
        );
        final forever = Timestamp.fromDate(DateTime.timestamp().add(const Duration(days: 3650)));

        await expectDenied(cheater.gameRef(_freshGameId()).set({...created, 'vsAi': true}));
        await expectDenied(cheater.gameRef(_freshGameId()).set({...created, GameField.expiresAt.name: forever}));

        // The game as the app writes it goes through: the refusals above come from the extra field and the expiry. So
        // does the game of a device whose clock runs days ahead.
        await cheater.gameRef(_freshGameId()).set(created);
        final daysAhead = Timestamp.fromDate(DateTime.timestamp().add(const Duration(days: 33)));
        await cheater.gameRef(_freshGameId()).set({...created, GameField.expiresAt.name: daysAhead});
      }, skip: !online);

      test('deleting a game', () async {
        await expectDenied(opponent.gameRef(gameId).delete());
      }, skip: !online);
    });
  });
}

/// A game id nobody uses yet, for a cheater writing the document directly.
GameId _freshGameId() => GameId('CHEAT-${DateTime.timestamp().microsecondsSinceEpoch}');

/// A board as the rules read it, with X and O on the given cells.
List<String> _board({List<int> x = const [], List<int> o = const []}) => [
  for (var cell = 0; cell < Board.cellCount; cell++) x.contains(cell) ? 'X' : (o.contains(cell) ? 'O' : ''),
];

/// Another device: its own Firebase app and anonymous account, on the same emulators.
final class _Device {
  _Device._(this.firestore, this.id) : repository = FirestoreGameRepository(firestore: firestore);

  final FirebaseFirestore firestore;
  final PlayerId id;
  final FirestoreGameRepository repository;

  static Future<_Device> signIn(String name) async {
    final firebaseApp = await Firebase.initializeApp(name: name, options: FirebaseEnvironment.emulatorOptions);
    await FirebaseEnvironment.current.useEmulators(firebaseApp);
    final credential = await FirebaseAuth.instanceFor(app: firebaseApp).signInAnonymously();

    return _Device._(FirebaseFirestore.instanceFor(app: firebaseApp), PlayerId(credential.user?.uid ?? ''));
  }

  DocumentReference<Map<String, dynamic>> gameRef(GameId gameId) => firestore.collection('games').doc(gameId.value);

  /// Writes a move as the app would, without the app's checks: the board after it, the server's time, and what [outcome]
  /// changes in the game (or overrides).
  Future<void> play(GameId gameId, List<String> board, Map<GameField, Object?> outcome) => gameRef(gameId).update({
    GameField.board.name: board,
    GameField.lastPlayAt.name: FieldValue.serverTimestamp(),
    GameField.updatedAt.name: FieldValue.serverTimestamp(),
    for (final MapEntry(key: field, :value) in outcome.entries) field.name: value,
  });
}

class _AppRobot {
  _AppRobot(this.tester);

  final WidgetTester tester;

  Future<void> launch() async {
    final container = await createAppContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const App()));
    await tester.pumpAndSettle();
    i18n = I18n.of(tester.element(find.byType(Scaffold).first));
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
  Future<GameCode> createOnlineGame({required String hostName}) async {
    await chooseMode(i18n.online1v1);
    await tester.enterText(find.widgetWithText(TextFormField, i18n.playerFirstName), hostName);
    await tapText(i18n.createGame);

    final codeLabel = find.textContaining(i18n.gameCodeValue(''));
    await waitFor(codeLabel);
    return GameCode.parse(tester.widget<Text>(codeLabel).data ?? '');
  }

  Future<void> joinOnlineGame(String code, {required String guestName}) async {
    await chooseMode(i18n.online1v1);
    await tapText(i18n.join);
    await tester.enterText(find.widgetWithText(TextFormField, i18n.playerFirstName), guestName);
    await tester.enterText(find.widgetWithText(TextFormField, i18n.gameCode), code);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, i18n.join));
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
