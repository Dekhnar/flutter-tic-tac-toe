import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

const _shareLink = 'ABCDEF';

void main() {
  late FakeFirebaseFirestore firestore;
  late GameRepository host;
  late GameRepository guest;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    host = GameRepository(firestore: firestore);
    guest = GameRepository(firestore: firestore);
  });

  Future<Game> startedGame() async {
    final game = await host.createGame(authorUid: 'X:Jessy', shareLink: _shareLink);
    await guest.joinGame(shareLink: _shareLink, joinerUid: 'O:Luigi');
    await host.startGame(gameId: game.id);
    return game;
  }

  /// The game as the players see it, once the moves of the current round are loaded.
  Future<Game> storedGame(String gameId, {int moveCount = 0}) =>
      host.watchGame(gameId).firstWhere((game) => game.moves.length == moveCount).timeout(const Duration(seconds: 1));

  group('Joining a game', () {
    test('fails when nobody created a game with this link', () {
      expect(guest.joinGame(shareLink: _shareLink, joinerUid: 'O:Luigi'), throwsA(isA<GameNotFoundException>()));
    });

    test('fails when the game already has two players, and keeps the first opponent', () async {
      final game = await host.createGame(authorUid: 'X:Jessy', shareLink: _shareLink);
      await guest.joinGame(shareLink: _shareLink, joinerUid: 'O:Luigi');

      await expectLater(
        GameRepository(firestore: firestore).joinGame(shareLink: _shareLink, joinerUid: 'O:Mario'),
        throwsA(isA<GameAlreadyFullException>()),
      );
      expect((await storedGame(game.id)).toId, 'O:Luigi');
    });
  });

  group('A move', () {
    test('is stored with the board and passes the turn', () async {
      final game = await startedGame();

      await host.makeMove(gameId: game.id, playerId: 'X:Jessy', row: 1, col: 1);

      final stored = await storedGame(game.id, moveCount: 1);
      expect(stored.moves.single, Move(playerId: 'X:Jessy', index: 4, mark: CellMark.X, round: 0, turn: 0));
      expect(stored.boardState, const BoardState(row: [0, 1, 0], col: [0, 1, 0], diag: 1, anti: 1, moveCount: 1));
      expect(stored.currentPlayerId, 'O:Luigi');
    });

    test('is refused when it is the opponent turn', () async {
      final game = await startedGame();

      expect(
        guest.makeMove(gameId: game.id, playerId: 'O:Luigi', row: 0, col: 0),
        throwsA(isA<MoveNotYourTurnException>()),
      );
    });

    test('is refused on a cell the opponent already took', () async {
      final game = await startedGame();
      await host.makeMove(gameId: game.id, playerId: 'X:Jessy', row: 0, col: 0);

      expect(
        guest.makeMove(gameId: game.id, playerId: 'O:Luigi', row: 0, col: 0),
        throwsA(isA<MoveCellAlreadyTakenException>()),
      );
    });

    test('is refused outside the board', () async {
      final game = await startedGame();

      expect(
        host.makeMove(gameId: game.id, playerId: 'X:Jessy', row: 0, col: 5),
        throwsA(isA<MoveCellIndexInvalidException>()),
      );
    });

    test('that completes a line ends the round and counts the win', () async {
      final game = await startedGame();
      for (final (playerId, cell) in [('X:Jessy', 0), ('O:Luigi', 3), ('X:Jessy', 1), ('O:Luigi', 4), ('X:Jessy', 2)]) {
        final repository = playerId == 'X:Jessy' ? host : guest;
        await repository.makeMove(gameId: game.id, playerId: playerId, row: cell ~/ 3, col: cell % 3);
      }

      final stored = await storedGame(game.id, moveCount: 5);
      expect(stored.status, GameStatus.finished);
      expect(stored.currentWinnerId, 'X:Jessy');
      expect((stored.fromWinCount, stored.toWinCount), (1, 0));
    });
  });

  group('Starting', () {
    test('the game twice keeps it playing', () async {
      final game = await startedGame();

      await guest.startGame(gameId: game.id);

      expect((await storedGame(game.id)).status, GameStatus.playing);
    });

    test('a new round while the round is being played changes nothing', () async {
      final game = await startedGame();
      await host.makeMove(gameId: game.id, playerId: 'X:Jessy', row: 0, col: 0);

      await guest.startNewRound(gameId: game.id);

      final stored = await storedGame(game.id, moveCount: 1);
      expect(stored.currentRoundIndex, 0);
      expect(stored.currentPlayerId, 'O:Luigi');
    });
  });
}
