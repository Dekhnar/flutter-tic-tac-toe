import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_local_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/shared/data/in_memory_store.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

const _host = GameLocalRepository.hostId;
const _guest = GameLocalRepository.guestId;

void main() {
  late GameLocalRepository repository;

  setUp(() {
    repository = GameLocalRepository(stores: <GameId, InMemoryStore<Game>>{}, aiMoveDelay: Duration.zero);
  });

  tearDown(() => repository.dispose());

  Future<GameId> startGame({bool vsAi = false}) async {
    final gameId = await repository.createGame(guestName: vsAi ? '' : 'Mario', hostName: 'Jessy', vsAi: vsAi);
    await repository.startGame(gameId: gameId);
    return gameId;
  }

  test('a new game seats the host as X, who plays first', () async {
    final gameId = await repository.createGame(guestName: 'Mario', hostName: 'Jessy', vsAi: false);

    final game = await repository.watchGame(gameId).first;
    expect(game.status, GameStatus.setup);
    expect(game.currentPlayerId, _host);
    expect((game.nameOf(_host), game.markOf(_host)), ('Jessy', CellMark.X));
    expect((game.nameOf(_guest), game.markOf(_guest)), ('Mario', CellMark.O));
  });

  test('the AI answers the player move', () async {
    final gameId = await startGame(vsAi: true);

    await repository.makeMove(gameId: gameId, playerId: _host, row: 0, col: 0);

    final answered = await repository.watchGame(gameId).firstWhere((game) => game.moves.length == 2);
    expect(answered.moves.last.playerId, _guest);
    expect(answered.currentPlayerId, _host);
  });

  test('a local guest is never played by the AI', () async {
    final gameId = await startGame();

    await repository.makeMove(gameId: gameId, playerId: _host, row: 0, col: 0);
    await Future<void>.delayed(Duration.zero);

    final current = await repository.watchGame(gameId).first;
    expect(current.moves, hasLength(1));
    expect(current.currentPlayerId, _guest);
  });

  test('a new round cannot start while the current one is being played', () async {
    final gameId = await startGame();
    await repository.makeMove(gameId: gameId, playerId: _host, row: 0, col: 0);

    await repository.startNewRound(gameId: gameId);

    final current = await repository.watchGame(gameId).first;
    expect(current.currentRoundIndex, 0);
    expect(current.moves, hasLength(1));
  });

  test('a move on a cell already taken is refused, as it is online', () async {
    final gameId = await startGame();
    await repository.makeMove(gameId: gameId, playerId: _host, row: 0, col: 0);

    expect(
      repository.makeMove(gameId: gameId, playerId: _guest, row: 0, col: 0),
      throwsA(isA<MoveCellAlreadyTakenException>()),
    );
  });

  test('a game that does not exist can be neither watched nor played', () {
    const unknown = GameId('unknown');

    expect(repository.watchGame(unknown), emitsError(isA<GameNotFoundException>()));
    expect(
      repository.makeMove(gameId: unknown, playerId: _host, row: 0, col: 0),
      throwsA(isA<GameNotFoundException>()),
    );
  });

  test('the AI stops playing once the games are closed', () async {
    final gameId = await startGame(vsAi: true);
    final updates = repository.watchGame(gameId).toList();

    await repository.makeMove(gameId: gameId, playerId: _host, row: 0, col: 0);
    repository.dispose();
    await Future<void>.delayed(Duration.zero);

    expect((await updates).last.moves, hasLength(1));
  });

  test('closing the repository ends the games being watched', () async {
    final gameId = await startGame();
    final updates = repository.watchGame(gameId).toList();

    repository.dispose();

    await expectLater(updates, completes);
  });
}
