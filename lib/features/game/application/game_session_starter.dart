import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';

part 'game_session_starter.g.dart';

/// Creates or joins the game the player chose; the board then only watches it.
final class GameSessionStarter {
  const GameSessionStarter({required LocalGameRepository localRepository, required OnlinePlay onlinePlay})
    : _localRepository = localRepository,
      _onlinePlay = onlinePlay;

  final LocalGameRepository _localRepository;
  final OnlinePlay _onlinePlay;

  Future<GameSession> start(GameCreateInput input) async {
    switch (input) {
      case GameCreateInputOffline1v1(:final guestName, :final hostName):
        final gameId = await _localRepository.createGame(guestName: guestName, hostName: hostName);
        return GameSession.local(gameId: gameId);
      case GameCreateInputOfflineVsAi(:final hostName):
        final gameId = await _localRepository.createGame(guestName: '', hostName: hostName);
        return GameSession.local(gameId: gameId, vsAi: true);
      case GameCreateInputOnlineLobby(:final hostName):
        final online = _online();
        final me = await online.identity.signIn();
        final gameId = await online.repository.createGame(host: me, hostName: hostName);
        return GameSession.online(gameId: gameId, me: me);
      case GameCreateInputJoinOnlineLobby(:final gameId, :final guestName):
        final online = _online();
        final me = await online.identity.signIn();
        await online.repository.joinGame(gameId, guest: me, guestName: guestName);
        return GameSession.online(gameId: gameId, me: me);
    }
  }

  /// Leaves the game of a [session] nobody is going to open.
  Future<void> leave(GameSession session) => switch (session) {
    LocalGameSession() => _localRepository.leaveGame(session.gameId),
    OnlineGameSession() => _online().repository.leaveGame(session.gameId),
  };

  OnlinePlayAvailable _online() => switch (_onlinePlay) {
    final OnlinePlayAvailable online => online,
    OnlinePlayUnavailable(:final reason) => throw OnlineUnavailableException(reason),
  };
}

/// Holds the dependencies themselves rather than a `Ref`, which may be disposed before a creation completes.
@riverpod
GameSessionStarter gameSessionStarter(Ref ref) => GameSessionStarter(
  localRepository: ref.watch(localGameRepositoryProvider),
  onlinePlay: ref.watch(onlinePlayProvider),
);
