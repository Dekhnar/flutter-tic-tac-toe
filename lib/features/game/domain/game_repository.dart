import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_code.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

/// Playing a game, wherever it is stored. Writes take a game id rather than a [Game], so that implementations check
/// them against the game as they store it, never against a stale copy.
abstract interface class GameRepository {
  Stream<Game> watchGame(GameId gameId);

  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell});

  Future<void> startNewRound({required GameId gameId});

  /// A local game is forgotten; the opponent of an online one sees it abandoned.
  Future<void> leaveGame(GameId gameId);
}

/// Games two players share one device for: they start as soon as they are created.
abstract interface class LocalGameRepository implements GameRepository {
  Future<GameId> createGame({required String guestName, required String hostName});
}

/// Games between two devices: the guest joins with the code the host shares, then a player starts the game.
abstract interface class OnlineGameRepository implements GameRepository {
  Future<GameCode> createGame({required PlayerId host, required String hostName});

  Future<void> joinGame(GameCode code, {required PlayerId guest, required String guestName});

  Future<void> startGame({required GameId gameId});
}
