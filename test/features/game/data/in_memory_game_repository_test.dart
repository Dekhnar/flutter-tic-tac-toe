import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

const _host = InMemoryGameRepository.hostId;
const _guest = InMemoryGameRepository.guestId;

void main() {
  late InMemoryGameRepository repository;

  setUp(() {
    repository = InMemoryGameRepository();
    addTearDown(repository.dispose);
  });

  Future<GameId> startGame() async {
    final gameId = await repository.createGame(guestName: 'Mario', hostName: 'Jessy');
    await repository.startGame(gameId: gameId);
    return gameId;
  }

  test('a new game seats the host as X, who plays first', () async {
    final gameId = await repository.createGame(guestName: 'Mario', hostName: 'Jessy');

    final game = await repository.watchGame(gameId).first;
    expect(game.status, GameStatus.setup);
    expect(game.currentPlayerId, _host);
    expect((game.nameOf(_host), game.markOf(_host)), ('Jessy', CellMark.X));
    expect((game.nameOf(_guest), game.markOf(_guest)), ('Mario', CellMark.O));
  });

  test('every game gets its own id', () async {
    final first = await repository.createGame(guestName: 'Mario', hostName: 'Jessy');
    final second = await repository.createGame(guestName: 'Luigi', hostName: 'Jessy');

    expect(first, isNot(second));
  });

  test('a move is stored and passes the turn', () async {
    final gameId = await startGame();

    await repository.makeMove(gameId: gameId, playerId: _host, cell: const Cell(0));

    final current = await repository.watchGame(gameId).first;
    expect(current.board, Board.empty.play(const Cell(0), CellMark.X));
    expect(current.currentPlayerId, _guest);
  });

  test('a new round cannot start while the current one is being played', () async {
    final gameId = await startGame();
    await repository.makeMove(gameId: gameId, playerId: _host, cell: const Cell(0));

    await repository.startNewRound(gameId: gameId);

    final current = await repository.watchGame(gameId).first;
    expect(current.currentRoundIndex, 0);
    expect(current.board[const Cell(0)], CellMark.X);
  });

  test('a move on a cell already taken is refused, as it is online', () async {
    final gameId = await startGame();
    await repository.makeMove(gameId: gameId, playerId: _host, cell: const Cell(0));

    expect(
      repository.makeMove(gameId: gameId, playerId: _guest, cell: const Cell(0)),
      throwsA(isA<MoveCellAlreadyTakenException>()),
    );
  });

  test('a game that does not exist can be neither watched nor played', () {
    const unknown = GameId('unknown');

    expect(repository.watchGame(unknown), emitsError(isA<GameNotFoundException>()));
    expect(
      repository.makeMove(gameId: unknown, playerId: _host, cell: const Cell(0)),
      throwsA(isA<GameNotFoundException>()),
    );
  });

  test('a game its players left is forgotten, and its board stops receiving updates', () async {
    final gameId = await startGame();
    final updates = repository.watchGame(gameId).toList();

    await repository.leaveGame(gameId);

    await expectLater(updates, completes);
    expect(repository.watchGame(gameId), emitsError(isA<GameNotFoundException>()));
  });

  test('closing the repository ends the games being watched', () async {
    final gameId = await startGame();
    final updates = repository.watchGame(gameId).toList();

    repository.dispose();

    await expectLater(updates, completes);
  });
}
