import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

/// Why the game refused what the player asked: each one has its own message for the player.
sealed class GameException implements ExpectedException {
  GameException({required this.code});
  final String code;

  @override
  String toString() => '$runtimeType($code)';
}

final class GameAlreadyFullException extends GameException {
  GameAlreadyFullException() : super(code: 'game_already_full');
}

final class GameAbandonedException extends GameException {
  GameAbandonedException() : super(code: 'game_abandoned');
}

final class GameNotFoundException extends GameException {
  GameNotFoundException() : super(code: 'game_not_found');
}

final class GameOpponentMissingException extends GameException {
  GameOpponentMissingException() : super(code: 'game_opponent_missing');
}

final class MoveCellAlreadyTakenException extends GameException {
  MoveCellAlreadyTakenException() : super(code: 'move_cell_already_taken');
}

final class MoveCellIndexInvalidException extends GameException {
  MoveCellIndexInvalidException() : super(code: 'move_cell_index_invalid');
}

final class MoveGameFinishedException extends GameException {
  MoveGameFinishedException() : super(code: 'move_game_finished');
}

final class MoveGameNotStartedException extends GameException {
  MoveGameNotStartedException() : super(code: 'move_game_not_started');
}

final class MoveNotYourTurnException extends GameException {
  MoveNotYourTurnException() : super(code: 'move_not_your_turn');
}
