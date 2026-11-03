import 'dart:async';

import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

/// The server could not be reached, or did not answer in time: the player can check their connection and try again.
final class ServerNotAnsweringException implements ExpectedException {
  const ServerNotAnsweringException(this.cause);

  ServerNotAnsweringException.after(Duration timeLimit)
    : this(TimeoutException('No answer within $timeLimit', timeLimit));

  final Object cause;

  @override
  String toString() => 'ServerNotAnsweringException($cause)';
}

extension ServerTimeLimit<T> on Future<T> {
  /// Stops waiting for an answer after [timeLimit]. The request itself may still reach the server later.
  Future<T> withinTimeLimit(Duration timeLimit) =>
      timeout(timeLimit, onTimeout: () => throw ServerNotAnsweringException.after(timeLimit));
}

extension ServerTimeLimitStream<T> on Stream<T> {
  /// Fails once with a [ServerNotAnsweringException] when the first event takes longer than [timeLimit]. Later events
  /// take as long as they take: a game waits for the other player.
  Stream<T> firstWithinTimeLimit(Duration timeLimit) {
    var waiting = true;
    return map((event) {
      waiting = false;
      return event;
    }).timeout(
      timeLimit,
      onTimeout: (sink) {
        if (!waiting) return;

        waiting = false;
        sink.addError(ServerNotAnsweringException.after(timeLimit));
      },
    );
  }
}
