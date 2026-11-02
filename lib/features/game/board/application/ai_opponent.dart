import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/tic_tac_toe_ai.dart';

part 'ai_opponent.g.dart';

/// How long the AI seems to think: the player sees their own move land before the answer.
@riverpod
Duration aiThinkingTime(Ref ref) => const Duration(seconds: 1);

/// Plays the AI's turns in the game of [session], as the player's moves are played: through [GameActions].
@riverpod
void aiOpponent(Ref ref, GameSession session) {
  final thinkingTime = ref.watch(aiThinkingTimeProvider);
  final actions = ref.watch(gameActionsProvider(session).notifier);
  Timer? thinking;
  ref.onDispose(() => thinking?.cancel());

  ref.listen(gameProvider(session), fireImmediately: true, (_, next) {
    thinking?.cancel();
    if (next.value?.isAiTurn != true) return;

    // The AI picks its cell once it is done thinking, on the board as it is then.
    thinking = Timer(thinkingTime, () {
      final game = ref.read(gameProvider(session)).value;
      final cell = game == null ? null : const TicTacToeAI().nextMove(game);
      if (cell == null) return;

      unawaited(actions.makeMove(cell ~/ Board.size, cell % Board.size));
    });
  });
}
