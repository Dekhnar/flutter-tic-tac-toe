import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

part 'game_provider.g.dart';

@riverpod
GameRepositoryInterface sessionGameRepository(Ref ref, GameSession session) => switch (session) {
  LocalGameSession() => ref.watch(localGameRepositoryProvider),
  OnlineGameSession() => ref.watch(onlineGameRepositoryProvider),
};

/// The board offers its own retry: a game that failed to load is not retried behind the player's back.
Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(retry: _noRetry)
Stream<Game> game(Ref ref, GameSession session) =>
    ref.watch(sessionGameRepositoryProvider(session)).watchGame(session.gameId);

/// What the player does on the board: loading while the game handles it, the error when it refused or failed.
@riverpod
class GameActions extends _$GameActions {
  @override
  FutureOr<void> build(GameSession session) {}

  Future<void> startGame() => _run((repository) => repository.startGame(gameId: session.gameId));

  Future<void> makeMove(Cell cell) => _run((repository) {
    final game = ref.read(gameProvider(session)).requireValue;
    return repository.makeMove(gameId: game.id, playerId: session.me ?? game.currentPlayerId, cell: cell);
  });

  Future<void> startNewRound() => _run((repository) => repository.startNewRound(gameId: session.gameId));

  /// The player leaves the game for good. The board closes right away: the leave runs to its end on its own, and a
  /// failure is logged rather than shown, the player having left already.
  Future<void> leave() {
    final errorLogger = ref.read(errorLoggerProvider);
    return ref.read(sessionGameRepositoryProvider(session)).leaveGame(session.gameId).onError(errorLogger.log);
  }

  Future<void> _run(Future<void> Function(GameRepositoryInterface repository) action) async {
    // The board disables its controls while an action runs.
    if (state.isLoading) return;

    final repository = ref.read(sessionGameRepositoryProvider(session));
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => action(repository));
    if (ref.mounted) state = result;
  }
}
