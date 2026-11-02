import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

const _gameId = GameId('ABCDEF');
const _jessy = PlayerId('jessy-uid');
const _luigi = PlayerId('luigi-uid');
const _mario = PlayerId('mario-uid');

void main() {
  late FakeFirebaseFirestore firestore;
  late GameRepository host;
  late GameRepository guest;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    host = GameRepository(firestore: firestore);
    guest = GameRepository(firestore: firestore);
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

  /// The game as the players see it, once the moves of the current round are loaded.
  Future<Game> storedGame({int moveCount = 0}) =>
      host.watchGame(_gameId).firstWhere((game) => game.moves.length == moveCount).timeout(const Duration(seconds: 1));

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
        GameRepository(firestore: firestore).joinGame(_gameId, guest: _mario, guestName: 'Mario'),
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

      final stored = await storedGame(moveCount: 1);
      expect(stored.moves.single, const Move(index: 4, mark: CellMark.X, playerId: _jessy, round: 0, turn: 0));
      expect(stored.boardState, const BoardState(anti: 1, col: [0, 1, 0], diag: 1, moveCount: 1, row: [0, 1, 0]));
      expect(stored.currentPlayerId, _luigi);
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

      final stored = await storedGame(moveCount: 5);
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

      final stored = await storedGame(moveCount: 1);
      expect(stored.currentRoundIndex, 0);
      expect(stored.currentPlayerId, _luigi);
    });

    test('a new round never shows the moves of the previous one', () async {
      await startedGame();
      final updates = <Game>[];
      final subscription = host.watchGame(_gameId).listen(updates.add);
      await play([0, 3, 1, 4, 2]);

      await guest.startNewRound(gameId: _gameId);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await subscription.cancel();

      expect(updates.last.currentRoundIndex, 1);
      expect(updates.where((game) => game.moves.length != game.boardState.moveCount), isEmpty);
      expect(updates.where((game) => game.moves.any((move) => move.round != game.currentRoundIndex)), isEmpty);
    });
  });
}
