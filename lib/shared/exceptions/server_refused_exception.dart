/// The server refused a request the app believed valid: the app is out of date, or a protection like App Check turned
/// it away. Unlike a refusal the game explains, it is reported.
final class ServerRefusedException implements Exception {
  const ServerRefusedException(this.cause);

  final Object cause;

  @override
  String toString() => 'ServerRefusedException($cause)';
}
