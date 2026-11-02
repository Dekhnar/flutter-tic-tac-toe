import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';

part 'game.freezed.dart';
part 'game.g.dart';

enum CellMark { O, X }

enum GameStatus { setup, playing, finished }

@freezed
@JsonSerializable(explicitToJson: true, converters: [GameIdConverter(), PlayerIdConverter()])
final class Game with _$Game {
  const Game({
    this.boardState = const BoardState(),
    required this.createdAt,
    required this.currentPlayerId,
    this.currentRoundIndex = 0,
    this.currentWinnerId,
    required this.fromId,
    required this.fromName,
    this.fromWinCount = 0,
    required this.id,
    this.lastPlayAt,
    this.moves = const [],
    required this.status,
    this.toId,
    this.toName,
    this.toWinCount = 0,
    required this.updatedAt,
    this.vsAi = false,
  });

  @override
  final BoardState boardState;

  @override
  final DateTime createdAt;

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
  final DateTime? lastPlayAt;

  @override
  final List<Move> moves;

  @override
  final GameStatus status;

  @override
  final PlayerId? toId;

  @override
  final String? toName;

  @override
  final int toWinCount;

  @override
  final DateTime updatedAt;

  @override
  final bool vsAi;

  factory Game.fromJson(Map<String, Object?> json) => _$GameFromJson(json);
  Map<String, Object?> toJson() => _$GameToJson(this);
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

@freezed
@JsonSerializable(converters: [PlayerIdConverter()])
final class Move with _$Move {
  const Move({
    required this.index,
    required this.mark,
    required this.playerId,
    required this.round,
    required this.turn,
  });

  @override
  final int index;
  @override
  final CellMark mark;
  @override
  final PlayerId playerId;
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
    this.anti = 0,
    this.col = const [0, 0, 0],
    this.diag = 0,
    this.moveCount = 0,
    this.row = const [0, 0, 0],
  });

  @override
  final int anti;
  @override
  final List<int> col;
  @override
  final int diag;
  @override
  final int moveCount;
  @override
  final List<int> row;

  factory BoardState.fromJson(Map<String, Object?> json) => _$BoardStateFromJson(json);
  Map<String, Object?> toJson() => _$BoardStateToJson(this);
}
