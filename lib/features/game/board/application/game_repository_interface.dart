import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';

abstract class GameRepositoryInterface {
  const GameRepositoryInterface();

  Stream<Game> watchGame(String gameId);

  Future<void> makeMove({required Game game, required String playerId, required int row, required int col});

  Future<void> startNewRound({required Game game});

  Future<void> startGame({required Game game});
}
