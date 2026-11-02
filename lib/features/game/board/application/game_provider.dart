import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_local_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

part 'game_provider.g.dart';

typedef _GameAction = Future<void> Function(Game game);

@riverpod
class GameNotifier extends _$GameNotifier {
  // Riverpod 2 keeps the notifier instance across rebuilds, so these are reset by every `build`.
  late GameRepositoryInterface _gameRepository;
  bool _actionRunning = false;
  bool _disposed = false;

  @override
  Stream<Game> build({required GameSession session}) {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    _gameRepository = switch (session) {
      LocalGameSession() => ref.watch(localGameRepositoryProvider),
      OnlineGameSession() => ref.watch(onlineGameRepositoryProvider),
    };
    return _gameRepository.watchGame(session.gameId);
  }

  void startGame() => unawaited(_runExclusively((game) => _gameRepository.startGame(gameId: game.id)));

  void makeMove(int row, int col) => unawaited(
    _runExclusively((game) async {
      final me = session.me;
      if (!game.isPlayableBy(me)) return;

      await _gameRepository.makeMove(gameId: game.id, playerId: me ?? game.currentPlayerId, row: row, col: col);
    }),
  );

  void startNewRound() => unawaited(_runExclusively((game) => _gameRepository.startNewRound(gameId: game.id)));

  Future<void> _runExclusively(_GameAction action) async {
    final game = state.valueOrNull;
    if (game == null || _actionRunning) return;

    _actionRunning = true;
    try {
      await action(game);
    } on AppException catch (refusal) {
      ref.read(errorLoggerServiceProvider).logAppException(refusal);
      _showMessage(InfoMessage.explaining(refusal));
    } catch (error, stackTrace) {
      ref.read(errorLoggerServiceProvider).logError(error, stackTrace);
      _showMessage(InfoMessage.pleaseRetry);
    } finally {
      _actionRunning = false;
    }
  }

  void _showMessage(InfoMessage message) {
    if (_disposed) return;

    ref.read(messageNotifierProvider.notifier).showMessage(message);
  }
}
