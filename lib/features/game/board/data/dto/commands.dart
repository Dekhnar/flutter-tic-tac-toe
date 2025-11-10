import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';

part 'commands.g.dart';

final class CreateGameCommand {
  final String _fromId;
  final String? _shareLink;

  const CreateGameCommand({required String fromId, final String? shareLink}) : _fromId = fromId, _shareLink = shareLink;

  Map<String, Object?> toFirestore() => {
    'fromId': _fromId,
    'toId': null,
    'status': GameStatus.setup.name,
    'boardState': {
      'row': const [0, 0, 0],
      'col': const [0, 0, 0],
      'diag': 0,
      'anti': 0,
      'moveCount': 0,
    },
    if (_shareLink case final shareLink?) "shareLink": shareLink,
    'currentPlayerId': _fromId,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

final class JoinGameCommand {
  final String _joinerUid;

  JoinGameCommand({required String joinerUid}) : _joinerUid = joinerUid;

  Map<String, Object?> toFirestore() => {'toId': _joinerUid, 'updatedAt': FieldValue.serverTimestamp()};
}

final class MoveEventCommand {
  final String _playerId;
  final int _index;
  final String _mark;
  final int _round;
  final int _turn;

  MoveEventCommand({
    required String playerId,
    required int index,
    required String mark,
    required int round,
    required int turn,
  }) : _playerId = playerId,
       _index = index,
       _mark = mark,
       _round = round,
       _turn = turn;

  Map<String, Object?> toFirestore() => {
    'playerId': _playerId,
    'index': _index,
    'mark': _mark,
    'round': _round,
    'turn': _turn,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

abstract class GamePatchCommand implements Built<GamePatchCommand, GamePatchCommandBuilder> {
  BuiltList<int>? get boardStateRow;

  BuiltList<int>? get boardStateCol;

  int? get boardStateDiag;

  int? get boardStateAnti;

  int? get boardStateMoveCount;

  String? get status;

  String? get currentPlayerId;

  String? get currentWinnerId;

  bool? get fromWins;

  bool? get toWins;

  bool? get hasMoved;

  int? get currentRoundIndex;

  GamePatchCommand._();
  factory GamePatchCommand([void Function(GamePatchCommandBuilder) updates]) = _$GamePatchCommand;

  Map<String, Object?> toFirestore() {
    return <String, Object?>{
      if (currentRoundIndex case final currentRoundIndex?) 'currentRoundIndex': currentRoundIndex,

      if (boardStateRow case final boardStateRow?) 'boardState.row': boardStateRow.toList(growable: false),
      if (boardStateCol case final boardStateCol?) 'boardState.col': boardStateCol.toList(growable: false),
      if (boardStateDiag != null) 'boardState.diag': boardStateDiag,
      if (boardStateAnti != null) 'boardState.anti': boardStateAnti,
      if (boardStateMoveCount != null) 'boardState.moveCount': boardStateMoveCount,

      if (hasMoved == true) 'lastPlayAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      if (status != null) 'status': status,
      if (currentPlayerId != null) 'currentPlayerId': currentPlayerId,

      if (currentWinnerId != null)
        'currentWinnerId': currentWinnerId
      else if (status == GameStatus.finished.name)
        'currentWinnerId': null,

      if (fromWins == true) 'fromWinCount': FieldValue.increment(1),
      if (toWins == true) 'toWinCount': FieldValue.increment(1),
    };
  }
}
