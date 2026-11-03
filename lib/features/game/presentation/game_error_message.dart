import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_refused_exception.dart';

extension GameErrorMessage on I18n {
  String gameError(Object error) => switch (error) {
    final GameException refusal => _refusal(refusal),
    OnlineUnavailableException(:final reason) => onlineUnavailableBecause(reason),
    ServerNotAnsweringException() => serverNotAnswering,
    ServerRefusedException() => serverRefused,
    _ => pleaseRetry,
  };

  String onlineUnavailableBecause(OnlineUnavailableReason reason) => switch (reason) {
    OnlineUnavailableReason.failedToStart => onlineFailedToStart,
    OnlineUnavailableReason.notConfigured => onlineUnavailable,
  };

  String _refusal(GameException refusal) => switch (refusal) {
    GameAbandonedException() => gameAbandoned,
    GameAlreadyFullException() => gameAlreadyFull,
    GameNotFoundException() => gameNotFound,
    GameOpponentMissingException() => opponentMustJoin,
    MoveCellAlreadyTakenException() => cellAlreadyTaken,
    MoveCellIndexInvalidException() => invalidCellIndex,
    MoveGameFinishedException() => roundIsOver,
    MoveGameNotStartedException() => gameNotStartedYet,
    MoveNotYourTurnException() => notYourTurn,
  };
}
