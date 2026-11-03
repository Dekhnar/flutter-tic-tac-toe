import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

part 'game_board_provider.g.dart';

/// What the player does on the board: loading while the game handles it, then the error if it was refused or failed.
/// One action at a time, each given [timeLimit] to complete.
@riverpod
class GameBoardActionsNotifier extends _$GameBoardActionsNotifier {
  static const timeLimit = Duration(seconds: 10);

  @override
  FutureOr<void> build(GameSession session) {}

  Future<void> startGame() => _run(() => ref.read(onlineGameRepositoryProvider).startGame(gameId: session.gameId));

  Future<void> makeMove(Cell cell) => _run(move: cell, () {
    final game = ref.read(gameProvider(session)).requireValue;
    final player = session.playsFor(game) ?? (throw MoveNotYourTurnException());
    return _repository.makeMove(gameId: game.id, playerId: player, cell: cell);
  });

  Future<void> startNewRound() => _run(() => _repository.startNewRound(gameId: session.gameId));

  /// The board closes at once: a failure to leave is logged rather than shown.
  Future<void> leave() => _repository.leaveGame(session.gameId).onError(ref.read(errorLoggerProvider).log);

  GameRepository get _repository => ref.read(sessionGameRepositoryProvider(session));

  Future<void> _run(Future<void> Function() action, {Cell? move}) async {
    if (state.isLoading) return;

    state = const AsyncLoading();
    if (move != null) ref.read(pendingMoveProvider(session).notifier).show(move);
    final result = await AsyncValue.guard(() => action().withinTimeLimit(timeLimit));
    if (!ref.mounted) return;

    state = result;
    if (result.hasError) ref.read(pendingMoveProvider(session).notifier).show(null);
  }
}

/// The cell of a move this device made, until the game shows it: online, the game comes back on its own stream, after
/// the server's answer. Only [GameBoardActionsNotifier] sets it.
@riverpod
class PendingMoveNotifier extends _$PendingMoveNotifier {
  @override
  Cell? build(GameSession session) {
    ref.listen(gameProvider(session), (_, next) {
      if (state case final cell? when next.value?.board[cell] != null) state = null;
    });
    return null;
  }

  void show(Cell? move) => state = move;
}

/// Only a game the board shows can end for an opponent: one that failed to load leaves nothing to confirm.
@riverpod
bool leaveNeedsConfirmation(Ref ref, GameSession session) => switch (ref.watch(gameProvider(session))) {
  AsyncData(:final value) => session.leaveEndsGameForOpponent(value),
  _ => false,
};
