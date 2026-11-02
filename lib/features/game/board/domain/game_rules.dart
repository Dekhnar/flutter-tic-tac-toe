import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';

/// Every change a game can go through, local or online: the repositories only store what these return, and
/// `firestore.rules` check the same rules on the server. A refusal throws the [GameException] that says why.
final class GameRules {
  const GameRules();

  /// The game once [guest] took the free seat, or null when [guest] already plays it.
  Game? join(Game game, {required PlayerId guest, required String guestName}) {
    if (guest == game.fromId || guest == game.toId) return null;
    if (game.toId != null) throw GameAlreadyFullException();

    return game.copyWith(toId: guest, toName: guestName);
  }

  /// The game once started, or null when it already is: both players may ask at once.
  Game? start(Game game) {
    if (game.status != GameStatus.setup) return null;
    if (game.toId == null) throw MoveOpponentMissingException();

    return game.copyWith(status: GameStatus.playing);
  }

  Game applyMove({required Game game, required PlayerId playerId, required int row, required int col}) {
    if (game.status == GameStatus.finished) throw MoveGameFinishedException();
    if (game.status == GameStatus.setup) throw MoveGameNotStartedException();

    final toId = game.toId;
    if (toId == null) throw MoveOpponentMissingException();
    if (game.currentPlayerId != playerId) throw MoveNotYourTurnException();
    if (!_isOnBoard(row: row, col: col)) throw MoveCellIndexInvalidException();

    final cell = row * Board.size + col;
    if (game.board[cell] != null) throw MoveCellAlreadyTakenException();

    final mark = game.markOf(playerId);
    final board = game.board.play(cell, mark);
    final played = game.copyWith(board: board);
    final hasLine = board.hasLine(mark);

    if (!hasLine && !board.isFull) {
      return played.copyWith(currentPlayerId: playerId == game.fromId ? toId : game.fromId);
    }

    return played.copyWith(
      status: GameStatus.finished,
      currentWinnerId: hasLine ? playerId : null,
      fromWinCount: game.fromWinCount + (hasLine && playerId == game.fromId ? 1 : 0),
      toWinCount: game.toWinCount + (hasLine && playerId == toId ? 1 : 0),
    );
  }

  /// The next round, on an empty board, the players taking turns to start; null while the round is being played,
  /// since both players may ask at once.
  Game? startNewRound(Game game) {
    if (game.status != GameStatus.finished) return null;

    final toId = game.toId;
    if (toId == null) return null;

    final nextRoundIndex = game.currentRoundIndex + 1;
    return game.copyWith(
      board: Board.empty,
      currentPlayerId: nextRoundIndex.isEven ? game.fromId : toId,
      currentRoundIndex: nextRoundIndex,
      currentWinnerId: null,
      status: GameStatus.playing,
    );
  }

  bool _isOnBoard({required int row, required int col}) => row >= 0 && row < Board.size && col >= 0 && col < Board.size;
}
