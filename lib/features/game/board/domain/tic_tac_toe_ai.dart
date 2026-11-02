import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';

final class TicTacToeAI {
  const TicTacToeAI();

  static const _rows = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
  ];
  static const _columns = [
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
  ];
  static const _diagonals = [
    [0, 4, 8],
    [2, 4, 6],
  ];
  static const _lines = [..._rows, ..._columns, ..._diagonals];

  static const _center = 4;
  static const _corners = [0, 2, 6, 8];
  static const _edges = [1, 3, 5, 7];
  static const _preferredCells = [_center, ..._corners, ..._edges];

  /// The cell index [0..8] the AI plays, or null when it is not the AI's turn.
  int? nextMove(Game game) {
    final aiId = game.toId;
    if (!game.isAiTurn || aiId == null) return null;

    final board = List<CellMark?>.filled(GameRules.boardSize * GameRules.boardSize, null);
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
