import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/application/ai_opponent.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';

const _almostDoneThinking = Duration(milliseconds: 999);
const _lastMillisecond = Duration(milliseconds: 1);

void main() {
  /// A started game whose board is open, in fake time: the game and the AI are watched.
  void withOpenBoard(void Function(FakeAsync time, _Board board) body, {required bool vsAi}) => fakeAsync((time) {
    final games = InMemoryGameRepository();
    final container = ProviderContainer(overrides: [localGameRepositoryProvider.overrideWithValue(games)]);

    late GameId gameId;
    games.createGame(guestName: 'Mario', hostName: 'Jessy').then((id) => gameId = id);
    time.flushMicrotasks();
    final session = GameSession.local(gameId: gameId, vsAi: vsAi);
    container.listen(gameProvider(session), (_, _) {});
    final ai = container.listen(aiOpponentProvider(session), (_, _) {});
    time.flushMicrotasks();

    body(time, _Board(container, session, ai));

    container.dispose();
    games.dispose();
    time.flushMicrotasks();
  });

  test('the AI answers the player once it is done thinking, and gives the turn back', () {
    withOpenBoard(vsAi: true, (time, board) {
      board.playerPlays(const Cell(0));
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
      board.playerPlays(const Cell(0));
      time.flushMicrotasks();

      time.elapse(const Duration(minutes: 1));

      expect(board.game.board.cells.nonNulls, hasLength(1));
      expect(board.game.currentPlayerId, InMemoryGameRepository.guestId);
    });
  });

  test('the AI stops playing once the board closes, even mid-thought', () {
    withOpenBoard(vsAi: true, (time, board) {
      board.playerPlays(const Cell(0));
      time.flushMicrotasks();
      time.elapse(_almostDoneThinking);

      board.closeAi();
      time.elapse(const Duration(minutes: 1));

      expect(board.game.board.cells.nonNulls, hasLength(1));
    });
  });
}

final class _Board {
  _Board(this._container, this._session, this._ai);

  final ProviderContainer _container;
  final GameSession _session;
  final ProviderSubscription<void> _ai;

  Game get game => _container.read(gameProvider(_session)).requireValue;

  void playerPlays(Cell cell) => _container.read(gameActionsProvider(_session).notifier).makeMove(cell);

  void closeAi() => _ai.close();
}
