import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';

// One command per kind of write `firestore.rules` accepts: each writes exactly the fields its rule allows.

final class CreateGameCommand {
  final PlayerId _host;
  final String _hostName;

  const CreateGameCommand({required PlayerId host, required String hostName}) : _host = host, _hostName = hostName;

  Map<String, Object?> toFirestore() => {
    'boardState': const BoardState().toJson(),
    'createdAt': FieldValue.serverTimestamp(),
    'currentPlayerId': _host.value,
    'currentRoundIndex': 0,
    'currentWinnerId': null,
    'fromId': _host.value,
    'fromName': _hostName,
    'fromWinCount': 0,
    'status': GameStatus.setup.name,
    'toId': null,
    'toName': null,
    'toWinCount': 0,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

final class JoinGameCommand {
  final PlayerId _guest;
  final String _guestName;

  const JoinGameCommand({required PlayerId guest, required String guestName}) : _guest = guest, _guestName = guestName;

  Map<String, Object?> toFirestore() => {
    'toId': _guest.value,
    'toName': _guestName,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

final class StartGameCommand {
  const StartGameCommand();

  Map<String, Object?> toFirestore() => {'status': GameStatus.playing.name, 'updatedAt': FieldValue.serverTimestamp()};
}

final class MoveEventCommand {
  final Move _move;

  const MoveEventCommand({required Move move}) : _move = move;

  Map<String, Object?> toFirestore() => {
    'createdAt': FieldValue.serverTimestamp(),
    'index': _move.index,
    'mark': _move.mark.name,
    'playerId': _move.playerId.value,
    'round': _move.round,
    'turn': _move.turn,
  };
}

/// The game after a move; `lastMoveIndex` lets the rules check that the move document is written in the same batch.
final class MovePlayedCommand {
  final Game _game;

  const MovePlayedCommand({required Game game}) : _game = game;

  Map<String, Object?> toFirestore() => {
    'boardState': _game.boardState.toJson(),
    'currentPlayerId': _game.currentPlayerId.value,
    'currentWinnerId': _game.currentWinnerId?.value,
    'fromWinCount': _game.fromWinCount,
    'lastMoveIndex': _game.moves.last.index,
    'lastPlayAt': FieldValue.serverTimestamp(),
    'status': _game.status.name,
    'toWinCount': _game.toWinCount,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

final class RoundStartedCommand {
  final Game _game;

  const RoundStartedCommand({required Game game}) : _game = game;

  Map<String, Object?> toFirestore() => {
    'boardState': _game.boardState.toJson(),
    'currentPlayerId': _game.currentPlayerId.value,
    'currentRoundIndex': _game.currentRoundIndex,
    'currentWinnerId': null,
    'lastPlayAt': FieldValue.serverTimestamp(),
    'status': _game.status.name,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
