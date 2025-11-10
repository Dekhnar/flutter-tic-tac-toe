import 'package:freezed_annotation/freezed_annotation.dart';

part 'game.freezed.dart';
part 'game.g.dart';

enum CellMark { O, X }

enum GameStatus { setup, playing, finished }

@freezed
@JsonSerializable(explicitToJson: true)
final class Game with _$Game {
  const Game({
    required this.id,
    required this.fromId,
    this.toId,
    required this.status,
    this.shareLink,
    this.moves = const [],
    this.boardState = const BoardState(),
    required this.currentPlayerId,
    this.fromWinCount = 0,
    this.toWinCount = 0,
    this.currentRoundIndex = 0,
    this.currentWinnerId,
    this.lastPlayAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final String id;

  @override
  final String fromId;

  @override
  final String? toId;

  @override
  final GameStatus status;

  @override
  final String? shareLink;

  @override
  final List<Move> moves;

  @override
  final BoardState boardState;

  @override
  final int fromWinCount;

  @override
  final int toWinCount;

  @override
  final int currentRoundIndex;

  @override
  final String currentPlayerId;

  @override
  final String? currentWinnerId;

  @override
  final DateTime? lastPlayAt;

  @override
  final DateTime updatedAt;

  @override
  final DateTime createdAt;

  factory Game.fromJson(Map<String, Object?> json) => _$GameFromJson(json);
  Map<String, Object?> toJson() => _$GameToJson(this);
}

@freezed
@JsonSerializable()
final class Move with _$Move {
  const Move({
    required this.playerId,
    required this.index,
    required this.mark,
    required this.round,
    required this.turn,
  });

  @override
  final String playerId;
  @override
  final int index;
  @override
  final CellMark mark;
  @override
  final int round;
  @override
  final int turn;

  factory Move.fromJson(Map<String, Object?> json) => _$MoveFromJson(json);
  Map<String, Object?> toJson() => _$MoveToJson(this);
}

@freezed
@JsonSerializable()
final class BoardState with _$BoardState {
  const BoardState({
    this.diag = 0,
    this.anti = 0,
    this.moveCount = 0,
    this.row = const [0, 0, 0],
    this.col = const [0, 0, 0],
  });

  @override
  final List<int> row;
  @override
  final List<int> col;
  @override
  final int diag;
  @override
  final int anti;
  @override
  final int moveCount;

  factory BoardState.fromJson(Map<String, Object?> json) => _$BoardStateFromJson(json);
  Map<String, Object?> toJson() => _$BoardStateToJson(this);
}
