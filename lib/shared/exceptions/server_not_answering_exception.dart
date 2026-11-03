import 'package:tic_tac_toe_app/shared/exceptions/expected_exception.dart';

/// The server could not be reached, or did not answer in time: the player can check their connection and try again.
final class ServerNotAnsweringException implements ExpectedException {
  const ServerNotAnsweringException(this.cause);

  /// The network error, or the time limit that ran out.
  final Object cause;

  @override
  String toString() => 'ServerNotAnsweringException($cause)';
}
