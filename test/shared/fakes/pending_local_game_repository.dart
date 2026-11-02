import 'dart:async';

import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository_interface.dart';

/// Local games that are created only once [created] completes, or never when it fails.
final class PendingLocalGameRepository implements LocalGameRepositoryInterface {
  PendingLocalGameRepository(this._repository);

  final InMemoryGameRepository _repository;

  final created = Completer<void>();

  int creations = 0;

  final createdGames = <GameId>[];

  @override
  Future<GameId> createGame({required String guestName, required String hostName}) async {
    creations++;
    await created.future;
    final gameId = await _repository.createGame(guestName: guestName, hostName: hostName);
    createdGames.add(gameId);
    return gameId;
  }

  @override
  void endGame(GameId gameId) => _repository.endGame(gameId);

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell}) =>
      _repository.makeMove(gameId: gameId, playerId: playerId, cell: cell);

  @override
  Future<void> startGame({required GameId gameId}) => _repository.startGame(gameId: gameId);

  @override
  Future<void> startNewRound({required GameId gameId}) => _repository.startNewRound(gameId: gameId);

  @override
  Stream<Game> watchGame(GameId gameId) => _repository.watchGame(gameId);
}
