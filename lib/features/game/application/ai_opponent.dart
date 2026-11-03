import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/tic_tac_toe_ai.dart';

part 'ai_opponent.g.dart';

/// How long the AI seems to think: the player sees their own move land before the answer.
@riverpod
Duration aiThinkingTime(Ref ref) => const Duration(seconds: 1);

/// Plays the AI's turns in the game of [session], as the player's moves are played: through [GameActionsNotifier].
@riverpod
void aiOpponent(Ref ref, GameSession session) {
  final thinkingTime = ref.watch(aiThinkingTimeProvider);
  final actions = ref.watch(gameActionsProvider(session).notifier);
  Timer? thinking;
  ref.onDispose(() => thinking?.cancel());

  ref.listen(gameProvider(session), fireImmediately: true, (_, next) {
    thinking?.cancel();
    if (next.value case final game? when session.isAiTurn(game)) {
      thinking = Timer(thinkingTime, () => _play(ref.read(gameProvider(session)).value, session, actions));
    }
  });
}

/// The AI picks its cell once it is done thinking, on the board as it is then.
void _play(Game? game, GameSession session, GameActionsNotifier actions) {
  if (game == null || !session.isAiTurn(game)) return;

  final cell = const TicTacToeAI().nextMove(game.board, mark: game.markOf(game.currentPlayerId));
  if (cell != null) unawaited(actions.makeMove(cell));
}
