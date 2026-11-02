import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/application/start_game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/data/auth/firebase_player_identity.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_local_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/player_identity.dart';

const _gameId = GameId('ABCDEF');

void main() {
  late FakeFirebaseFirestore firestore;

  ProviderContainer containerSignedInAs(PlayerId player) {
    final container = ProviderContainer(
      overrides: [
        onlineGameRepositoryProvider.overrideWithValue(GameRepository(firestore: firestore)),
        playerIdentityProvider.overrideWithValue(_FakePlayerIdentity(player)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() => firestore = FakeFirebaseFirestore());

  test('a local game is created on the device, both players sharing it', () async {
    final container = containerSignedInAs(const PlayerId('unused'));

    final session = await container.read(startGameSessionProvider)(
      GameCreateInput.offline(guestName: 'Mario', hostName: 'Jessy'),
    );

    final game = await container.read(localGameRepositoryProvider).watchGame(session.gameId).first;
    expect(session, isA<LocalGameSession>());
    expect((game.fromName, game.toName, game.vsAi), ('Jessy', 'Mario', false));
  });

  test('a game against the AI seats the AI as the guest', () async {
    final container = containerSignedInAs(const PlayerId('unused'));

    final session = await container.read(startGameSessionProvider)(GameCreateInput.offlineVsAi(hostName: 'Jessy'));

    final game = await container.read(localGameRepositoryProvider).watchGame(session.gameId).first;
    expect(game.vsAi, isTrue);
  });

  test('an online game is created under the signed-in player, who then plays as the host', () async {
    const jessy = PlayerId('jessy-uid');
    final container = containerSignedInAs(jessy);

    final session = await container.read(startGameSessionProvider)(
      GameCreateInput.createOnlineLobby(gameId: _gameId, hostName: 'Jessy'),
    );

    // The fake database applies a transaction just after it completes.
    await Future<void>.delayed(Duration.zero);
    final game = await container.read(onlineGameRepositoryProvider).watchGame(_gameId).first;
    expect(session, const GameSession.online(gameId: _gameId, me: jessy));
    expect((game.fromId, game.fromName, game.status), (jessy, 'Jessy', GameStatus.setup));
  });

  test('joining an online game seats the signed-in player as the guest', () async {
    const luigi = PlayerId('luigi-uid');
    await GameRepository(
      firestore: firestore,
    ).createGame(_gameId, host: const PlayerId('jessy-uid'), hostName: 'Jessy');
    final container = containerSignedInAs(luigi);

    final session = await container.read(startGameSessionProvider)(
      GameCreateInput.joinOnlineLobby(gameId: _gameId, guestName: 'Luigi'),
    );

    // The fake database applies a transaction just after it completes.
    await Future<void>.delayed(Duration.zero);
    final game = await container.read(onlineGameRepositoryProvider).watchGame(_gameId).first;
    expect(session, const GameSession.online(gameId: _gameId, me: luigi));
    expect((game.toId, game.toName), (luigi, 'Luigi'));
  });
}

final class _FakePlayerIdentity implements PlayerIdentity {
  const _FakePlayerIdentity(this._player);

  final PlayerId _player;

  @override
  Future<PlayerId> signIn() async => _player;
}
