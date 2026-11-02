import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

/// Every change a game can go through, local or online: the repositories only store what these return, and
/// `firestore.rules` check the same rules on the server. A refusal throws the [GameException] that says why; a null
/// result means the change already happened, both players being able to ask for it at once.
final class GameRules {
  const GameRules();

  /// The game once [guest] took the free seat, or null when [guest] already plays it.
  Game? join(Game game, {required PlayerId guest, required String guestName}) {
    if (game.status == GameStatus.abandoned) throw GameAbandonedException();
    if (guest == game.hostId || guest == game.guestId) return null;
    if (game.guestId != null) throw GameAlreadyFullException();

    return game.copyWith(guestId: guest, guestName: guestName);
  }

  /// The game once started, or null when it already is.
  Game? start(Game game) {
    if (game.status != GameStatus.setup) return null;
    if (game.guestId == null) throw MoveOpponentMissingException();

    return game.copyWith(status: GameStatus.playing);
  }

  Game applyMove({required Game game, required PlayerId playerId, required Cell cell}) {
    if (game.status == GameStatus.abandoned) throw GameAbandonedException();
    if (game.status == GameStatus.finished) throw MoveGameFinishedException();
    if (game.status == GameStatus.setup) throw MoveGameNotStartedException();

    final guestId = game.guestId;
    if (guestId == null) throw MoveOpponentMissingException();
    if (game.currentPlayerId != playerId) throw MoveNotYourTurnException();
    if (!cell.isOnBoard) throw MoveCellIndexInvalidException();
    if (game.board[cell] != null) throw MoveCellAlreadyTakenException();

    final mark = game.markOf(playerId);
    final board = game.board.play(cell, mark);
    final played = game.copyWith(board: board);
    final hasLine = board.hasLine(mark);

    if (!hasLine && !board.isFull) {
      return played.copyWith(currentPlayerId: playerId == game.hostId ? guestId : game.hostId);
    }

    return played.copyWith(
      status: GameStatus.finished,
      currentWinnerId: hasLine ? playerId : null,
      hostWinCount: game.hostWinCount + (hasLine && playerId == game.hostId ? 1 : 0),
      guestWinCount: game.guestWinCount + (hasLine && playerId == guestId ? 1 : 0),
    );
  }

  /// The next round, on an empty board, the players taking turns to start; null while the round is being played.
  Game? startNewRound(Game game) {
    if (game.status != GameStatus.finished) return null;

    final guestId = game.guestId;
    if (guestId == null) return null;

    final nextRoundIndex = game.currentRoundIndex + 1;
    return game.copyWith(
      board: Board.empty,
      currentPlayerId: nextRoundIndex.isEven ? game.hostId : guestId,
      currentRoundIndex: nextRoundIndex,
      currentWinnerId: null,
      status: GameStatus.playing,
    );
  }

  /// The game once a player left it: the other one can no longer play it.
  Game? leave(Game game) {
    if (game.status == GameStatus.abandoned) return null;

    return game.copyWith(status: GameStatus.abandoned);
  }
}
