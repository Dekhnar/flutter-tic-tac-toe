import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_providers.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/domain/player_identity.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

part 'game_session_starter.g.dart';

/// Creates or joins the game the player chose; the board then only watches it.
final class GameSessionStarter {
  const GameSessionStarter({
    required LocalGameRepositoryInterface localRepository,
    OnlineGameRepositoryInterface? onlineRepository,
    PlayerIdentity? playerIdentity,
  }) : _localRepository = localRepository,
       _onlineRepository = onlineRepository,
       _playerIdentity = playerIdentity;

  final LocalGameRepositoryInterface _localRepository;
  final OnlineGameRepositoryInterface? _onlineRepository;
  final PlayerIdentity? _playerIdentity;

  Future<GameSession> start(GameCreateInput input) async {
    switch (input) {
      case GameCreateInputOffline1v1(:final guestName, :final hostName):
        final gameId = await _localRepository.createGame(guestName: guestName, hostName: hostName);
        return GameSession.local(gameId: gameId);
      case GameCreateInputOfflineVsAi(:final hostName):
        final gameId = await _localRepository.createGame(guestName: '', hostName: hostName);
        return GameSession.local(gameId: gameId, vsAi: true);
      case GameCreateInputOnlineLobby(:final hostName):
        final (repository, me) = await _signInOnline();
        final gameId = await repository.createGame(host: me, hostName: hostName);
        return GameSession.online(gameId: gameId, me: me);
      case GameCreateInputJoinOnlineLobby(:final gameId, :final guestName):
        final (repository, me) = await _signInOnline();
        await repository.joinGame(gameId, guest: me, guestName: guestName);
        return GameSession.online(gameId: gameId, me: me);
    }
  }

  Future<(OnlineGameRepositoryInterface, PlayerId)> _signInOnline() async {
    final (repository, identity) = (_onlineRepository, _playerIdentity);
    if (repository == null || identity == null) throw OnlineUnavailableException();

    return (repository, await identity.signIn());
  }
}

/// Holds the dependencies themselves rather than a `Ref`, which may be disposed before a creation completes.
@riverpod
GameSessionStarter gameSessionStarter(Ref ref) {
  final isOnlineAvailable = ref.watch(isOnlineAvailableProvider);
  return GameSessionStarter(
    localRepository: ref.watch(localGameRepositoryProvider),
    onlineRepository: isOnlineAvailable ? ref.watch(onlineGameRepositoryProvider) : null,
    playerIdentity: isOnlineAvailable ? ref.watch(playerIdentityProvider) : null,
  );
}
