sealed class AppException implements Exception {
  AppException({required this.code});
  final String code;

  @override
  String toString() => '$runtimeType($code)';
}

final class GameAlreadyFullException extends AppException {
  GameAlreadyFullException() : super(code: "game_already_full");
}

final class GameNotFoundException extends AppException {
  GameNotFoundException() : super(code: "game_not_found");
}

final class MoveCellAlreadyTakenException extends AppException {
  MoveCellAlreadyTakenException() : super(code: "move_cell_already_taken");
}

final class MoveCellIndexInvalidException extends AppException {
  MoveCellIndexInvalidException() : super(code: "move_cell_index_invalid");
}

final class MoveGameFinishedException extends AppException {
  MoveGameFinishedException() : super(code: "move_game_finished");
}

final class MoveGameNotStartedException extends AppException {
  MoveGameNotStartedException() : super(code: "move_game_not_started");
}

final class MoveNotYourTurnException extends AppException {
  MoveNotYourTurnException() : super(code: "move_not_your_turn");
}

final class MoveOpponentMissingException extends AppException {
  MoveOpponentMissingException() : super(code: "move_opponent_missing");
}
