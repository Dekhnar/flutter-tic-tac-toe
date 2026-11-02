import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_rules.dart';

const _x = PlayerId('jessy');
const _o = PlayerId('mario');

void main() {
  const rules = GameRules();

  Game play(Game game, List<int> cells) =>
      cells.fold(game, (game, cell) => rules.applyMove(game: game, playerId: game.currentPlayerId, cell: Cell(cell)));

  Game Function() move(Game game, {required PlayerId playerId, required int cell}) =>
      () => rules.applyMove(game: game, playerId: playerId, cell: Cell(cell));

  group('Joining', () {
    final waiting = _startedGame().copyWith(status: GameStatus.setup, guest: null);

    test('seats the guest in the free seat, by name', () {
      final joined = rules.join(waiting, guest: _o, guestName: 'Mario');

      expect((joined?.guest?.id, joined?.guest?.name), (_o, 'Mario'));
    });

    test('again, or as the host, changes nothing', () {
      expect(rules.join(_startedGame(), guest: _o, guestName: 'Mario'), isNull);
      expect(rules.join(waiting, guest: _x, guestName: 'Jessy'), isNull);
    });

    test('is refused once a player left the game', () {
      final abandoned = waiting.copyWith(status: GameStatus.abandoned);

      expect(() => rules.join(abandoned, guest: _o, guestName: 'Mario'), throwsA(isA<GameAbandonedException>()));
    });

    test('is refused once both seats are taken', () {
      expect(
        () => rules.join(_startedGame(), guest: const PlayerId('luigi'), guestName: 'Luigi'),
        throwsA(isA<GameAlreadyFullException>()),
      );
    });
  });

  group('Leaving', () {
    test('ends the game for both players, whatever its state', () {
      for (final status in [GameStatus.setup, GameStatus.playing, GameStatus.finished]) {
        expect(rules.leave(_startedGame().copyWith(status: status))?.status, GameStatus.abandoned);
      }
    });

    test('again changes nothing', () {
      expect(rules.leave(_startedGame().copyWith(status: GameStatus.abandoned)), isNull);
    });

    test('stops the moves, the start and the next round', () {
      final abandoned = _startedGame().copyWith(status: GameStatus.abandoned);

      expect(move(abandoned, playerId: _x, cell: 0), throwsA(isA<GameAbandonedException>()));
      expect(rules.start(abandoned), isNull);
      expect(rules.startNewRound(abandoned), isNull);
    });
  });

  group('Starting the game', () {
    test('lets the players play', () {
      expect(rules.start(_startedGame().copyWith(status: GameStatus.setup))?.status, GameStatus.playing);
    });

    test('again changes nothing', () {
      expect(rules.start(_startedGame()), isNull);
    });

    test('is refused while no opponent has joined', () {
      final alone = _startedGame().copyWith(status: GameStatus.setup, guest: null);

      expect(() => rules.start(alone), throwsA(isA<MoveOpponentMissingException>()));
    });
  });

  group('A move', () {
    test('marks the cell with the player mark and passes the turn', () {
      final game = play(_startedGame(), [4]);

      expect(game.board, Board.empty.play(const Cell(4), CellMark.X));
      expect(game.currentPlayerId, _o);
      expect(game.status, GameStatus.playing);
    });

    test('is refused when it is not the player turn', () {
      expect(move(_startedGame(), playerId: _o, cell: 0), throwsA(isA<MoveNotYourTurnException>()));
    });

    test('is refused on a cell already taken', () {
      final game = play(_startedGame(), [0]);

      expect(move(game, playerId: _o, cell: 0), throwsA(isA<MoveCellAlreadyTakenException>()));
    });

    test('is refused outside the board', () {
      expect(move(_startedGame(), playerId: _x, cell: 9), throwsA(isA<MoveCellIndexInvalidException>()));
      expect(move(_startedGame(), playerId: _x, cell: -1), throwsA(isA<MoveCellIndexInvalidException>()));
    });

    test('is refused before the game starts and after the round ends', () {
      final notStarted = _startedGame().copyWith(status: GameStatus.setup);
      final finished = play(_startedGame(), [0, 3, 1, 4, 2]);

      expect(move(notStarted, playerId: _x, cell: 0), throwsA(isA<MoveGameNotStartedException>()));
      expect(move(finished, playerId: _o, cell: 8), throwsA(isA<MoveGameFinishedException>()));
    });

    test('is refused while no opponent has joined', () {
      final alone = _startedGame().copyWith(guest: null);

      expect(move(alone, playerId: _x, cell: 0), throwsA(isA<MoveOpponentMissingException>()));
    });
  });

  group('The round ends', () {
    test('when the first player completes a row', () {
      final game = play(_startedGame(), [0, 3, 1, 4, 2]);

      expect(game.status, GameStatus.finished);
      expect(game.currentWinnerId, _x);
      expect((game.host.wins, game.guest?.wins), (1, 0));
    });

    test('when the second player completes a column', () {
      final game = play(_startedGame(), [0, 1, 3, 4, 8, 7]);

      expect(game.currentWinnerId, _o);
      expect((game.host.wins, game.guest?.wins), (0, 1));
    });

    test('when a player completes a diagonal or the anti-diagonal', () {
      expect(play(_startedGame(), [0, 1, 4, 2, 8]).currentWinnerId, _x);
      expect(play(_startedGame(), [2, 0, 4, 1, 6]).currentWinnerId, _x);
    });

    test('in a draw when the board is full without a line', () {
      final game = play(_startedGame(), [0, 1, 2, 4, 3, 5, 7, 6, 8]);

      expect(game.status, GameStatus.finished);
      expect(game.currentWinnerId, isNull);
      expect((game.host.wins, game.guest?.wins), (0, 0));
    });
  });

  group('A new round', () {
    test('clears the board, keeps the scores and lets the other player start', () {
      final finished = play(_startedGame(), [0, 3, 1, 4, 2]);

      final next = rules.startNewRound(finished);

      expect(next?.status, GameStatus.playing);
      expect(next?.currentRoundIndex, 1);
      expect(next?.currentPlayerId, _o);
      expect(next?.currentWinnerId, isNull);
      expect(next?.board, Board.empty);
      expect((next?.host.wins, next?.guest?.wins), (1, 0));
    });

    test('cannot start while the round is still being played', () {
      final playing = play(_startedGame(), [0]);

      expect(rules.startNewRound(playing), isNull);
    });
  });
}

Game _startedGame() => const Game(
  currentPlayerId: _x,
  guest: Player(id: _o, name: 'Mario'),
  host: Player(id: _x, name: 'Jessy'),
  id: GameId('game'),
  status: GameStatus.playing,
);
