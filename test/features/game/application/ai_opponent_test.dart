import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/application/ai_opponent.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

import '../../../shared/fakes/forwarding_repositories.dart';
import '../../../shared/fakes/recording_error_logger.dart';

const _almostDoneThinking = Duration(milliseconds: 999);
const _lastMillisecond = Duration(milliseconds: 1);

void main() {
  /// A started game whose board is open, in fake time: the game and the AI are watched.
  void withOpenBoard(
    void Function(FakeAsync time, _Board board) body, {
    required bool vsAi,
    bool aiMovesFail = false,
  }) => fakeAsync((time) {
    final memory = InMemoryGameRepository();
    final games = aiMovesFail ? _RefusingAiMoves(memory) : memory;
    final errors = RecordingErrorLogger();
    final container = ProviderContainer(
      overrides: [errorLoggerProvider.overrideWithValue(errors), localGameRepositoryProvider.overrideWithValue(games)],
    );

    late GameId gameId;
    unawaited(games.createGame(guestName: 'Mario', hostName: 'Jessy').then((id) => gameId = id));
    time.flushMicrotasks();
    final session = GameSession.local(gameId: gameId, vsAi: vsAi);
    container.listen(gameProvider(session), (_, _) {});
    final ai = container.listen(aiOpponentProvider(session), (_, _) {});
    time.flushMicrotasks();

    body(time, _Board(container, games, errors, session, ai));

    container.dispose();
    memory.dispose();
    time.flushMicrotasks();
  });

  test('the AI answers the player once it is done thinking, and gives the turn back', () {
    withOpenBoard(vsAi: true, (time, board) {
      board.hostPlays(const Cell(0));
      time.flushMicrotasks();

      time.elapse(_almostDoneThinking);
      expect(board.game.board.cells.nonNulls, hasLength(1));

      time.elapse(_lastMillisecond);
      expect(board.game.board[const Cell(4)], CellMark.O);
      expect(board.game.currentPlayerId, InMemoryGameRepository.hostId);
    });
  });

  test('a human opponent is never played by the AI', () {
    withOpenBoard(vsAi: false, (time, board) {
      board.hostPlays(const Cell(0));
      time.flushMicrotasks();

      time.elapse(const Duration(minutes: 1));

      expect(board.game.board.cells.nonNulls, hasLength(1));
      expect(board.game.currentPlayerId, InMemoryGameRepository.guestId);
    });
  });

  test('the AI stops playing once the board closes, even mid-thought', () {
    withOpenBoard(vsAi: true, (time, board) {
      board.hostPlays(const Cell(0));
      time.flushMicrotasks();
      time.elapse(_almostDoneThinking);

      board.closeAi();
      time.elapse(const Duration(minutes: 1));

      expect(board.game.board.cells.nonNulls, hasLength(1));
    });
  });

  test('the AI makes no move once the player leaves, even one it is thinking about', () {
    withOpenBoard(vsAi: true, (time, board) {
      board.hostPlays(const Cell(0));
      time.flushMicrotasks();
      time.elapse(_almostDoneThinking);

      board.leave();
      time.elapse(const Duration(minutes: 1));

      expect(board.errors.errors, isEmpty);
      expect(board.game.board.cells.nonNulls, hasLength(1));
    });
  });

  test('a move the AI could not make is reported', () {
    withOpenBoard(vsAi: true, aiMovesFail: true, (time, board) {
      board.hostPlays(const Cell(0));
      time.flushMicrotasks();

      time.elapse(const Duration(seconds: 1));

      expect(board.errors.errors, [isA<_AiMoveFailure>()]);
    });
  });
}

final class _Board {
  _Board(this._container, this._games, this.errors, this._session, this._ai);

  final ProviderContainer _container;
  final LocalGameRepository _games;

  final RecordingErrorLogger errors;
  final GameSession _session;
  final ProviderSubscription<void> _ai;

  Game get game => _container.read(gameProvider(_session)).requireValue;

  void hostPlays(Cell cell) =>
      unawaited(_games.makeMove(gameId: _session.gameId, playerId: InMemoryGameRepository.hostId, cell: cell));

  void closeAi() => _ai.close();

  /// What leaving the board does, the AI first: its game is then forgotten.
  void leave() {
    _container.read(aiOpponentProvider(_session).notifier).stop();
    unawaited(_games.leaveGame(_session.gameId));
  }
}

/// Local games where the AI's moves fail.
final class _RefusingAiMoves extends ForwardingLocalGameRepository {
  _RefusingAiMoves(super.inner);

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell}) async {
    if (playerId == InMemoryGameRepository.guestId) throw _AiMoveFailure();

    await inner.makeMove(gameId: gameId, playerId: playerId, cell: cell);
  }
}

final class _AiMoveFailure implements Exception {}
