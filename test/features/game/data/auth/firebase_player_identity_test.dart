import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/data/auth/firebase_player_identity.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

void main() {
  test('a device signs in anonymously once, then keeps playing as the same player', () async {
    final auth = _FakeAuth();
    final identity = FirebasePlayerIdentity(auth: auth);

    final first = await identity.signIn();
    final second = await identity.signIn();

    expect((first, second), (const PlayerId('anonymous-1'), const PlayerId('anonymous-1')));
    expect(auth.anonymousSignIns, 1);
  });

  test('a device that cannot reach the server is told so', () async {
    final identity = FirebasePlayerIdentity(auth: _FakeAuth(offline: true));

    await expectLater(identity.signIn(), throwsA(isA<ServerNotAnsweringException>()));
  });
}

/// The account Firebase Auth keeps on the device between launches.
final class _FakeAuth implements FirebaseAuth {
  _FakeAuth({this.offline = false});

  final bool offline;
  User? _user;
  int anonymousSignIns = 0;

  @override
  User? get currentUser => _user;

  @override
  Future<UserCredential> signInAnonymously() async {
    if (offline) throw FirebaseAuthException(code: 'network-request-failed');

    final user = _FakeUser('anonymous-${++anonymousSignIns}');
    _user = user;
    return _FakeCredential(user);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeUser implements User {
  _FakeUser(this.uid);

  @override
  final String uid;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FakeCredential implements UserCredential {
  _FakeCredential(this.user);

  @override
  final User? user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
