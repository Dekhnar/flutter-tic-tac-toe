import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';

part 'game.freezed.dart';

enum CellMark { O, X }

enum GameStatus { setup, playing, finished }

@freezed
final class Game with _$Game {
  const Game({
    this.board = Board.empty,
    required this.currentPlayerId,
    this.currentRoundIndex = 0,
    this.currentWinnerId,
    required this.fromId,
    required this.fromName,
    this.fromWinCount = 0,
    required this.id,
    required this.status,
    this.toId,
    this.toName,
    this.toWinCount = 0,
    this.vsAi = false,
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

  @override
  final PlayerId fromId;

  @override
  final String fromName;

  @override
  final int fromWinCount;

  @override
  final GameId id;

  @override
  final GameStatus status;

  @override
  final PlayerId? toId;

  @override
  final String? toName;

  @override
  final int toWinCount;

  @override
  final bool vsAi;
}

extension GamePlayers on Game {
  /// The game creator plays X, the opponent plays O.
  CellMark markOf(PlayerId playerId) => playerId == fromId ? CellMark.X : CellMark.O;

  String nameOf(PlayerId playerId) => playerId == fromId ? fromName : toName ?? '';

  bool get isAiTurn => vsAi && status == GameStatus.playing && currentPlayerId == toId;

  /// Whether [player] may play now. On a local game ([player] is null), whoever's turn it is plays, except the AI.
  bool isPlayableBy(PlayerId? player) =>
      status == GameStatus.playing && !isAiTurn && (player == null || currentPlayerId == player);
}

/// The 3×3 grid, its cells numbered row by row from 0 to 8.
@Freezed(copyWith: false)
final class Board with _$Board {
  const Board({this.cells = _emptyCells});

  static const size = 3;
  static const cellCount = size * size;
  static const empty = Board();

  /// Every row, column and diagonal, as cell numbers.
  static const lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  static const _emptyCells = <CellMark?>[null, null, null, null, null, null, null, null, null];

  @override
  final List<CellMark?> cells;

  CellMark? operator [](int cell) => cells[cell];

  bool get isFull => !cells.contains(null);

  bool hasLine(CellMark mark) => lines.any((line) => line.every((cell) => cells[cell] == mark));

  Board play(int cell, CellMark mark) => Board(cells: List.unmodifiable([...cells]..[cell] = mark));
}
