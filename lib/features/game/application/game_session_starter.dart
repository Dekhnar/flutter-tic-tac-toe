import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';

part 'game_session_starter.g.dart';

final class GameSessionStarter {
  const GameSessionStarter({required LocalGameRepository localRepository, required OnlinePlay onlinePlay})
    : _localRepository = localRepository,
      _onlinePlay = onlinePlay;

  final LocalGameRepository _localRepository;
  final OnlinePlay _onlinePlay;

  Future<GameSession> start(GameCreateInput input) async {
    switch (input) {
      case LocalGameInput(:final guestName, :final hostName):
        final gameId = await _localRepository.createGame(guestName: guestName, hostName: hostName);
        return GameSession.local(gameId: gameId);
      case LocalVsAiGameInput(:final hostName):
        final gameId = await _localRepository.createGame(guestName: '', hostName: hostName);
        return GameSession.local(gameId: gameId, vsAi: true);
      case CreateOnlineGameInput(:final hostName):
        final online = _online();
        final me = await online.identity.signIn();
        final code = await online.repository.createGame(host: me, hostName: hostName);
        return GameSession.online(gameId: code, me: me);
      case JoinOnlineGameInput(:final code, :final guestName):
        final online = _online();
        final me = await online.identity.signIn();
        await online.repository.joinGame(code, guest: me, guestName: guestName);
        return GameSession.online(gameId: code, me: me);
    }
  }

  /// Lets go of a [session] that started once the player no longer waited for it. A game created for it is left: nobody
  /// else knows it. A seat taken in someone else's game is kept, so that joining again opens the game.
  Future<void> dropLate(GameCreateInput input, GameSession session) async {
    if (input is JoinOnlineGameInput) return;

    await switch (session) {
      LocalGameSession(:final gameId) => _localRepository.leaveGame(gameId),
      OnlineGameSession(:final gameId) => _online().repository.leaveGame(gameId),
    };
  }

  OnlinePlayAvailable _online() => switch (_onlinePlay) {
    final OnlinePlayAvailable online => online,
    OnlinePlayUnavailable(:final reason) => throw OnlineUnavailableException(reason),
  };
}

/// Holds the dependencies rather than a `Ref`, which may be disposed before a creation completes.
@riverpod
GameSessionStarter gameSessionStarter(Ref ref) => GameSessionStarter(
  localRepository: ref.watch(localGameRepositoryProvider),
  onlinePlay: ref.watch(onlinePlayProvider),
);
