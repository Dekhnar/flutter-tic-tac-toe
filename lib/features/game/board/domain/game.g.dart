// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
  boardState:
      json['boardState'] == null
          ? const BoardState()
          : BoardState.fromJson(json['boardState'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  currentPlayerId: const PlayerIdConverter().fromJson(
    json['currentPlayerId'] as String,
  ),
  currentRoundIndex: (json['currentRoundIndex'] as num?)?.toInt() ?? 0,
  currentWinnerId: _$JsonConverterFromJson<String, PlayerId>(
    json['currentWinnerId'],
    const PlayerIdConverter().fromJson,
  ),
  fromId: const PlayerIdConverter().fromJson(json['fromId'] as String),
  fromName: json['fromName'] as String,
  fromWinCount: (json['fromWinCount'] as num?)?.toInt() ?? 0,
  id: const GameIdConverter().fromJson(json['id'] as String),
  lastPlayAt:
      json['lastPlayAt'] == null
          ? null
          : DateTime.parse(json['lastPlayAt'] as String),
  moves:
      (json['moves'] as List<dynamic>?)
          ?.map((e) => Move.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status: $enumDecode(_$GameStatusEnumMap, json['status']),
  toId: _$JsonConverterFromJson<String, PlayerId>(
    json['toId'],
    const PlayerIdConverter().fromJson,
  ),
  toName: json['toName'] as String?,
  toWinCount: (json['toWinCount'] as num?)?.toInt() ?? 0,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  vsAi: json['vsAi'] as bool? ?? false,
);

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
  'boardState': instance.boardState.toJson(),
  'createdAt': instance.createdAt.toIso8601String(),
  'currentPlayerId': const PlayerIdConverter().toJson(instance.currentPlayerId),
  'currentRoundIndex': instance.currentRoundIndex,
  'currentWinnerId': _$JsonConverterToJson<String, PlayerId>(
    instance.currentWinnerId,
    const PlayerIdConverter().toJson,
  ),
  'fromId': const PlayerIdConverter().toJson(instance.fromId),
  'fromName': instance.fromName,
  'fromWinCount': instance.fromWinCount,
  'id': const GameIdConverter().toJson(instance.id),
  'lastPlayAt': instance.lastPlayAt?.toIso8601String(),
  'moves': instance.moves.map((e) => e.toJson()).toList(),
  'status': _$GameStatusEnumMap[instance.status]!,
  'toId': _$JsonConverterToJson<String, PlayerId>(
    instance.toId,
    const PlayerIdConverter().toJson,
  ),
  'toName': instance.toName,
  'toWinCount': instance.toWinCount,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'vsAi': instance.vsAi,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

const _$GameStatusEnumMap = {
  GameStatus.setup: 'setup',
  GameStatus.playing: 'playing',
  GameStatus.finished: 'finished',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

Move _$MoveFromJson(Map<String, dynamic> json) => Move(
  index: (json['index'] as num).toInt(),
  mark: $enumDecode(_$CellMarkEnumMap, json['mark']),
  playerId: const PlayerIdConverter().fromJson(json['playerId'] as String),
  round: (json['round'] as num).toInt(),
  turn: (json['turn'] as num).toInt(),
);

Map<String, dynamic> _$MoveToJson(Move instance) => <String, dynamic>{
  'index': instance.index,
  'mark': _$CellMarkEnumMap[instance.mark]!,
  'playerId': const PlayerIdConverter().toJson(instance.playerId),
  'round': instance.round,
  'turn': instance.turn,
};

const _$CellMarkEnumMap = {CellMark.O: 'O', CellMark.X: 'X'};

BoardState _$BoardStateFromJson(Map<String, dynamic> json) => BoardState(
  anti: (json['anti'] as num?)?.toInt() ?? 0,
  col:
      (json['col'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [0, 0, 0],
  diag: (json['diag'] as num?)?.toInt() ?? 0,
  moveCount: (json['moveCount'] as num?)?.toInt() ?? 0,
  row:
      (json['row'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [0, 0, 0],
);

Map<String, dynamic> _$BoardStateToJson(BoardState instance) =>
    <String, dynamic>{
      'anti': instance.anti,
      'col': instance.col,
      'diag': instance.diag,
      'moveCount': instance.moveCount,
      'row': instance.row,
    };
