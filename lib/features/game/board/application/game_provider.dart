import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
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

  String get _myId => switch (gameCreateInput) {
    GameCreateInputOffline1v1(:final fromLabel) => _playerId(CellMark.X, fromLabel),
    GameCreateInputOfflineVsAi(:final fromLabel) => _playerId(CellMark.X, fromLabel),
    GameCreateInputOnlineLobby(:final fromLabel) => _playerId(CellMark.X, fromLabel),
    GameCreateInputJoinOnlineLobby(:final toLabel) => _playerId(CellMark.O, toLabel),
  };

  bool get _isOnline => gameCreateInput is GameCreateInputOnline;

  @override
  Stream<Game> build({required GameCreateInput gameCreateInput}) async* {
    _disposed = false;
    ref.onDispose(() => _disposed = true);

    final Game game;
    switch (gameCreateInput) {
      case GameCreateInputOffline1v1(:final fromLabel, :final toLabel):
        final repository = ref.watch(gameLocalRepositoryProvider);
        _gameRepository = repository;
        game = await repository.createGame(
          fromId: _playerId(CellMark.X, fromLabel),
          toId: _playerId(CellMark.O, toLabel),
        );
      case GameCreateInputOfflineVsAi(:final fromLabel, :final toLabel):
        final repository = ref.watch(gameLocalRepositoryProvider);
        _gameRepository = repository;
        game = await repository.createGame(
          fromId: _playerId(CellMark.X, fromLabel),
          toId: _playerId(CellMark.O, toLabel),
          vsAi: true,
        );
      case GameCreateInputOnlineLobby(:final shareLink):
        final repository = ref.watch(gameRepositoryProvider);
        _gameRepository = repository;
        game = await repository.createGame(authorUid: _myId, shareLink: shareLink);
      case GameCreateInputJoinOnlineLobby(:final shareLink):
        final repository = ref.watch(gameRepositoryProvider);
        _gameRepository = repository;
        game = await repository.joinGame(shareLink: shareLink, joinerUid: _myId);
    }

    yield* _gameRepository.watchGame(game.id);
  }

  void startGame() => unawaited(_runExclusively((game) => _gameRepository.startGame(gameId: game.id)));

  void makeMove(int row, int col) => unawaited(
    _runExclusively((game) async {
      if (game.status != GameStatus.playing || game.isAiTurn) return;

      if (_isOnline && !game.isMyTurn(_myId)) return;

      final playerId = _isOnline ? _myId : game.currentPlayerId;
      await _gameRepository.makeMove(gameId: game.id, playerId: playerId, row: row, col: col);
    }),
  );

  void startNewRound() => unawaited(_runExclusively((game) => _gameRepository.startNewRound(gameId: game.id)));

  static String _playerId(CellMark mark, String label) => '${mark.name}:$label';

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
