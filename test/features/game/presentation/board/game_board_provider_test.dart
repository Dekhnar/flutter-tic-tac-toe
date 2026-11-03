import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/game_board_provider.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

const _gameId = GameId('ABCDEF');
const _jessy = PlayerId('jessy-uid');
const _online = GameSession.online(gameId: _gameId, me: _jessy);

const _waiting = Game(
  currentPlayerId: _jessy,
  host: Player(id: _jessy, name: 'Jessy'),
  id: _gameId,
  status: GameStatus.setup,
);
final _withOpponent = _waiting.copyWith(guest: const Player(id: PlayerId('luigi-uid'), name: 'Luigi'));

void main() {
  group('The actions on a local board', () {
    late _SlowMoves games;
    late ProviderContainer container;
    late GameSession session;

    /// A started local game whose board is open; its moves land once [_SlowMoves.answer] completes.
    Future<void> openBoard() async {
      final memory = InMemoryGameRepository();
      addTearDown(memory.dispose);
      games = _SlowMoves(memory);
      container = ProviderContainer(overrides: [localGameRepositoryProvider.overrideWithValue(games)]);
      addTearDown(container.dispose);
      session = GameSession.local(gameId: await games.createGame(guestName: 'Mario', hostName: 'Jessy'));
      container.listen(gameProvider(session), (_, _) {});
      container.listen(gameBoardActionsProvider(session), (_, _) {});
      await container.read(gameProvider(session).future);
    }

    GameBoardActionsNotifier actions() => container.read(gameBoardActionsProvider(session).notifier);

    AsyncValue<void> state() => container.read(gameBoardActionsProvider(session));

    test('run one at a time: a tap while a move is on its way is ignored', () async {
      await openBoard();

      final first = actions().makeMove(const Cell(0));
      final second = actions().makeMove(const Cell(1));
      games.answer.complete();
      await Future.wait([first, second]);

      expect(games.moves, [const Cell(0)]);
      expect(state(), const AsyncData<void>(null));
    });

    test('a refused move leaves the reason to show, and the next move clears it', () async {
      await openBoard();
      games.answer.complete();

      await actions().makeMove(const Cell(9));
      expect(state().error, isA<MoveCellIndexInvalidException>());

      await actions().makeMove(const Cell(0));
      expect(state(), const AsyncData<void>(null));
    });

    test('a move not done in time is given up: the server is not answering', () {
      fakeAsync((time) {
        unawaited(openBoard());
        time.flushMicrotasks();

        unawaited(actions().makeMove(const Cell(0)));
        time.elapse(GameBoardActionsNotifier.timeLimit - const Duration(milliseconds: 1));
        expect(state().isLoading, isTrue);
        time.elapse(const Duration(milliseconds: 1));

        expect(state().error, isA<ServerNotAnsweringException>());
      });
    });
  });

  group('The board asks before leaving', () {
    late StreamController<Game> server;
    late ProviderContainer container;

    setUp(() {
      server = StreamController<Game>();
      addTearDown(server.close);
      container = ProviderContainer(overrides: [gameProvider(_online).overrideWith((ref) => server.stream)]);
      addTearDown(container.dispose);
      container.listen(leaveNeedsConfirmationProvider(_online), (_, _) {});
    });

    bool asks() => container.read(leaveNeedsConfirmationProvider(_online));

    test('while an opponent sits in the game it shows', () async {
      server.add(_withOpponent);
      await pumpEventQueue();

      expect(asks(), isTrue);
    });

    test('not once that game is gone from the server, though the board still shows it', () async {
      server.add(_withOpponent);
      await pumpEventQueue();

      server.addError(GameNotFoundException());
      await pumpEventQueue();

      expect(container.read(gameProvider(_online)).value, _withOpponent);
      expect(asks(), isFalse);
    });
  });
}

/// Local games whose moves land once [answer] completes.
final class _SlowMoves implements LocalGameRepository {
  _SlowMoves(this._games);

  final InMemoryGameRepository _games;
  final answer = Completer<void>();
  final moves = <Cell>[];

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell}) async {
    moves.add(cell);
    await answer.future;
    await _games.makeMove(gameId: gameId, playerId: playerId, cell: cell);
  }

  @override
  Future<GameId> createGame({required String guestName, required String hostName}) =>
      _games.createGame(guestName: guestName, hostName: hostName);

  @override
  Future<void> leaveGame(GameId gameId) => _games.leaveGame(gameId);

  @override
  Future<void> startNewRound({required GameId gameId}) => _games.startNewRound(gameId: gameId);

  @override
  Stream<Game> watchGame(GameId gameId) => _games.watchGame(gameId);
}
