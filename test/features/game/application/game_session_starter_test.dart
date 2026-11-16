import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session_starter.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';

import '../../../shared/fakes/signed_in_identity.dart';

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
        localGameRepositoryProvider.overrideWithValue(localRepository),
        onlinePlayProvider.overrideWithValue(
          isOnlineAvailable
              ? OnlinePlayAvailable(identity: identity, repository: FirestoreGameRepository(firestore: firestore))
              : const OnlinePlayUnavailable(OnlineUnavailableReason.notConfigured),
        ),
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
    final container = containerSignedInAs(SignedInIdentity(_jessy));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.local(guestName: 'Mario', hostName: 'Jessy'));

    final game = await localRepository.watchGame(session.gameId).first;
    expect(session, isA<LocalGameSession>());
    expect((game.host.name, game.guest?.name), ('Jessy', 'Mario'));
    expect(session, const GameSession.local(gameId: GameId('local-1')));
  });

  test('in a game against the AI, the AI plays the guest', () async {
    final container = containerSignedInAs(SignedInIdentity(_jessy));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.localVsAi(hostName: 'Jessy'));

    final game = await localRepository.watchGame(session.gameId).first;
    expect(session.isAi(game, InMemoryGameRepository.guestId), isTrue);
    expect(session.isAi(game, InMemoryGameRepository.hostId), isFalse);
  });

  test('an online game is created under the signed-in player, who then plays as the host', () async {
    final container = containerSignedInAs(SignedInIdentity(_jessy));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.createOnline(hostName: 'Jessy'));

    final game = await onlineGame(session.gameId);
    expect(session, GameSession.online(gameId: game.id, me: _jessy));
    expect((game.host.id, game.host.name, game.status), (_jessy, 'Jessy', GameStatus.setup));
  });

  test('joining an online game seats the signed-in player as the guest', () async {
    final gameId = await FirestoreGameRepository(firestore: firestore).createGame(host: _jessy, hostName: 'Jessy');
    final container = containerSignedInAs(SignedInIdentity(_luigi));

    final session = await container
        .read(gameSessionStarterProvider)
        .start(GameCreateInput.joinOnline(code: gameId, guestName: 'Luigi'));

    final game = await onlineGame(gameId, where: (game) => game.guest?.id != null);
    expect(session, GameSession.online(gameId: gameId, me: _luigi));
    expect((game.guest?.id, game.guest?.name), (_luigi, 'Luigi'));
  });

  group('A session that started once the player no longer waited for it', () {
    test('leaves the game created for it: nobody else knows the code', () async {
      final starter = containerSignedInAs(SignedInIdentity(_jessy)).read(gameSessionStarterProvider);
      const input = GameCreateInput.createOnline(hostName: 'Jessy');
      final session = await starter.start(input);

      await starter.dropLate(input, session);

      expect(
        (await onlineGame(session.gameId, where: (game) => game.status == GameStatus.abandoned)).status,
        GameStatus.abandoned,
      );
    });

    test('keeps the seat taken in a friend\'s game, so that joining again opens it', () async {
      final code = await FirestoreGameRepository(firestore: firestore).createGame(host: _jessy, hostName: 'Jessy');
      final starter = containerSignedInAs(SignedInIdentity(_luigi)).read(gameSessionStarterProvider);
      final input = GameCreateInput.joinOnline(code: code, guestName: 'Luigi');
      final session = await starter.start(input);

      await starter.dropLate(input, session);

      expect(await starter.start(input), session);
      final game = await onlineGame(code, where: (game) => game.guest != null);
      expect((game.guest?.id, game.status), (_luigi, GameStatus.setup));
    });

    test('forgets a local game', () async {
      final starter = containerSignedInAs(SignedInIdentity(_jessy)).read(gameSessionStarterProvider);
      const input = GameCreateInput.localVsAi(hostName: 'Jessy');
      final session = await starter.start(input);

      await starter.dropLate(input, session);

      await expectLater(localRepository.watchGame(session.gameId).first, throwsA(isA<GameNotFoundException>()));
    });
  });

  test('an online game cannot be started without Firebase, and nothing is written', () async {
    final container = containerSignedInAs(SignedInIdentity(_jessy), isOnlineAvailable: false);

    await expectLater(
      container.read(gameSessionStarterProvider).start(GameCreateInput.createOnline(hostName: 'Jessy')),
      throwsA(isA<OnlineUnavailableException>()),
    );
    expect((await firestore.collection('games').get()).docs, isEmpty);
  });

  test('an online game is still created when nobody watches the creation any more by the time sign-in ends', () async {
    final signIn = Completer<PlayerId>();
    final container = containerSignedInAs(SignedInIdentity.later(signIn.future));

    final session = container.read(gameSessionStarterProvider).start(GameCreateInput.createOnline(hostName: 'Jessy'));
    container.invalidate(gameSessionStarterProvider);
    await container.pump();
    signIn.complete(_jessy);

    final created = await session;
    expect(created.me, _jessy);
    expect((await onlineGame(created.gameId)).host.id, _jessy);
  });
}
