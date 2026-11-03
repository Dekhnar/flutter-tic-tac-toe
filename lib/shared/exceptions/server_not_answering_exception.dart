import 'dart:async';

import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

/// The server could not be reached, or did not answer in time: the player can check their connection and try again.
final class ServerNotAnsweringException implements ExpectedException {
  const ServerNotAnsweringException(this.cause);

  ServerNotAnsweringException.after(Duration timeLimit)
    : this(TimeoutException('No answer within $timeLimit', timeLimit));

  /// The network error, or the time limit that ran out.
  final Object cause;

  @override
  String toString() => 'ServerNotAnsweringException($cause)';
}

extension ServerTimeLimit<T> on Future<T> {
  /// Stops waiting for an answer after [timeLimit]. The request itself may still reach the server later.
  Future<T> withinTimeLimit(Duration timeLimit) =>
      timeout(timeLimit, onTimeout: () => throw ServerNotAnsweringException.after(timeLimit));
}
