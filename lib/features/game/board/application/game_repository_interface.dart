import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';

/// Writes take a game id rather than a [Game]: implementations validate against their own current state, never
/// against a possibly stale copy held by the caller.
abstract class GameRepositoryInterface {
  const GameRepositoryInterface();

  Stream<Game> watchGame(String gameId);

  Future<void> makeMove({required String gameId, required String playerId, required int row, required int col});

  Future<void> startNewRound({required String gameId});

  Future<void> startGame({required String gameId});
}
