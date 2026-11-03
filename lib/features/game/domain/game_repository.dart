import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

/// Playing a game, whatever stores it. Writes take a game id rather than a [Game]: implementations validate against
/// their own current state, never against a possibly stale copy held by the caller.
abstract interface class GameRepository {
  Stream<Game> watchGame(GameId gameId);

  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell});

  Future<void> startNewRound({required GameId gameId});

  /// Leaves the game for good: a local game is forgotten, the opponent of an online one sees it abandoned.
  Future<void> leaveGame(GameId gameId);
}

/// Games played on this device, both players sharing the screen: they start as soon as they are created.
abstract interface class LocalGameRepository implements GameRepository {
  Future<GameId> createGame({required String guestName, required String hostName});
}

/// Games played between two devices, joined with the game id: a short code the host shares. The game starts once the
/// guest sat down and a player starts it.
abstract interface class OnlineGameRepository implements GameRepository {
  Future<GameId> createGame({required PlayerId host, required String hostName});

  Future<void> joinGame(GameId gameId, {required PlayerId guest, required String guestName});

  Future<void> startGame({required GameId gameId});
}
