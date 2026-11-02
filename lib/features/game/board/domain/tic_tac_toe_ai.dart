import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';

final class TicTacToeAI {
  const TicTacToeAI();

  static const _lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  static const _preferredCells = [
    4, // center
    0, 2, 6, 8, // corners
    1, 3, 5, 7, // edges
  ];

  /// The cell index [0..8] the AI plays, or null when it is not the AI's turn.
  int? nextMove(Game game) {
    final aiId = game.toId;
    if (!game.isAiTurn || aiId == null) return null;

    final board = List<CellMark?>.filled(9, null);
    for (final move in game.moves) {
      board[move.index] = move.mark;
    }

    final aiMark = game.markOf(aiId);
    final opponentMark = game.markOf(game.fromId);

    return _cellCompletingLine(board, aiMark) ??
        _cellCompletingLine(board, opponentMark) ??
        _preferredCells.where((index) => board[index] == null).firstOrNull;
  }

  int? _cellCompletingLine(List<CellMark?> board, CellMark mark) {
    for (final line in _lines) {
      final emptyCells = line.where((index) => board[index] == null).toList();
      final markCount = line.where((index) => board[index] == mark).length;

      if (emptyCells.length == 1 && markCount == line.length - 1) return emptyCells.single;
    }
    return null;
  }
}
