import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_local_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/shared/data/in_memory_store.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

void main() {
  late GameLocalRepository repository;

  setUp(() {
    repository = GameLocalRepository(stores: <String, InMemoryStore<Game>>{}, aiMoveDelay: Duration.zero);
  });

  tearDown(() => repository.dispose());

  Future<Game> startGame({required String toId, bool vsAi = false}) async {
    final game = await repository.createGame(fromId: 'X:Jessy', toId: toId, vsAi: vsAi);
    await repository.startGame(gameId: game.id);
    return game;
  }

  test('the AI answers the player move', () async {
    final game = await startGame(toId: 'O:Ai', vsAi: true);

    await repository.makeMove(gameId: game.id, playerId: 'X:Jessy', row: 0, col: 0);

    final answered = await repository.watchGame(game.id).firstWhere((game) => game.moves.length == 2);
    expect(answered.moves.last.playerId, 'O:Ai');
    expect(answered.currentPlayerId, 'X:Jessy');
  });

  test('a human opponent named "Ai" is not played by the AI', () async {
    final game = await startGame(toId: 'O:Ai');

    await repository.makeMove(gameId: game.id, playerId: 'X:Jessy', row: 0, col: 0);
    await Future<void>.delayed(Duration.zero);

    final current = await repository.watchGame(game.id).first;
    expect(current.moves, hasLength(1));
    expect(current.currentPlayerId, 'O:Ai');
  });

  test('a new round cannot start while the current one is being played', () async {
    final game = await startGame(toId: 'O:Mario');
    await repository.makeMove(gameId: game.id, playerId: 'X:Jessy', row: 0, col: 0);

    await repository.startNewRound(gameId: game.id);

    final current = await repository.watchGame(game.id).first;
    expect(current.currentRoundIndex, 0);
    expect(current.moves, hasLength(1));
  });

  test('a move on a cell already taken is refused, as it is online', () async {
    final game = await startGame(toId: 'O:Mario');
    await repository.makeMove(gameId: game.id, playerId: 'X:Jessy', row: 0, col: 0);

    expect(
      repository.makeMove(gameId: game.id, playerId: 'O:Mario', row: 0, col: 0),
      throwsA(isA<MoveCellAlreadyTakenException>()),
    );
  });

  test('a game that does not exist can be neither watched nor played', () {
    expect(repository.watchGame('unknown'), emitsError(isA<GameNotFoundException>()));
    expect(
      repository.makeMove(gameId: 'unknown', playerId: 'X:Jessy', row: 0, col: 0),
      throwsA(isA<GameNotFoundException>()),
    );
  });

  test('the AI stops playing once the games are closed', () async {
    final game = await startGame(toId: 'O:Ai', vsAi: true);
    final updates = repository.watchGame(game.id).toList();

    await repository.makeMove(gameId: game.id, playerId: 'X:Jessy', row: 0, col: 0);
    repository.dispose();
    await Future<void>.delayed(Duration.zero);

    expect((await updates).last.moves, hasLength(1));
  });

  test('closing the repository ends the games being watched', () async {
    final game = await startGame(toId: 'O:Mario');
    final updates = repository.watchGame(game.id).toList();

    repository.dispose();

    await expectLater(updates, completes);
  });
}
