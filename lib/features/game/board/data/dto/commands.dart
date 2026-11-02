import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';

final class CreateGameCommand {
  final String _fromId;
  final String? _shareLink;

  const CreateGameCommand({required String fromId, final String? shareLink}) : _fromId = fromId, _shareLink = shareLink;

  Map<String, Object?> toFirestore() => {
    'fromId': _fromId,
    'toId': null,
    'status': GameStatus.setup.name,
    'boardState': const BoardState().toJson(),
    if (_shareLink case final shareLink?) "shareLink": shareLink,
    'currentPlayerId': _fromId,
    'currentRoundIndex': 0,
    'fromWinCount': 0,
    'toWinCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

final class JoinGameCommand {
  final String _joinerUid;

  JoinGameCommand({required String joinerUid}) : _joinerUid = joinerUid;

  Map<String, Object?> toFirestore() => {'toId': _joinerUid, 'updatedAt': FieldValue.serverTimestamp()};
}

final class StartGameCommand {
  const StartGameCommand();

  Map<String, Object?> toFirestore() => {'status': GameStatus.playing.name, 'updatedAt': FieldValue.serverTimestamp()};
}

final class MoveEventCommand {
  final Move _move;

  const MoveEventCommand({required Move move}) : _move = move;

  Map<String, Object?> toFirestore() => {
    'playerId': _move.playerId,
    'index': _move.index,
    'mark': _move.mark.name,
    'round': _move.round,
    'turn': _move.turn,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

final class GameStateCommand {
  final Game _game;

  const GameStateCommand({required Game game}) : _game = game;

  Map<String, Object?> toFirestore() => {
    'boardState': _game.boardState.toJson(),
    'currentPlayerId': _game.currentPlayerId,
    'currentRoundIndex': _game.currentRoundIndex,
    'currentWinnerId': _game.currentWinnerId,
    'fromWinCount': _game.fromWinCount,
    'lastPlayAt': FieldValue.serverTimestamp(),
    'status': _game.status.name,
    'toWinCount': _game.toWinCount,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
