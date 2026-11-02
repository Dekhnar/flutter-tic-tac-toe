import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/tic_tac_toe_ai.dart';
import 'package:tic_tac_toe_app/shared/data/in_memory_store.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';

final class InMemoryGameRepository implements LocalGameRepositoryInterface {
  const InMemoryGameRepository({
    @visibleForTesting TicTacToeAI ai = const TicTacToeAI(),
    @visibleForTesting Duration aiMoveDelay = const Duration(seconds: 1),
    @visibleForTesting Clock clock = const Clock(),
    @visibleForTesting GameRules rules = const GameRules(),
    required Map<GameId, InMemoryStore<Game>> stores,
  }) : _ai = ai,
       _aiMoveDelay = aiMoveDelay,
       _clock = clock,
       _rules = rules,
       _stores = stores;

  static const guestId = PlayerId('guest');
  static const hostId = PlayerId('host');

  final TicTacToeAI _ai;
  final Duration _aiMoveDelay;
  final Clock _clock;
  final GameRules _rules;
  final Map<GameId, InMemoryStore<Game>> _stores;

  @override
  Stream<Game> watchGame(GameId gameId) => switch (_stores[gameId]) {
    final store? => store.stream,
    null => Stream.error(GameNotFoundException()),
  };

  @override
  Future<GameId> createGame({required String guestName, required String hostName, required bool vsAi}) async {
    final now = _clock.now();
    final gameId = GameId('local-${now.microsecondsSinceEpoch}');
    _stores[gameId] = InMemoryStore<Game>(
      Game(
        createdAt: now,
        currentPlayerId: hostId,
        fromId: hostId,
        fromName: hostName,
        id: gameId,
        status: GameStatus.setup,
        toId: guestId,
        toName: guestName,
        updatedAt: now,
        vsAi: vsAi,
      ),
    );
    return gameId;
  }

  @override
  Future<void> startGame({required GameId gameId}) async {
    final store = _storeOf(gameId);
    if (store.value.status != GameStatus.setup) return;

    final now = _clock.now();
    store.value = store.value.copyWith(status: GameStatus.playing, lastPlayAt: now, updatedAt: now);
    _playAiMoveIfNeeded(store);
  }

  @override
  Future<void> startNewRound({required GameId gameId}) async {
    final store = _storeOf(gameId);

    final nextRound = _rules.startNewRound(game: store.value, currentDate: _clock.now());
    if (nextRound == null) return;

    store.value = nextRound;
    _playAiMoveIfNeeded(store);
  }

  @override
  Future<void> makeMove({
    required GameId gameId,
    required PlayerId playerId,
    required int row,
    required int col,
  }) async {
    _applyMove(_storeOf(gameId), playerId: playerId, row: row, col: col);
  }

  @override
  void endGame(GameId gameId) => _stores.remove(gameId)?.close();

  void dispose() {
    for (final store in _stores.values) {
      store.close();
    }
    _stores.clear();
  }

  InMemoryStore<Game> _storeOf(GameId gameId) => _stores[gameId] ?? (throw GameNotFoundException());

  void _applyMove(InMemoryStore<Game> store, {required PlayerId playerId, required int row, required int col}) {
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
