import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

/// Playing a game, whatever stores it. Writes take a game id rather than a [Game]: implementations validate against
/// their own current state, never against a possibly stale copy held by the caller.
abstract interface class GameRepositoryInterface {
  Stream<Game> watchGame(GameId gameId);

  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell});

  Future<void> startNewRound({required GameId gameId});

  Future<void> startGame({required GameId gameId});
}

/// Games played on this device, both players sharing the screen.
abstract interface class LocalGameRepositoryInterface implements GameRepositoryInterface {
  Future<GameId> createGame({required String guestName, required String hostName});

  /// Forgets a game once nobody plays it any more.
  void endGame(GameId gameId);
}

/// Games played between two devices, joined with the game id: a short code the host shares.
abstract interface class OnlineGameRepositoryInterface implements GameRepositoryInterface {
  Future<GameId> createGame({required PlayerId host, required String hostName});

  Future<void> joinGame(GameId gameId, {required PlayerId guest, required String guestName});

  /// Leaves the game for good: the opponent sees it abandoned.
  Future<void> leaveGame(GameId gameId);
}
