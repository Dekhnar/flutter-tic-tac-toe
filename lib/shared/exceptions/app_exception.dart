sealed class AppException implements Exception {
  AppException({required this.code});
  final String code;
}

final class GameCreationDataMissingException extends AppException {
  GameCreationDataMissingException() : super(code: "game_creation_data_missing_exception");
}

final class GameNotFoundException extends AppException {
  GameNotFoundException() : super(code: "game_not_found");
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

final class MoveCellIndexInvalidException extends AppException {
  MoveCellIndexInvalidException() : super(code: "move_cell_index_invalid");
}

final class MoveCellAlreadyTakenException extends AppException {
  MoveCellAlreadyTakenException() : super(code: "move_cell_already_taken");
}
