import 'package:firebase_auth/firebase_auth.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

/// Anonymous Firebase account: the device keeps the same player id across launches, so it can come back to its games.
final class FirebasePlayerIdentity implements PlayerIdentity {
  const FirebasePlayerIdentity({required FirebaseAuth auth}) : _auth = auth;

  final FirebaseAuth _auth;

  @override
  Future<PlayerId> signIn() async {
    final user = _auth.currentUser ?? (await _signInAnonymously()).user;
    if (user == null) throw StateError('Anonymous sign-in returned no user');

    return PlayerId(user.uid);
  }

  Future<UserCredential> _signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } on FirebaseAuthException catch (error, stackTrace) {
      if (error.code != 'network-request-failed') rethrow;

      Error.throwWithStackTrace(ServerNotAnsweringException(error), stackTrace);
    }
  }
}
