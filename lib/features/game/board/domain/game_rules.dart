import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';

final class GameRules {
  const GameRules();

  static const boardSize = 3;

  Game? applyMove({
    required Game game,
    required String playerId,
    required int row,
    required int col,
    required DateTime currentDate,
  }) {
    if (game.status != GameStatus.playing) return null;
    if (game.currentPlayerId != playerId) return null;
    if (!isOnBoard(row: row, col: col)) return null;

    final toId = game.toId;
    if (toId == null) return null;

    final index = row * boardSize + col;
    if (game.moves.any((m) => m.index == index)) return null;

    final isFromPlayer = playerId == game.fromId;
    final (opponentId, sign) = isFromPlayer ? (toId, 1) : (game.fromId, -1);

    final nextRow = List<int>.of(game.boardState.row, growable: false);
    final nextCol = List<int>.of(game.boardState.col, growable: false);
    int nextDiag = game.boardState.diag;
    int nextAnti = game.boardState.anti;
    int nextMoveCount = game.boardState.moveCount + 1;

    nextRow[row] += sign;
    nextCol[col] += sign;
    if (row == col) nextDiag += sign; // e.g. (0,0), (1,1), (2,2)
    if ((row + col) == boardSize - 1) nextAnti += sign; // e.g. (2,0), (1,1), (0,2)

    final hasLine = [nextRow[row], nextCol[col], nextDiag, nextAnti].any((count) => count.abs() == boardSize);

    final move = Move(
      playerId: playerId,
      index: index,
      mark: game.markOf(playerId),
      round: game.currentRoundIndex,
      turn: game.boardState.moveCount,
    );

    final updated = game.copyWith(
      moves: [...game.moves, move],
      boardState: BoardState(row: nextRow, col: nextCol, diag: nextDiag, anti: nextAnti, moveCount: nextMoveCount),
      lastPlayAt: currentDate,
      updatedAt: currentDate,
    );

    if (!hasLine && nextMoveCount < boardSize * boardSize) {
      return updated.copyWith(currentPlayerId: opponentId);
    }

    return updated.copyWith(
      status: GameStatus.finished,
      currentWinnerId: hasLine ? playerId : null,
      fromWinCount: updated.fromWinCount + (hasLine && isFromPlayer ? 1 : 0),
      toWinCount: updated.toWinCount + (hasLine && !isFromPlayer ? 1 : 0),
    );
  }

  /// Resets the board for the next round; the players take turns to start.
  Game? startNewRound({required Game game, required DateTime currentDate}) {
    if (game.status != GameStatus.finished) return null;

    final toId = game.toId;
    if (toId == null) return null;

    final nextRoundIndex = game.currentRoundIndex + 1;
    return game.copyWith(
      status: GameStatus.playing,
      currentRoundIndex: nextRoundIndex,
      currentPlayerId: nextRoundIndex.isEven ? game.fromId : toId,
      currentWinnerId: null,
      moves: const [],
      boardState: const BoardState(),
      lastPlayAt: currentDate,
      updatedAt: currentDate,
    );
  }

  bool isOnBoard({required int row, required int col}) => row >= 0 && row < boardSize && col >= 0 && col < boardSize;
}
