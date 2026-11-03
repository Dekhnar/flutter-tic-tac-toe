import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/tic_tac_toe_ai.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

part 'ai_opponent.g.dart';

/// Gives the player time to see their own move land before the answer.
@riverpod
Duration aiThinkingTime(Ref ref) => const Duration(seconds: 1);

/// Plays the AI's turns in the game of [session] for as long as it is watched. Every change of the game restarts the
/// thinking, so the AI always plays on the game as it is.
@riverpod
void aiOpponent(Ref ref, GameSession session) {
  if (!session.hasAi) return;

  final thinkingTime = ref.watch(aiThinkingTimeProvider);
  final repository = ref.watch(sessionGameRepositoryProvider(session));
  final errorLogger = ref.watch(errorLoggerProvider);
  Timer? thinking;
  ref.onDispose(() => thinking?.cancel());

  ref.listen(gameProvider(session), fireImmediately: true, (_, next) {
    thinking?.cancel();
    if (next.value case final game? when session.isAiTurn(game)) {
      thinking = Timer(thinkingTime, () => unawaited(_play(game, repository).onError(errorLogger.log)));
    }
  });
}

Future<void> _play(Game game, GameRepository repository) async {
  final cell = const TicTacToeAI().nextMove(game.board, mark: game.markOf(game.currentPlayerId));
  if (cell != null) await repository.makeMove(gameId: game.id, playerId: game.currentPlayerId, cell: cell);
}
