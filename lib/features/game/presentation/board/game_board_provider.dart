import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/ai_opponent.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

part 'game_board_provider.g.dart';

/// What the player does on the board: loading until the board shows the action, then the error if it was refused or
/// failed. One action at a time, each given [timeLimit] to complete.
@riverpod
class GameBoardActionsNotifier extends _$GameBoardActionsNotifier {
  static const timeLimit = Duration(seconds: 10);

  @override
  FutureOr<void> build(GameSession session) {}

  Future<void> startGame() => _run(() async {
    await ref.read(onlineGameRepositoryProvider).startGame(gameId: session.gameId);
    await gameShowing(ref, session, (game) => game.status != GameStatus.setup);
  });

  /// Ignores a move the game as it is now does not offer this device, like a second tap landing in the same frame.
  Future<void> makeMove(Cell cell) async {
    final game = ref.read(gameProvider(session)).value;
    if (game == null || !session.canPlayAt(game, cell)) return;

    await _run(move: cell, () async {
      await _repository.makeMove(gameId: game.id, playerId: game.currentPlayerId, cell: cell);
      await gameShowing(ref, session, (shown) => shown != game);
    });
  }

  Future<void> startNewRound() => _run(() async {
    await _repository.startNewRound(gameId: session.gameId);
    await gameShowing(ref, session, (game) => game.status != GameStatus.finished);
  });

  /// The board closes at once: a failure to leave is logged rather than shown.
  Future<void> leave() {
    ref.read(aiOpponentProvider(session).notifier).stop();
    return _repository.leaveGame(session.gameId).onError(ref.read(errorLoggerProvider).log);
  }

  GameRepository get _repository => ref.read(sessionGameRepositoryProvider(session));

  Future<void> _run(Future<void> Function() action, {Cell? move}) async {
    if (state.isLoading) return;

    state = const AsyncLoading();
    ref.read(pendingMoveProvider(session).notifier).show(move);
    final result = await AsyncValue.guard(() => action().withinTimeLimit(timeLimit));
    if (!ref.mounted) return;

    state = result;
    ref.read(pendingMoveProvider(session).notifier).show(null);
  }
}

/// The cell of the move [GameBoardActionsNotifier] runs, for as long as it runs.
@riverpod
class PendingMoveNotifier extends _$PendingMoveNotifier {
  @override
  Cell? build(GameSession session) => null;

  void show(Cell? move) => state = move;
}

/// Whether leaving ends the game the board last showed for an opponent. Before the first one shows, an opponent may sit
/// in an online game already; a game gone from the server ends for nobody.
@riverpod
bool leaveNeedsConfirmation(Ref ref, GameSession session) {
  final game = ref.watch(gameProvider(session));
  if (game.error is GameNotFoundException) return false;

  return switch (game.value) {
    final value? => session.leaveEndsGameForOpponent(value),
    null => session is OnlineGameSession,
  };
}

/// Whether an online opponent has not played for [inactiveAfter] while it is their turn: their app may be closed or
/// offline. Any change of the game starts the wait again.
@riverpod
class OpponentInactiveNotifier extends _$OpponentInactiveNotifier {
  static const inactiveAfter = Duration(minutes: 1);

  @override
  bool build(GameSession session) {
    final awaited = ref.watch(
      gameProvider(session).select(
        (asyncGame) => switch (asyncGame.value) {
          final Game game when game.status == GameStatus.playing && !session.canPlay(game) => game,
          _ => null,
        },
      ),
    );
    if (session.me == null || awaited == null) return false;

    final timer = Timer(inactiveAfter, () => state = true);
    ref.onDispose(timer.cancel);
    return false;
  }
}
