// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
  id: json['id'] as String,
  fromId: json['fromId'] as String,
  toId: json['toId'] as String?,
  status: $enumDecode(_$GameStatusEnumMap, json['status']),
  shareLink: json['shareLink'] as String?,
  moves:
      (json['moves'] as List<dynamic>?)
          ?.map((e) => Move.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  boardState:
      json['boardState'] == null
          ? const BoardState()
          : BoardState.fromJson(json['boardState'] as Map<String, dynamic>),
  currentPlayerId: json['currentPlayerId'] as String,
  fromWinCount: (json['fromWinCount'] as num?)?.toInt() ?? 0,
  toWinCount: (json['toWinCount'] as num?)?.toInt() ?? 0,
  currentRoundIndex: (json['currentRoundIndex'] as num?)?.toInt() ?? 0,
  currentWinnerId: json['currentWinnerId'] as String?,
  lastPlayAt:
      json['lastPlayAt'] == null
          ? null
          : DateTime.parse(json['lastPlayAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
  'id': instance.id,
  'fromId': instance.fromId,
  'toId': instance.toId,
  'status': _$GameStatusEnumMap[instance.status]!,
  'shareLink': instance.shareLink,
  'moves': instance.moves.map((e) => e.toJson()).toList(),
  'boardState': instance.boardState.toJson(),
  'fromWinCount': instance.fromWinCount,
  'toWinCount': instance.toWinCount,
  'currentRoundIndex': instance.currentRoundIndex,
  'currentPlayerId': instance.currentPlayerId,
  'currentWinnerId': instance.currentWinnerId,
  'lastPlayAt': instance.lastPlayAt?.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$GameStatusEnumMap = {
  GameStatus.setup: 'setup',
  GameStatus.playing: 'playing',
  GameStatus.finished: 'finished',
};

Move _$MoveFromJson(Map<String, dynamic> json) => Move(
  playerId: json['playerId'] as String,
  index: (json['index'] as num).toInt(),
  mark: $enumDecode(_$CellMarkEnumMap, json['mark']),
  round: (json['round'] as num).toInt(),
  turn: (json['turn'] as num).toInt(),
);

Map<String, dynamic> _$MoveToJson(Move instance) => <String, dynamic>{
  'playerId': instance.playerId,
  'index': instance.index,
  'mark': _$CellMarkEnumMap[instance.mark]!,
  'round': instance.round,
  'turn': instance.turn,
};

const _$CellMarkEnumMap = {CellMark.O: 'O', CellMark.X: 'X'};

BoardState _$BoardStateFromJson(Map<String, dynamic> json) => BoardState(
  diag: (json['diag'] as num?)?.toInt() ?? 0,
  anti: (json['anti'] as num?)?.toInt() ?? 0,
  moveCount: (json['moveCount'] as num?)?.toInt() ?? 0,
  row:
      (json['row'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [0, 0, 0],
  col:
      (json['col'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [0, 0, 0],
);

Map<String, dynamic> _$BoardStateToJson(BoardState instance) =>
    <String, dynamic>{
      'row': instance.row,
      'col': instance.col,
      'diag': instance.diag,
      'anti': instance.anti,
      'moveCount': instance.moveCount,
    };
