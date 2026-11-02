import 'dart:async';

import 'package:tic_tac_toe_app/features/game/board/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_repository_interface.dart';

/// Local games that are created only once [created] completes, or never when it fails.
final class PendingLocalGameRepository implements LocalGameRepositoryInterface {
  PendingLocalGameRepository(this._repository);

  final InMemoryGameRepository _repository;

  final created = Completer<void>();

  int creations = 0;

  @override
  Future<GameId> createGame({required String guestName, required String hostName, required bool vsAi}) async {
    creations++;
    await created.future;
    return _repository.createGame(guestName: guestName, hostName: hostName, vsAi: vsAi);
  }

  @override
  void endGame(GameId gameId) => _repository.endGame(gameId);

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required int row, required int col}) =>
      _repository.makeMove(gameId: gameId, playerId: playerId, row: row, col: col);

  @override
  Future<void> startGame({required GameId gameId}) => _repository.startGame(gameId: gameId);

  @override
  Future<void> startNewRound({required GameId gameId}) => _repository.startNewRound(gameId: gameId);

  @override
  Stream<Game> watchGame(GameId gameId) => _repository.watchGame(gameId);
}
