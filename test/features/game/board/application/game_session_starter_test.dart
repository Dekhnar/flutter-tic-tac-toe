import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session_starter.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_providers.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/player_identity.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

const _gameId = GameId('ABCDEF');
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

  /// The game as the server stores it. The fake database applies a transaction just after it completes.
  Future<Game> onlineGame() async {
    await Future<void>.delayed(Duration.zero);
    return FirestoreGameRepository(firestore: firestore).watchGame(_gameId).first.timeout(const Duration(seconds: 1));
  }

  test('a local game is created on the device, both players sharing it', () async {
    final container = containerSignedInAs(const _SignedIn(_jessy));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.offline(guestName: 'Mario', hostName: 'Jessy'));

    final game = await localRepository.watchGame(session.gameId).first;
    expect(session, isA<LocalGameSession>());
    expect((game.fromName, game.toName, game.vsAi), ('Jessy', 'Mario', false));
  });

  test('a game against the AI seats the AI as the guest', () async {
    final container = containerSignedInAs(const _SignedIn(_jessy));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.offlineVsAi(hostName: 'Jessy'));

    expect((await localRepository.watchGame(session.gameId).first).vsAi, isTrue);
  });

  test('an online game is created under the signed-in player, who then plays as the host', () async {
    final container = containerSignedInAs(const _SignedIn(_jessy));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.createOnlineLobby(gameId: _gameId, hostName: 'Jessy'));

    final game = await onlineGame();
    expect(session, const GameSession.online(gameId: _gameId, me: _jessy));
    expect((game.fromId, game.fromName, game.status), (_jessy, 'Jessy', GameStatus.setup));
  });

  test('joining an online game seats the signed-in player as the guest', () async {
    await FirestoreGameRepository(firestore: firestore).createGame(_gameId, host: _jessy, hostName: 'Jessy');
    final container = containerSignedInAs(const _SignedIn(_luigi));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.joinOnlineLobby(gameId: _gameId, guestName: 'Luigi'));

    final game = await FirestoreGameRepository(
      firestore: firestore,
    ).watchGame(_gameId).firstWhere((game) => game.toId != null).timeout(const Duration(seconds: 1));
    expect(session, const GameSession.online(gameId: _gameId, me: _luigi));
    expect((game.toId, game.toName), (_luigi, 'Luigi'));
  });

  test('an online game cannot be started without Firebase, and nothing is written', () async {
    final container = containerSignedInAs(const _SignedIn(_jessy), isOnlineAvailable: false);

    await expectLater(
      container
          .read(gameSessionStarterProvider)
          .start(GameCreateInput.createOnlineLobby(gameId: _gameId, hostName: 'Jessy')),
      throwsA(isA<OnlineUnavailableException>()),
    );
    expect((await firestore.collection('games').get()).docs, isEmpty);
  });

  test('an online game is still created when nobody watches the creation any more by the time sign-in ends', () async {
    final signIn = Completer<PlayerId>();
    final container = containerSignedInAs(_SigningIn(signIn.future));

    final session = container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.createOnlineLobby(gameId: _gameId, hostName: 'Jessy'));
    container.invalidate(gameSessionStarterProvider);
    await container.pump();
    signIn.complete(_jessy);

    expect(await session, const GameSession.online(gameId: _gameId, me: _jessy));
    expect((await onlineGame()).fromId, _jessy);
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
