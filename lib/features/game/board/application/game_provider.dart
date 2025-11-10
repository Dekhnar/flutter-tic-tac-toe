import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/application/notifier_mounter.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_repository_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/game_local_repository_provider.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_handler.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

part 'game_provider.g.dart';

@riverpod
class GameNotifier extends _$GameNotifier with NotifierMounted, MessageHandler {
  late final GameRepositoryInterface _gameRepository;
  late final GameCreateInput _input;

  StreamSubscription<Game>? _gameSubscription;

  bool _isActionRunning = false;

  late final String _myId = switch (_input) {
    GameCreateInputOffline1v1(:final fromLabel) => "${CellMark.X.name}:$fromLabel",
    GameCreateInputOfflineVsAi(:final fromLabel) => "${CellMark.X.name}:$fromLabel",
    GameCreateInputOnlineLobby(:final fromLabel) => "${CellMark.X.name}:$fromLabel",
    GameCreateInputJoinOnlineLobby(:final toLabel) => "${CellMark.O.name}:$toLabel",
  };

  late final bool _isOffline = switch (_input) {
    GameCreateInputOffline() => true,
    GameCreateInputOnline() => false,
  };

  late final bool _isOnline = !_isOffline;

  @override
  Future<Game> build({required GameCreateInput gameCreateInput}) async {
    ref.onDispose(_dispose);

    late Game game;
    _input = gameCreateInput;
    switch (_input) {
      case GameCreateInputOffline1v1(:final fromLabel, :final toLabel):
        final repo = ref.read(gameLocalRepositoryProvider);
        final fromId = "${CellMark.X.name}:$fromLabel";
        final toId = "${CellMark.O.name}:$toLabel";
        game = await repo.createGame(fromId: fromId, toId: toId);
        _gameRepository = repo;
        break;
      case GameCreateInputOfflineVsAi(:final fromLabel, :final toLabel):
        final repo = ref.read(gameLocalRepositoryProvider);
        final fromId = "${CellMark.X.name}:$fromLabel";
        final toId = "${CellMark.O.name}:$toLabel";
        game = await repo.createGame(fromId: fromId, toId: toId);
        _gameRepository = repo;
        break;
      case GameCreateInputOnlineLobby(:final shareLink):
        final repo = ref.read(gameRepositoryProvider);
        game = await repo.createGame(authorUid: _myId, shareLink: shareLink);
        _gameRepository = repo;
        break;
      case GameCreateInputJoinOnlineLobby(:final shareLink):
        final repo = ref.read(gameRepositoryProvider);
        game = await repo.joinGame(shareLink: shareLink, joinerUid: _myId);
        _gameRepository = repo;
        break;
    }

    _gameSubscription = _gameRepository.watchGame(game.id).listen(_updateGame);
    return game;
  }

  void startGame() {
    _runWithGlobalLock(() async {
      final game = state.asData?.value;
      if (game case null) return;
      try {
        await _gameRepository.startGame(game: game);
      } catch (e) {
        showMessage(InfoMessage.pleaseRetry);
      }
    });
  }

  void makeMove(int row, int col) {
    _runWithGlobalLock(() async {
      final game = state.asData?.value;

      if (game case null) return;

      if (game.status != GameStatus.playing) return;

      if (_isOnline && !game.isMyTurn(_myId)) return;

      final playerId = _isOnline ? _myId : game.currentPlayerId;

      if (playerId.endsWith("Ai")) return;
      try {
        await _gameRepository.makeMove(game: game, playerId: playerId, row: row, col: col);
      } catch (e) {
        showMessage(InfoMessage.pleaseRetry);
      }
    });
  }

  void startNewRound() {
    _runWithGlobalLock(() async {
      final game = state.asData?.value;
      if (game case null) return;
      try {
        await _gameRepository.startNewRound(game: game);
      } catch (e) {
        showMessage(InfoMessage.pleaseRetry);
      }
    });
  }

  void _updateGame(Game game) {
    if (game != state.asData?.value) {
      state = AsyncData(game);
    }
  }

  void _dispose() {
    _gameSubscription?.cancel();
    setUnmounted();
  }

  void _runWithGlobalLock(AsyncCallback action) async {
    if (_isActionRunning && !mounted) return;
    _isActionRunning = true;
    try {
      await action();
    } finally {
      _isActionRunning = false;
    }
  }
}
