import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_local_repository_provider.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

part 'game_provider.g.dart';

@riverpod
class GameNotifier extends _$GameNotifier {
  // Riverpod 2 keeps the notifier instance across rebuilds, so these are reset by every `build`.
  late GameRepositoryInterface _gameRepository;
  bool _isDisposed = false;
  bool _isActionRunning = false;

  String get _myId => switch (gameCreateInput) {
    GameCreateInputOffline1v1(:final fromLabel) => _playerId(CellMark.X, fromLabel),
    GameCreateInputOfflineVsAi(:final fromLabel) => _playerId(CellMark.X, fromLabel),
    GameCreateInputOnlineLobby(:final fromLabel) => _playerId(CellMark.X, fromLabel),
    GameCreateInputJoinOnlineLobby(:final toLabel) => _playerId(CellMark.O, toLabel),
  };

  bool get _isOnline => gameCreateInput is GameCreateInputOnline;

  @override
  Future<Game> build({required GameCreateInput gameCreateInput}) async {
    _isDisposed = false;
    ref.onDispose(() => _isDisposed = true);

    final Game game;
    switch (gameCreateInput) {
      case GameCreateInputOffline1v1(:final fromLabel, :final toLabel):
        final repo = ref.watch(gameLocalRepositoryProvider);
        _gameRepository = repo;
        game = await repo.createGame(fromId: _playerId(CellMark.X, fromLabel), toId: _playerId(CellMark.O, toLabel));
      case GameCreateInputOfflineVsAi(:final fromLabel, :final toLabel):
        final repo = ref.watch(gameLocalRepositoryProvider);
        _gameRepository = repo;
        game = await repo.createGame(
          fromId: _playerId(CellMark.X, fromLabel),
          toId: _playerId(CellMark.O, toLabel),
          isOpponentAi: true,
        );
      case GameCreateInputOnlineLobby(:final shareLink):
        final repo = ref.watch(gameRepositoryProvider);
        _gameRepository = repo;
        game = await repo.createGame(authorUid: _myId, shareLink: shareLink);
      case GameCreateInputJoinOnlineLobby(:final shareLink):
        final repo = ref.watch(gameRepositoryProvider);
        _gameRepository = repo;
        game = await repo.joinGame(shareLink: shareLink, joinerUid: _myId);
    }

    final gameSubscription = _gameRepository.watchGame(game.id).listen(_updateGame);
    ref.onDispose(gameSubscription.cancel);
    return game;
  }

  Future<void> startGame() => _runExclusively((game) => _gameRepository.startGame(gameId: game.id));

  Future<void> makeMove(int row, int col) => _runExclusively((game) async {
    if (game.status != GameStatus.playing || game.isAiTurn) return;

    if (_isOnline && !game.isMyTurn(_myId)) return;

    final playerId = _isOnline ? _myId : game.currentPlayerId;
    await _gameRepository.makeMove(gameId: game.id, playerId: playerId, row: row, col: col);
  });

  Future<void> startNewRound() => _runExclusively((game) => _gameRepository.startNewRound(gameId: game.id));

  static String _playerId(CellMark mark, String label) => '${mark.name}:$label';

  void _updateGame(Game game) {
    if (game != state.asData?.value) {
      state = AsyncData(game);
    }
  }

  Future<void> _runExclusively(Future<void> Function(Game game) action) async {
    final game = state.asData?.value;
    if (game == null || _isActionRunning) return;

    _isActionRunning = true;
    try {
      await action(game);
    } catch (error, stackTrace) {
      ref.read(errorLoggerServiceProvider).logError(error, stackTrace);
      if (!_isDisposed) ref.read(messageNotifierProvider.notifier).showMessage(InfoMessage.pleaseRetry);
    } finally {
      _isActionRunning = false;
    }
  }
}
