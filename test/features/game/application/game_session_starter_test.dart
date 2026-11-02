import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session_starter.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

const _jessy = PlayerId('jessy-uid');
const _luigi = PlayerId('luigi-uid');

void main() {
  late FakeFirebaseFirestore firestore;
  late InMemoryGameRepository localRepository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    localRepository = InMemoryGameRepository();
    addTearDown(localRepository.dispose);
  });

  ProviderContainer containerSignedInAs(PlayerIdentity identity, {bool isOnlineAvailable = true}) {
    final container = ProviderContainer(
      overrides: [
        isOnlineAvailableProvider.overrideWithValue(isOnlineAvailable),
        localGameRepositoryProvider.overrideWithValue(localRepository),
        // As in the composition: the online contracts are bound only when Firebase is available.
        if (isOnlineAvailable) ...[
          onlineGameRepositoryProvider.overrideWith((ref) => FirestoreGameRepository(firestore: firestore)),
          playerIdentityProvider.overrideWithValue(identity),
        ],
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  /// The game as the server stores it, once the fake database applied the transaction, just after it completes.
  Future<Game> onlineGame(GameId gameId, {bool Function(Game game)? where}) async {
    await firestore.collection('games').doc(gameId.value).snapshots().firstWhere((snapshot) => snapshot.exists);
    return FirestoreGameRepository(
      firestore: firestore,
    ).watchGame(gameId).firstWhere(where ?? (_) => true).timeout(const Duration(seconds: 1));
  }

  test('a local game is created on the device, both players sharing it', () async {
    final container = containerSignedInAs(const _SignedIn(_jessy));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.offline(guestName: 'Mario', hostName: 'Jessy'));

    final game = await localRepository.watchGame(session.gameId).first;
    expect(session, isA<LocalGameSession>());
    expect((game.host.name, game.guest?.name), ('Jessy', 'Mario'));
    expect(session, const GameSession.local(gameId: GameId('local-1')));
  });

  test('in a game against the AI, the AI plays the guest', () async {
    final container = containerSignedInAs(const _SignedIn(_jessy));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.offlineVsAi(hostName: 'Jessy'));

    final game = await localRepository.watchGame(session.gameId).first;
    expect(session.isAi(game, InMemoryGameRepository.guestId), isTrue);
    expect(session.isAi(game, InMemoryGameRepository.hostId), isFalse);
  });

  test('an online game is created under the signed-in player, who then plays as the host', () async {
    final container = containerSignedInAs(const _SignedIn(_jessy));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.createOnlineLobby(hostName: 'Jessy'));

    final game = await onlineGame(session.gameId);
    expect(session, GameSession.online(gameId: game.id, me: _jessy));
    expect((game.host.id, game.host.name, game.status), (_jessy, 'Jessy', GameStatus.setup));
  });

  test('joining an online game seats the signed-in player as the guest', () async {
    final gameId = await FirestoreGameRepository(firestore: firestore).createGame(host: _jessy, hostName: 'Jessy');
    final container = containerSignedInAs(const _SignedIn(_luigi));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.joinOnlineLobby(gameId: gameId, guestName: 'Luigi'));

    final game = await onlineGame(gameId, where: (game) => game.guest?.id != null);
    expect(session, GameSession.online(gameId: gameId, me: _luigi));
    expect((game.guest?.id, game.guest?.name), (_luigi, 'Luigi'));
  });

  test('an online game cannot be started without Firebase, and nothing is written', () async {
    final container = containerSignedInAs(const _SignedIn(_jessy), isOnlineAvailable: false);

    await expectLater(
      container.read(gameSessionStarterProvider).start(GameCreateInput.createOnlineLobby(hostName: 'Jessy')),
      throwsA(isA<OnlineUnavailableException>()),
    );
    expect((await firestore.collection('games').get()).docs, isEmpty);
  });

  test('an online game is still created when nobody watches the creation any more by the time sign-in ends', () async {
    final signIn = Completer<PlayerId>();
    final container = containerSignedInAs(_SigningIn(signIn.future));

    final session = container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.createOnlineLobby(hostName: 'Jessy'));
    container.invalidate(gameSessionStarterProvider);
    await container.pump();
    signIn.complete(_jessy);

    final created = await session;
    expect(created.me, _jessy);
    expect((await onlineGame(created.gameId)).host.id, _jessy);
  });
}

final class _SignedIn implements PlayerIdentity {
  const _SignedIn(this._player);

  final PlayerId _player;

  @override
  Future<PlayerId> signIn() async => _player;
}

final class _SigningIn implements PlayerIdentity {
  const _SigningIn(this._player);

  final Future<PlayerId> _player;

  @override
  Future<PlayerId> signIn() => _player;
}
