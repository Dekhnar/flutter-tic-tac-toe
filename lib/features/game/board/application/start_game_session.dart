import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/data/auth/firebase_player_identity.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_local_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_repository_provider.dart';

part 'start_game_session.g.dart';

/// Creates or joins the game the player chose; the board then only watches it.
typedef StartGameSession = Future<GameSession> Function(GameCreateInput input);

@riverpod
StartGameSession startGameSession(Ref ref) => (input) async {
  switch (input) {
    case GameCreateInputOffline1v1(:final guestName, :final hostName):
      final gameId = await ref
          .read(localGameRepositoryProvider)
          .createGame(guestName: guestName, hostName: hostName, vsAi: false);
      return GameSession.local(gameId: gameId);
    case GameCreateInputOfflineVsAi(:final hostName):
      final gameId = await ref
          .read(localGameRepositoryProvider)
          .createGame(guestName: '', hostName: hostName, vsAi: true);
      return GameSession.local(gameId: gameId);
    case GameCreateInputOnlineLobby(:final gameId, :final hostName):
      final me = await ref.read(playerIdentityProvider).signIn();
      await ref.read(onlineGameRepositoryProvider).createGame(gameId, host: me, hostName: hostName);
      return GameSession.online(gameId: gameId, me: me);
    case GameCreateInputJoinOnlineLobby(:final gameId, :final guestName):
      final me = await ref.read(playerIdentityProvider).signIn();
      await ref.read(onlineGameRepositoryProvider).joinGame(gameId, guest: me, guestName: guestName);
      return GameSession.online(gameId: gameId, me: me);
  }
};
