import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

part 'game.freezed.dart';

enum CellMark { O, X }

/// A game is abandoned once a player left it: nobody plays it any more.
enum GameStatus { setup, playing, finished, abandoned }

@freezed
final class Game with _$Game {
  const Game({
    this.board = Board.empty,
    required this.currentPlayerId,
    this.currentRoundIndex = 0,
    this.currentWinnerId,
    this.guestId,
    this.guestName,
    this.guestWinCount = 0,
    required this.hostId,
    required this.hostName,
    this.hostWinCount = 0,
    required this.id,
    required this.status,
  });

  /// The board of the current round.
  @override
  final Board board;

  @override
  final PlayerId currentPlayerId;

  @override
  final int currentRoundIndex;

  @override
  final PlayerId? currentWinnerId;

  /// The player who joined, and plays O; null until someone joins.
  @override
  final PlayerId? guestId;

  @override
  final String? guestName;

  @override
  final int guestWinCount;

  /// The player who created the game, and plays X.
  @override
  final PlayerId hostId;

  @override
  final String hostName;

  @override
  final int hostWinCount;

  @override
  final GameId id;

  @override
  final GameStatus status;
}

extension GamePlayers on Game {
  /// The game creator plays X, the opponent plays O.
  CellMark markOf(PlayerId playerId) => playerId == hostId ? CellMark.X : CellMark.O;

  String nameOf(PlayerId playerId) => playerId == hostId ? hostName : guestName ?? '';
}

/// A cell of the board, numbered row by row from 0 to 8.
extension type const Cell(int index) {
  static final all = List<Cell>.unmodifiable([for (var index = 0; index < Board.cellCount; index++) Cell(index)]);

  int get row => index ~/ Board.size;

  int get column => index % Board.size;

  bool get isOnBoard => index >= 0 && index < Board.cellCount;
}

/// The 3×3 grid.
@Freezed(copyWith: false)
final class Board with _$Board {
  const Board({this.cells = _emptyCells});

  static const size = 3;
  static const cellCount = size * size;
  static const empty = Board();

  /// Every row, column and diagonal.
  static const lines = [
    [Cell(0), Cell(1), Cell(2)], [Cell(3), Cell(4), Cell(5)], [Cell(6), Cell(7), Cell(8)], // rows
    [Cell(0), Cell(3), Cell(6)], [Cell(1), Cell(4), Cell(7)], [Cell(2), Cell(5), Cell(8)], // columns
    [Cell(0), Cell(4), Cell(8)], [Cell(2), Cell(4), Cell(6)], // diagonals
  ];

  static const _emptyCells = <CellMark?>[null, null, null, null, null, null, null, null, null];

  @override
  final List<CellMark?> cells;

  CellMark? operator [](Cell cell) => cells[cell.index];

  Iterable<Cell> get emptyCells => Cell.all.where((cell) => this[cell] == null);

  bool get isFull => !cells.contains(null);

  bool hasLine(CellMark mark) => lines.any((line) => line.every((cell) => this[cell] == mark));

  Board play(Cell cell, CellMark mark) => Board(cells: List.unmodifiable([...cells]..[cell.index] = mark));
}
