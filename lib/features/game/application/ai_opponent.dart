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

/// Plays the AI's turns in the game of [session] for as long as it is watched, until [stop]. Every change of the game
/// restarts the thinking, so the AI always plays on the game as it is.
@riverpod
class AiOpponentNotifier extends _$AiOpponentNotifier {
  Timer? _thinking;
  bool _stopped = false;

  @override
  void build(GameSession session) {
    if (!session.hasAi) return;

    final thinkingTime = ref.watch(aiThinkingTimeProvider);
    final repository = ref.watch(sessionGameRepositoryProvider(session));
    final errorLogger = ref.watch(errorLoggerProvider);
    ref.onDispose(() => _thinking?.cancel());

    ref.listen(gameProvider(session), fireImmediately: true, (_, next) {
      _thinking?.cancel();
      if (next.value case final game? when session.isAiTurn(game) && !_stopped) {
        _thinking = Timer(thinkingTime, () => unawaited(_play(game, repository).onError(errorLogger.log)));
      }
    });
  }

  /// The player is leaving the game: the AI makes no more move in it, even one it is thinking about.
  void stop() {
    _stopped = true;
    _thinking?.cancel();
  }
}

Future<void> _play(Game game, GameRepository repository) async {
  final cell = const TicTacToeAI().nextMove(game.board, mark: game.markOf(game.currentPlayerId));
  if (cell != null) await repository.makeMove(gameId: game.id, playerId: game.currentPlayerId, cell: cell);
}
