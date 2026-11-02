import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

extension GameErrorMessage on I18n {
  /// What the player reads when the game refused what they asked, or could not do it.
  String gameError(Object error) => switch (error) {
    final GameException refusal => _refusal(refusal),
    _ => pleaseRetry,
  };

  String _refusal(GameException refusal) => switch (refusal) {
    GameAlreadyFullException() => gameAlreadyFull,
    GameNotFoundException() => gameNotFound,
    MoveCellAlreadyTakenException() => cellAlreadyTaken,
    MoveCellIndexInvalidException() => invalidCellIndex,
    MoveGameFinishedException() => roundIsOver,
    MoveGameNotStartedException() => gameNotStartedYet,
    MoveNotYourTurnException() => notYourTurn,
    MoveOpponentMissingException() => opponentMustJoin,
    OnlineUnavailableException() => onlineUnavailable,
  };
}
