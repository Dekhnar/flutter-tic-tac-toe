import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/data/dto/game_document.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';

const _gameId = GameId('ABCDEF');
const _jessy = PlayerId('jessy-uid');
const _luigi = PlayerId('luigi-uid');
const _mario = PlayerId('mario-uid');

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreGameRepository host;
  late FirestoreGameRepository guest;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    host = FirestoreGameRepository(firestore: firestore);
    guest = FirestoreGameRepository(firestore: firestore);
  });

  Future<void> startedGame() async {
    await host.createGame(_gameId, host: _jessy, hostName: 'Jessy');
    await guest.joinGame(_gameId, guest: _luigi, guestName: 'Luigi');
    await host.startGame(gameId: _gameId);
  }

  Future<void> play(List<int> cells) async {
    for (final (turn, cell) in cells.indexed) {
      final (repository, player) = turn.isEven ? (host, _jessy) : (guest, _luigi);
      await repository.makeMove(gameId: _gameId, playerId: player, row: cell ~/ 3, col: cell % 3);
    }
  }

  /// The game as the players see it, once it holds [marks] marks. The fake database applies a transaction just after
  /// it completes.
  Future<Game> storedGame({int marks = 0}) => host
      .watchGame(_gameId)
      .firstWhere((game) => game.board.cells.nonNulls.length == marks)
      .timeout(const Duration(seconds: 1));

  group('Joining a game', () {
    test('seats the guest as O, by name', () async {
      await host.createGame(_gameId, host: _jessy, hostName: 'Jessy');

      await guest.joinGame(_gameId, guest: _luigi, guestName: 'Luigi');

      final game = await host
          .watchGame(_gameId)
          .firstWhere((game) => game.toId != null)
          .timeout(const Duration(seconds: 1));
      expect((game.toId, game.toName, game.markOf(_luigi)), (_luigi, 'Luigi', CellMark.O));
    });

    test('fails when nobody created a game with this code', () {
      expect(guest.joinGame(_gameId, guest: _luigi, guestName: 'Luigi'), throwsA(isA<GameNotFoundException>()));
    });

    test('fails when the game already has two players, and keeps the first opponent', () async {
      await host.createGame(_gameId, host: _jessy, hostName: 'Jessy');
      await guest.joinGame(_gameId, guest: _luigi, guestName: 'Luigi');

      await expectLater(
        FirestoreGameRepository(firestore: firestore).joinGame(_gameId, guest: _mario, guestName: 'Mario'),
        throwsA(isA<GameAlreadyFullException>()),
      );
      expect((await storedGame()).toId, _luigi);
    });

    test('again, from the same device, comes back to the same seat', () async {
      await startedGame();

      await guest.joinGame(_gameId, guest: _luigi, guestName: 'Luigi');

      expect((await storedGame()).toId, _luigi);
    });
  });

  test('creating a game with a code already in use fails', () async {
    await host.createGame(_gameId, host: _jessy, hostName: 'Jessy');

    expect(guest.createGame(_gameId, host: _mario, hostName: 'Mario'), throwsA(isA<StateError>()));
  });

  test('a game is deleted by the server thirty days after its creation', () async {
    final createdAt = DateTime.utc(2026, 11, 2, 10);
    final repository = FirestoreGameRepository(clock: Clock.fixed(createdAt), firestore: firestore);

    await repository.createGame(_gameId, host: _jessy, hostName: 'Jessy');

    final document = await firestore.collection('games').doc(_gameId.value).get();
    expect(document.data()?[GameField.expiresAt.name], Timestamp.fromDate(DateTime.utc(2026, 12, 2, 10)));
  });

  test('a game stored in a shape the app cannot read ends its stream in an error', () async {
    await host.createGame(_gameId, host: _jessy, hostName: 'Jessy');
    await Future<void>.delayed(Duration.zero);

    final reading = expectLater(host.watchGame(_gameId), emitsThrough(emitsError(isA<FormatException>())));
    await firestore.collection('games').doc(_gameId.value).update({GameField.board.name: 'X........'});

    await reading;
  });

  test('watching a game deleted from the server ends in an error', () async {
    await host.createGame(_gameId, host: _jessy, hostName: 'Jessy');
    final deletion = expectLater(host.watchGame(_gameId), emitsThrough(emitsError(isA<GameNotFoundException>())));

    await firestore.collection('games').doc(_gameId.value).delete();

    await deletion;
  });

  group('A move', () {
    test('is stored with the board and passes the turn', () async {
      await startedGame();

      await host.makeMove(gameId: _gameId, playerId: _jessy, row: 1, col: 1);

      final stored = await storedGame(marks: 1);
      final document = await firestore.collection('games').doc(_gameId.value).get();
      expect(stored.board, Board.empty.play(4, CellMark.X));
      expect(stored.currentPlayerId, _luigi);
      expect(document.data()?[GameField.board.name], ['', '', '', '', 'X', '', '', '', '']);
    });

    test('is refused when it is the opponent turn', () async {
      await startedGame();

      expect(
        guest.makeMove(gameId: _gameId, playerId: _luigi, row: 0, col: 0),
        throwsA(isA<MoveNotYourTurnException>()),
      );
    });

    test('is refused on a cell the opponent already took', () async {
      await startedGame();
      await play([0]);

      expect(
        guest.makeMove(gameId: _gameId, playerId: _luigi, row: 0, col: 0),
        throwsA(isA<MoveCellAlreadyTakenException>()),
      );
    });

    test('is refused outside the board', () async {
      await startedGame();

      expect(
        host.makeMove(gameId: _gameId, playerId: _jessy, row: 0, col: 5),
        throwsA(isA<MoveCellIndexInvalidException>()),
      );
    });

    test('that completes a line ends the round and counts the win', () async {
      await startedGame();

      await play([0, 3, 1, 4, 2]);

      final stored = await storedGame(marks: 5);
      expect(stored.status, GameStatus.finished);
      expect(stored.currentWinnerId, _jessy);
      expect((stored.fromWinCount, stored.toWinCount), (1, 0));
    });
  });

  group('Starting', () {
    test('the game twice keeps it playing', () async {
      await startedGame();

      await guest.startGame(gameId: _gameId);

      expect((await storedGame()).status, GameStatus.playing);
    });

    test('a new round while the round is being played changes nothing', () async {
      await startedGame();
      await play([0]);

      await guest.startNewRound(gameId: _gameId);

      final stored = await storedGame(marks: 1);
      expect(stored.currentRoundIndex, 0);
      expect(stored.currentPlayerId, _luigi);
    });

    test('a new round starts on an empty board, the other player first', () async {
      await startedGame();
      await play([0, 3, 1, 4, 2]);

      await guest.startNewRound(gameId: _gameId);

      final next = await host.watchGame(_gameId).firstWhere((game) => game.currentRoundIndex == 1);
      expect((next.board, next.status, next.currentPlayerId), (Board.empty, GameStatus.playing, _luigi));
    });
  });
}
