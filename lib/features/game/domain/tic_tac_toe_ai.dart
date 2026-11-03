import 'package:tic_tac_toe_app/features/game/domain/game.dart';

/// Plays perfectly: minimax over the whole game tree, which tic-tac-toe keeps small, with alpha-beta pruning.
final class TicTacToeAI {
  const TicTacToeAI();

  // Explored first so that, among equally good moves, the AI keeps the classic center-corners-edges preference.
  static const _cellsByPreference = [4, 0, 2, 6, 8, 1, 3, 5, 7];

  static const _win = 100;

  /// The best cell for [mark] on [board], or null when the round is over.
  Cell? nextMove(Board board, {required CellMark mark}) {
    if (board.isFull || CellMark.values.any(board.hasLine)) return null;

    // The search plays and undoes moves on its own copy of the cells.
    final cells = board.cells.toList();
    int? bestCell;
    var bestScore = -_win - 1;
    for (final cell in _cellsByPreference.where((cell) => cells[cell] == null)) {
      cells[cell] = mark;
      final score = -_negamax(cells, _opponentOf(mark), depth: 1, alpha: -_win - 1, beta: -bestScore);
      cells[cell] = null;

      if (score > bestScore) {
        bestScore = score;
        bestCell = cell;
      }
    }
    return switch (bestCell) {
      final index? => Cell(index),
      null => null,
    };
  }

  /// The best outcome [mark] can force from [cells], from its own point of view: a quicker win scores higher and a
  /// later loss scores less badly.
  int _negamax(List<CellMark?> cells, CellMark mark, {required int depth, required int alpha, required int beta}) {
    if (_hasLine(cells, _opponentOf(mark))) return -(_win - depth);
    if (!cells.contains(null)) return 0;

    var best = -_win - 1;
    var lowerBound = alpha;
    for (final cell in _cellsByPreference.where((cell) => cells[cell] == null)) {
      cells[cell] = mark;
      final score = -_negamax(cells, _opponentOf(mark), depth: depth + 1, alpha: -beta, beta: -lowerBound);
      cells[cell] = null;

      if (score > best) best = score;
      if (best > lowerBound) lowerBound = best;
      if (lowerBound >= beta) break;
    }
    return best;
  }

  bool _hasLine(List<CellMark?> cells, CellMark mark) =>
      Board.lines.any((line) => line.every((cell) => cells[cell.index] == mark));

  CellMark _opponentOf(CellMark mark) => mark == CellMark.X ? CellMark.O : CellMark.X;
}
