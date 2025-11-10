import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';

final class GameRules {
  const GameRules();

  Game? applyMove({
    required Game game,
    required String playerId,
    required int row,
    required int col,
    required DateTime currentDate,
  }) {
    if (game.status == GameStatus.finished) return null;
    if (game.status == GameStatus.setup) return null;
    if (game.currentPlayerId != playerId) return null;

    final index = row * 3 + col;
    if (index >= 9) return null;
    if (game.moves.any((m) => m.index == index)) return null;

    final (opponentId, sign, mark) = switch (playerId == game.fromId) {
      true => (game.toId!, 1, CellMark.X),
      false => (game.fromId, -1, CellMark.O),
    };

    final nextRow = List<int>.of(game.boardState.row, growable: false);
    final nextCol = List<int>.of(game.boardState.col, growable: false);
    int nextDiag = game.boardState.diag;
    int nextAnti = game.boardState.anti;
    int nextMoveCount = game.boardState.moveCount + 1;

    nextRow[row] += sign;
    nextCol[col] += sign;
    if (row == col) nextDiag += sign;
    if ((row + col) == 2) nextAnti += sign;

    String? winnerId;
    final hasLine = nextRow[row].abs() == 3 || nextCol[col].abs() == 3 || nextDiag.abs() == 3 || nextAnti.abs() == 3;

    if (hasLine) {
      winnerId = playerId;
    } else if (nextMoveCount == 9) {
      winnerId = null;
    }

    final move = Move(
      playerId: playerId,
      index: index,
      mark: mark,
      round: game.currentRoundIndex,
      turn: game.moves.length,
    );

    Game updated = game.copyWith(
      moves: [...game.moves, move],
      boardState: BoardState(row: nextRow, col: nextCol, diag: nextDiag, anti: nextAnti, moveCount: nextMoveCount),
      lastPlayAt: currentDate,
      updatedAt: currentDate,
    );

    if (winnerId != null || nextMoveCount == 9) {
      updated = updated.copyWith(
        status: GameStatus.finished,
        currentWinnerId: winnerId,
        fromWinCount: updated.fromWinCount + ((winnerId == game.fromId) ? 1 : 0),
        toWinCount: updated.toWinCount + ((winnerId == game.toId) ? 1 : 0),
      );
    } else {
      updated = updated.copyWith(currentPlayerId: opponentId);
    }

    return updated;
  }
}
