import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

part 'game_provider.g.dart';

/// The online games, for as long as online play is available: an online session only exists then.
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

/// The board offers its own retry: a game that failed to load is not retried behind the player's back.
Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(retry: _noRetry)
Stream<Game> game(Ref ref, GameSession session) =>
    ref.watch(sessionGameRepositoryProvider(session)).watchGame(session.gameId);

/// What is done on the board, by the player or the AI: loading while the game handles it, the error when it refused
/// or failed.
@riverpod
class GameActionsNotifier extends _$GameActionsNotifier {
  @override
  FutureOr<void> build(GameSession session) {}

  /// Only an online game waits to be started: a local one starts as soon as it is created.
  Future<void> startGame() => _run(() => ref.read(onlineGameRepositoryProvider).startGame(gameId: session.gameId));

  Future<void> makeMove(Cell cell) => _run(() {
    final game = ref.read(gameProvider(session)).requireValue;
    return _repository.makeMove(gameId: game.id, playerId: session.me ?? game.currentPlayerId, cell: cell);
  });

  Future<void> startNewRound() => _run(() => _repository.startNewRound(gameId: session.gameId));

  /// The player leaves the game for good. The board closes right away: the leave runs to its end on its own, and a
  /// failure is logged rather than shown, the player having left already.
  Future<void> leave() {
    final errorLogger = ref.read(errorLoggerProvider);
    return _repository.leaveGame(session.gameId).onError(errorLogger.log);
  }

  GameRepository get _repository => ref.read(sessionGameRepositoryProvider(session));

  Future<void> _run(Future<void> Function() action) async {
    // The board disables its controls while an action runs.
    if (state.isLoading) return;

    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    if (ref.mounted) state = result;
  }
}
