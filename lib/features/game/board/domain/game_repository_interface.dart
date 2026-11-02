import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';

/// Playing a game, whatever stores it. Writes take a game id rather than a [Game]: implementations validate against
/// their own current state, never against a possibly stale copy held by the caller.
abstract interface class GameRepositoryInterface {
  Stream<Game> watchGame(GameId gameId);

  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required int row, required int col});

  Future<void> startNewRound({required GameId gameId});

  Future<void> startGame({required GameId gameId});
}

/// Games played on this device, both players sharing the screen.
abstract interface class LocalGameRepositoryInterface implements GameRepositoryInterface {
  Future<GameId> createGame({required String guestName, required String hostName, required bool vsAi});

  /// Forgets a game once nobody plays it anymore.
  void endGame(GameId gameId);
}

/// Games played between two devices, joined with the game id.
abstract interface class OnlineGameRepositoryInterface implements GameRepositoryInterface {
  Future<void> createGame(GameId gameId, {required PlayerId host, required String hostName});

  Future<void> joinGame(GameId gameId, {required PlayerId guest, required String guestName});
}
