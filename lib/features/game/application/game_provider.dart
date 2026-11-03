import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';

part 'game_provider.g.dart';

/// Throws while online play is off: no online session exists then.
@riverpod
OnlineGameRepository onlineGameRepository(Ref ref) => switch (ref.watch(onlinePlayProvider)) {
  OnlinePlayAvailable(:final repository) => repository,
  OnlinePlayUnavailable(:final reason) => throw OnlineUnavailableException(reason),
};

@riverpod
GameRepository sessionGameRepository(Ref ref, GameSession session) => switch (session) {
  LocalGameSession() => ref.watch(localGameRepositoryProvider),
  OnlineGameSession() => ref.watch(onlineGameRepositoryProvider),
};

/// The board offers its own retry.
Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(retry: _noRetry)
Stream<Game> game(Ref ref, GameSession session) =>
    ref.watch(sessionGameRepositoryProvider(session)).watchGame(session.gameId);
