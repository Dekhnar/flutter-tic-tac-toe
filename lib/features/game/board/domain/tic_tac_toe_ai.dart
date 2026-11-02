import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';

/// Plays perfectly: minimax over the whole game tree, which tic-tac-toe keeps small, with alpha-beta pruning.
final class TicTacToeAI {
  const TicTacToeAI();

  // Explored first so that, among equally good moves, the AI keeps the classic center-corners-edges preference.
  static const _cellsByPreference = [4, 0, 2, 6, 8, 1, 3, 5, 7];

  static const _win = 100;

  /// The cell index [0..8] the AI plays, or null when it is not the AI's turn.
  int? nextMove(Game game) {
    final aiId = game.toId;
    if (!game.isAiTurn || aiId == null) return null;

    // The search plays and undoes moves on its own copy of the cells.
    final board = game.board.cells.toList();

    final aiMark = game.markOf(aiId);
    int? bestCell;
    var bestScore = -_win - 1;
    for (final cell in _cellsByPreference.where((cell) => board[cell] == null)) {
      board[cell] = aiMark;
      final score = -_negamax(board, _opponentOf(aiMark), depth: 1, alpha: -_win - 1, beta: -bestScore);
      board[cell] = null;

      if (score > bestScore) {
        bestScore = score;
        bestCell = cell;
      }
    }
    return bestCell;
  }

  /// The best outcome [mark] can force from [board], from its own point of view: a quicker win scores higher and a
  /// later loss scores less badly.
  int _negamax(List<CellMark?> board, CellMark mark, {required int depth, required int alpha, required int beta}) {
    if (_hasLine(board, _opponentOf(mark))) return -(_win - depth);
    if (!board.contains(null)) return 0;

    var best = -_win - 1;
    var lowerBound = alpha;
    for (final cell in _cellsByPreference.where((cell) => board[cell] == null)) {
      board[cell] = mark;
      final score = -_negamax(board, _opponentOf(mark), depth: depth + 1, alpha: -beta, beta: -lowerBound);
      board[cell] = null;

      if (score > best) best = score;
      if (best > lowerBound) lowerBound = best;
      if (lowerBound >= beta) break;
    }
    return best;
  }

  bool _hasLine(List<CellMark?> board, CellMark mark) =>
      Board.lines.any((line) => line.every((index) => board[index] == mark));

  CellMark _opponentOf(CellMark mark) => mark == CellMark.X ? CellMark.O : CellMark.X;
}
