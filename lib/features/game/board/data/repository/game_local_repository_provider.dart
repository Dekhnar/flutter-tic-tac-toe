import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/tic_tac_toe_ai.dart';
import 'package:tic_tac_toe_app/shared/data/in_memory_store.dart';

part 'game_local_repository_provider.g.dart';

@riverpod
GameLocalRepository gameLocalRepository(Ref ref) => GameLocalRepository(stores: <String, InMemoryStore<Game>>{});

final class GameLocalRepository extends GameRepositoryInterface {
  const GameLocalRepository({
    required Map<String, InMemoryStore<Game>> stores,
    @visibleForTesting Duration aiMoveDelay = const Duration(seconds: 1),
    @visibleForTesting Clock clock = const Clock(),
    @visibleForTesting GameRules rules = const GameRules(),
  }) : _stores = stores,
       _aiMoveDelay = aiMoveDelay,
       _clock = clock,
       _rules = rules;

  final Map<String, InMemoryStore<Game>> _stores;
  final Duration _aiMoveDelay;
  final Clock _clock;
  final GameRules _rules;

  @override
  Stream<Game> watchGame(String id) => switch (_stores[id]) {
    final store? => store.stream,
    _ => const Stream.empty(),
  };

  Future<Game> createGame({required String fromId, required String toId}) async {
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
      createdAt: now,
      updatedAt: now,
    );
    _stores[id] = InMemoryStore<Game>(game);
    return game;
  }

  @override
  Future<void> startGame({required Game game}) async {
    final store = _stores[game.id];
    if (store == null) return;
    final now = _clock.now();
    store.value = game.copyWith(status: GameStatus.playing, lastPlayAt: now, updatedAt: now);
  }

  @override
  Future<void> startNewRound({required Game game}) async {
    final store = _stores[game.id];
    if (store == null) return;
    final nextRound = game.currentRoundIndex + 1;
    final nextStarter = nextRound.isEven ? game.fromId : game.toId!;
    final now = _clock.now();
    store.value = game.copyWith(
      status: GameStatus.playing,
      currentRoundIndex: nextRound,
      currentPlayerId: nextStarter,
      currentWinnerId: null,
      lastPlayAt: now,
      updatedAt: now,
      moves: const [],
      boardState: const BoardState(),
    );
    _maybePlayAiMove(store.value);
  }

  @override
  Future<void> makeMove({required Game game, required String playerId, required int row, required int col}) async {
    final store = _stores[game.id];
    if (store == null) return;

    final updated = _rules.applyMove(game: game, playerId: playerId, row: row, col: col, currentDate: _clock.now());

    if (updated == null) return;

    store.value = updated;
    await _maybePlayAiMove(store.value);
  }

  Future<void> _maybePlayAiMove(Game currentGame) async {
    final ticTacToeAI = TicTacToeAI();
    final bestCellIndex = ticTacToeAI.playIfNeeded(currentGame);
    if (bestCellIndex case final bestCellIndex? when bestCellIndex >= 0) {
      final aiRowIndex = bestCellIndex ~/ 3;
      final aiColumnIndex = bestCellIndex % 3;
      Future.microtask(() async {
        await Future.delayed(_aiMoveDelay);
        await makeMove(game: currentGame, playerId: currentGame.currentPlayerId, row: aiRowIndex, col: aiColumnIndex);
      });
    }
  }
}
