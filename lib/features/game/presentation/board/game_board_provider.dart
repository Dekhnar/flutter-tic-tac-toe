import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
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

  Future<void> makeMove(Cell cell) => _run(() {
    final game = ref.read(gameProvider(session)).requireValue;
    return _repository.makeMove(gameId: game.id, playerId: session.me ?? game.currentPlayerId, cell: cell);
  });

  Future<void> startNewRound() => _run(() => _repository.startNewRound(gameId: session.gameId));

  /// The board closes at once: a failure to leave is logged rather than shown.
  Future<void> leave() => _repository.leaveGame(session.gameId).onError(ref.read(errorLoggerProvider).log);

  GameRepository get _repository => ref.read(sessionGameRepositoryProvider(session));

  Future<void> _run(Future<void> Function() action) async {
    if (state.isLoading) return;

    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => action().withinTimeLimit(timeLimit));
    if (ref.mounted) state = result;
  }
}

/// Only a game the board shows can end for an opponent: one that failed to load leaves nothing to confirm.
@riverpod
bool leaveNeedsConfirmation(Ref ref, GameSession session) => switch (ref.watch(gameProvider(session))) {
  AsyncData(:final value) => session.leaveEndsGameForOpponent(value),
  _ => false,
};
