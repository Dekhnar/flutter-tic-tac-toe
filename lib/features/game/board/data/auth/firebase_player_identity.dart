import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/player_identity.dart';

part 'firebase_player_identity.g.dart';

@riverpod
PlayerIdentity playerIdentity(Ref ref) => FirebasePlayerIdentity(auth: FirebaseAuth.instance);

/// Anonymous Firebase account: the device keeps the same player id across launches, so it can come back to its games.
final class FirebasePlayerIdentity implements PlayerIdentity {
  const FirebasePlayerIdentity({required FirebaseAuth auth}) : _auth = auth;

  final FirebaseAuth _auth;

  @override
  Future<PlayerId> signIn() async {
    final user = _auth.currentUser ?? (await _auth.signInAnonymously()).user;
    if (user == null) throw StateError('Anonymous sign-in returned no user');

    return PlayerId(user.uid);
  }
}
