import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/tic_tac_toe_ai.dart';
import 'package:tic_tac_toe_app/shared/data/in_memory_store.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

part 'game_local_repository_provider.g.dart';

@riverpod
GameLocalRepository gameLocalRepository(Ref ref) {
  final repository = GameLocalRepository(stores: <String, InMemoryStore<Game>>{});
  ref.onDispose(repository.dispose);
  return repository;
}

final class GameLocalRepository implements GameRepositoryInterface {
  const GameLocalRepository({
    @visibleForTesting TicTacToeAI ai = const TicTacToeAI(),
    @visibleForTesting Duration aiMoveDelay = const Duration(seconds: 1),
    @visibleForTesting Clock clock = const Clock(),
    @visibleForTesting GameRules rules = const GameRules(),
    required Map<String, InMemoryStore<Game>> stores,
  }) : _ai = ai,
       _aiMoveDelay = aiMoveDelay,
       _clock = clock,
       _rules = rules,
       _stores = stores;

  final TicTacToeAI _ai;
  final Duration _aiMoveDelay;
  final Clock _clock;
  final GameRules _rules;
  final Map<String, InMemoryStore<Game>> _stores;

  @override
  Stream<Game> watchGame(String gameId) => switch (_stores[gameId]) {
    final store? => store.stream,
    null => Stream.error(GameNotFoundException()),
  };

  Future<Game> createGame({required String fromId, required String toId, bool vsAi = false}) async {
    final now = _clock.now();
    final id = 'local-${now.microsecondsSinceEpoch}';
    final game = Game(
      id: id,
      fromId: fromId,
      toId: toId,
      status: GameStatus.setup,
      shareLink: null,
      moves: const [],
      boardState: const BoardState(),
      currentPlayerId: fromId,
      fromWinCount: 0,
      toWinCount: 0,
      currentRoundIndex: 0,
      currentWinnerId: null,
      lastPlayAt: now,
      vsAi: vsAi,
      createdAt: now,
      updatedAt: now,
    );
    _stores[id] = InMemoryStore<Game>(game);
    return game;
  }

  @override
  Future<void> startGame({required String gameId}) async {
    final store = _storeOf(gameId);
    if (store.value.status != GameStatus.setup) return;

    final now = _clock.now();
    store.value = store.value.copyWith(status: GameStatus.playing, lastPlayAt: now, updatedAt: now);
    _playAiMoveIfNeeded(store);
  }

  @override
  Future<void> startNewRound({required String gameId}) async {
    final store = _storeOf(gameId);

    final nextRound = _rules.startNewRound(game: store.value, currentDate: _clock.now());
    if (nextRound == null) return;

    store.value = nextRound;
    _playAiMoveIfNeeded(store);
  }

  @override
  Future<void> makeMove({required String gameId, required String playerId, required int row, required int col}) async {
    _applyMove(_storeOf(gameId), playerId: playerId, row: row, col: col);
  }

  void dispose() {
    for (final store in _stores.values) {
      store.close();
    }
    _stores.clear();
  }

  InMemoryStore<Game> _storeOf(String gameId) => _stores[gameId] ?? (throw GameNotFoundException());

  void _applyMove(InMemoryStore<Game> store, {required String playerId, required int row, required int col}) {
    store.value = _rules.applyMove(
      game: store.value,
      playerId: playerId,
      row: row,
      col: col,
      currentDate: _clock.now(),
    );
    _playAiMoveIfNeeded(store);
  }

  void _playAiMoveIfNeeded(InMemoryStore<Game> store) {
    if (!store.value.isAiTurn) return;

    // The move is chosen after the delay, from the board as it is then.
    unawaited(
      Future<void>.delayed(_aiMoveDelay, () {
        if (store.isClosed) return;

        final game = store.value;
        final aiId = game.toId;
        final cellIndex = _ai.nextMove(game);
        if (aiId == null || cellIndex == null) return;

        _applyMove(store, playerId: aiId, row: cellIndex ~/ GameRules.boardSize, col: cellIndex % GameRules.boardSize);
      }),
    );
  }
}
