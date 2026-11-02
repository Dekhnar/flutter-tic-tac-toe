import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

part 'message_notifier.g.dart';

enum InfoMessage {
  cellAlreadyTaken,
  gameAlreadyFull,
  gameNotFound,
  gameNotStartedYet,
  invalidCellIndex,
  notYourTurn,
  onlineUnavailable,
  opponentMustJoin,
  pleaseRetry,
  roundIsOver;

  factory InfoMessage.explaining(AppException exception) => switch (exception) {
    MoveCellAlreadyTakenException() => cellAlreadyTaken,
    MoveCellIndexInvalidException() => invalidCellIndex,
    MoveGameFinishedException() => roundIsOver,
    MoveGameNotStartedException() => gameNotStartedYet,
    MoveNotYourTurnException() => notYourTurn,
    MoveOpponentMissingException() => opponentMustJoin,
    GameAlreadyFullException() => gameAlreadyFull,
    GameNotFoundException() => gameNotFound,
  };
}

/// One message to display. Each call builds a new instance on purpose: Riverpod compares states by identity, so
/// showing the same [InfoMessage] twice in a row still notifies the listeners.
final class MessageEvent {
  MessageEvent(this.message);

  final InfoMessage message;
}

@riverpod
class MessageNotifier extends _$MessageNotifier {
  @override
  MessageEvent? build() => null;

  void showMessage(InfoMessage message) => state = MessageEvent(message);
}
