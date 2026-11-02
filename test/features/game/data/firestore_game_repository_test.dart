import 'dart:math';

import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/data/dto/game_document.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';

const _jessy = PlayerId('jessy-uid');
const _luigi = PlayerId('luigi-uid');
const _mario = PlayerId('mario-uid');

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreGameRepository host;
  late FirestoreGameRepository guest;
  late GameId gameId;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    host = FirestoreGameRepository(firestore: firestore);
    guest = FirestoreGameRepository(firestore: firestore);
  });

  Future<void> startedGame() async {
    gameId = await host.createGame(host: _jessy, hostName: 'Jessy');
    await guest.joinGame(gameId, guest: _luigi, guestName: 'Luigi');
    await host.startGame(gameId: gameId);
  }

  Future<void> play(List<int> cells) async {
    for (final (turn, cell) in cells.indexed) {
      final (repository, player) = turn.isEven ? (host, _jessy) : (guest, _luigi);
      await repository.makeMove(gameId: gameId, playerId: player, cell: Cell(cell));
    }
  }

  /// Waits for the fake database to apply the transaction, which it does just after the transaction completes.
  Future<void> stored(GameId gameId) => firestore
      .collection('games')
      .doc(gameId.value)
      .snapshots()
      .firstWhere((snapshot) => snapshot.exists)
      .timeout(const Duration(seconds: 1));

  /// The game as the players see it, once it holds [marks] marks. The fake database applies a transaction just after
  /// it completes.
  Future<Game> storedGame({int marks = 0}) => host
      .watchGame(gameId)
      .firstWhere((game) => game.board.cells.nonNulls.length == marks)
      .timeout(const Duration(seconds: 1));

  group('Joining a game', () {
    test('seats the guest as O, by name', () async {
      gameId = await host.createGame(host: _jessy, hostName: 'Jessy');

      await guest.joinGame(gameId, guest: _luigi, guestName: 'Luigi');

      final game = await host
          .watchGame(gameId)
          .firstWhere((game) => game.guestId != null)
          .timeout(const Duration(seconds: 1));
      expect((game.guestId, game.guestName, game.markOf(_luigi)), (_luigi, 'Luigi', CellMark.O));
    });

    test('fails when nobody created a game with this code', () {
      expect(
        guest.joinGame(const GameId('ABCDEF'), guest: _luigi, guestName: 'Luigi'),
        throwsA(isA<GameNotFoundException>()),
      );
    });

    test('fails when the game already has two players, and keeps the first opponent', () async {
      gameId = await host.createGame(host: _jessy, hostName: 'Jessy');
      await guest.joinGame(gameId, guest: _luigi, guestName: 'Luigi');

      await expectLater(
        FirestoreGameRepository(firestore: firestore).joinGame(gameId, guest: _mario, guestName: 'Mario'),
        throwsA(isA<GameAlreadyFullException>()),
      );
      expect((await storedGame()).guestId, _luigi);
    });

    test('again, from the same device, comes back to the same seat', () async {
      await startedGame();

      await guest.joinGame(gameId, guest: _luigi, guestName: 'Luigi');

      expect((await storedGame()).guestId, _luigi);
    });
  });

  group('Leaving a game', () {
    test('shows it abandoned to the other player', () async {
      await startedGame();

      await guest.leaveGame(gameId);

      final game = await host
          .watchGame(gameId)
          .firstWhere((game) => game.status == GameStatus.abandoned)
          .timeout(const Duration(seconds: 1));
      expect(game.status, GameStatus.abandoned);
    });

    test('that nobody joined yet leaves no game to join', () async {
      gameId = await host.createGame(host: _jessy, hostName: 'Jessy');

      await host.leaveGame(gameId);

      expect(guest.joinGame(gameId, guest: _luigi, guestName: 'Luigi'), throwsA(isA<GameAbandonedException>()));
    });
  });

  test('a new game gets a short code to read out, which no other game uses', () async {
    // Both devices draw the same codes: the second one must skip the code the first one took.
    final first = await FirestoreGameRepository(
      firestore: firestore,
      random: Random(7),
    ).createGame(host: _jessy, hostName: 'Jessy');
    final second = await FirestoreGameRepository(
      firestore: firestore,
      random: Random(7),
    ).createGame(host: _mario, hostName: 'Mario');

    expect([first.value, second.value], everyElement(matches(RegExp(r'^[A-HJ-NP-Z2-9]{6}$'))));
    expect(second, isNot(first));
  });

  test('a game is deleted by the server thirty days after its creation', () async {
    final createdAt = DateTime.utc(2026, 11, 2, 10);
    final repository = FirestoreGameRepository(clock: Clock.fixed(createdAt), firestore: firestore);

    gameId = await repository.createGame(host: _jessy, hostName: 'Jessy');

    final document = await firestore.collection('games').doc(gameId.value).get();
    expect(document.data()?[GameField.expiresAt.name], Timestamp.fromDate(DateTime.utc(2026, 12, 2, 10)));
  });

  test('a game stored in a shape the app cannot read ends its stream in an error', () async {
    gameId = await host.createGame(host: _jessy, hostName: 'Jessy');
    await stored(gameId);

    final reading = expectLater(host.watchGame(gameId), emitsThrough(emitsError(isA<FormatException>())));
    await firestore.collection('games').doc(gameId.value).update({GameField.board.name: 'X........'});

    await reading;
  });

  test('watching a game deleted from the server ends in an error', () async {
    gameId = await host.createGame(host: _jessy, hostName: 'Jessy');
    final deletion = expectLater(host.watchGame(gameId), emitsThrough(emitsError(isA<GameNotFoundException>())));

    await firestore.collection('games').doc(gameId.value).delete();

    await deletion;
  });

  group('A move', () {
    test('is stored with the board and passes the turn', () async {
      await startedGame();

      await host.makeMove(gameId: gameId, playerId: _jessy, cell: const Cell(4));

      final stored = await storedGame(marks: 1);
      final document = await firestore.collection('games').doc(gameId.value).get();
      expect(stored.board, Board.empty.play(const Cell(4), CellMark.X));
      expect(stored.currentPlayerId, _luigi);
      expect(document.data()?[GameField.board.name], ['', '', '', '', 'X', '', '', '', '']);
    });

    test('is refused when it is the opponent turn', () async {
      await startedGame();

      expect(
        guest.makeMove(gameId: gameId, playerId: _luigi, cell: const Cell(0)),
        throwsA(isA<MoveNotYourTurnException>()),
      );
    });

    test('is refused on a cell the opponent already took', () async {
      await startedGame();
      await play([0]);

      expect(
        guest.makeMove(gameId: gameId, playerId: _luigi, cell: const Cell(0)),
        throwsA(isA<MoveCellAlreadyTakenException>()),
      );
    });

    test('is refused outside the board', () async {
      await startedGame();

      expect(
        host.makeMove(gameId: gameId, playerId: _jessy, cell: const Cell(9)),
        throwsA(isA<MoveCellIndexInvalidException>()),
      );
    });

    test('that completes a line ends the round and counts the win', () async {
      await startedGame();

      await play([0, 3, 1, 4, 2]);

      final stored = await storedGame(marks: 5);
      expect(stored.status, GameStatus.finished);
      expect(stored.currentWinnerId, _jessy);
      expect((stored.hostWinCount, stored.guestWinCount), (1, 0));
    });
  });

  group('Starting', () {
    test('the game twice keeps it playing', () async {
      await startedGame();

      await guest.startGame(gameId: gameId);

      expect((await storedGame()).status, GameStatus.playing);
    });

    test('a new round while the round is being played changes nothing', () async {
      await startedGame();
      await play([0]);

      await guest.startNewRound(gameId: gameId);

      final stored = await storedGame(marks: 1);
      expect(stored.currentRoundIndex, 0);
      expect(stored.currentPlayerId, _luigi);
    });

    test('a new round starts on an empty board, the other player first', () async {
      await startedGame();
      await play([0, 3, 1, 4, 2]);

      await guest.startNewRound(gameId: gameId);

      final next = await host.watchGame(gameId).firstWhere((game) => game.currentRoundIndex == 1);
      expect((next.board, next.status, next.currentPlayerId), (Board.empty, GameStatus.playing, _luigi));
    });
  });
}
