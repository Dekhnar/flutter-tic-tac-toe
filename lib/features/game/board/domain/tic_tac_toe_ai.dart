import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';

final class TicTacToeAI {
  late String _playerMark; // 'X' ou 'O' (IA)
  late String _opponentMark; // 'O' ou 'X' (adversaire)

  TicTacToeAI();

  int? playIfNeeded(Game currentGame) {
    if (currentGame.status != GameStatus.playing) return null;

    final nextPlayerId = currentGame.currentPlayerId;
    if (!nextPlayerId.endsWith('Ai')) return null;

    _playerMark = nextPlayerId.startsWith('${CellMark.X.name}:') ? 'X' : 'O';
    _opponentMark = (_playerMark == 'X') ? 'O' : 'X';

    final boardGrid = ((final Game currentGame) {
      const int boardSize = 3;
      final boardGrid = List.generate(boardSize, (_) => List.filled(boardSize, ''), growable: false);

      for (final move in currentGame.moves) {
        final rowIndex = move.index ~/ boardSize;
        final columnIndex = move.index % boardSize;
        boardGrid[rowIndex][columnIndex] = move.mark.name;
      }
      return boardGrid;
    })(currentGame);

    return _selectBestIndex(boardGrid);
  }

  /// Sélectionne l’index [0..8] du meilleur coup pour la grille 3x3.
  int _selectBestIndex(List<List<String>> boardGrid) {
    const int boardSize = 3;

    // 1) Gagner tout de suite ou bloquer l’adversaire
    final ({int rowIndex, int columnIndex})? immediate = _findImmediateMove(boardGrid, boardSize);
    if (immediate != null) {
      return immediate.rowIndex * boardSize + immediate.columnIndex;
    }

    // 2) Prendre le centre si libre
    if (boardGrid[1][1].isEmpty) return 4;

    // 3) Corners puis arêtes
    for (final (int rowIndex, int columnIndex) in const [
      (0, 0), (0, 2), (2, 0), (2, 2), // coins
      (0, 1), (1, 0), (1, 2), (2, 1), // arêtes
    ]) {
      if (boardGrid[rowIndex][columnIndex].isEmpty) {
        return rowIndex * boardSize + columnIndex;
      }
    }

    // 4) Premier emplacement libre (fallback)
    for (int rowIndex = 0; rowIndex < boardSize; rowIndex++) {
      for (int columnIndex = 0; columnIndex < boardSize; columnIndex++) {
        if (boardGrid[rowIndex][columnIndex].isEmpty) {
          return rowIndex * boardSize + columnIndex;
        }
      }
    }
    return -1; // plus de cases
  }

  ({int rowIndex, int columnIndex})? _findImmediateMove(List<List<String>> boardGrid, int boardSize) {
    // lignes et colonnes
    for (int fixed = 0; fixed < boardSize; fixed++) {
      final winRow = _findWinningOrBlockingSpot(
        boardGrid,
        startRowIndex: fixed,
        startColumnIndex: 0,
        deltaRow: 0,
        deltaColumn: 1,
        boardSize: boardSize,
      );
      if (winRow != null) return winRow;

      final winCol = _findWinningOrBlockingSpot(
        boardGrid,
        startRowIndex: 0,
        startColumnIndex: fixed,
        deltaRow: 1,
        deltaColumn: 0,
        boardSize: boardSize,
      );
      if (winCol != null) return winCol;
    }

    // diagonales
    final winDiagMain = _findWinningOrBlockingSpot(
      boardGrid,
      startRowIndex: 0,
      startColumnIndex: 0,
      deltaRow: 1,
      deltaColumn: 1,
      boardSize: boardSize,
    );
    if (winDiagMain != null) return winDiagMain;

    return _findWinningOrBlockingSpot(
      boardGrid,
      startRowIndex: 0,
      startColumnIndex: boardSize - 1,
      deltaRow: 1,
      deltaColumn: -1,
      boardSize: boardSize,
    );
  }

  ({int rowIndex, int columnIndex})? _findWinningOrBlockingSpot(
    List<List<String>> boardGrid, {
    required int startRowIndex,
    required int startColumnIndex,
    required int deltaRow,
    required int deltaColumn,
    required int boardSize,
  }) {
    int playerMarkCount = 0;
    int opponentMarkCount = 0;
    ({int rowIndex, int columnIndex})? emptySpot;

    for (int step = 0; step < boardSize; step++) {
      final int rowIndex = startRowIndex + step * deltaRow;
      final int columnIndex = startColumnIndex + step * deltaColumn;
      final String cellValue = boardGrid[rowIndex][columnIndex];

      if (cellValue == _playerMark) {
        playerMarkCount++;
      } else if (cellValue == _opponentMark) {
        opponentMarkCount++;
      } else {
        emptySpot = (rowIndex: rowIndex, columnIndex: columnIndex);
      }
    }

    if (emptySpot != null && (playerMarkCount == boardSize - 1 || opponentMarkCount == boardSize - 1)) {
      return emptySpot; // gagne ou bloque
    }
    return null;
  }
}
