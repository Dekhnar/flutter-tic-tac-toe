import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';

const _x = 'X:Jessy';
const _o = 'O:Mario';
final _now = DateTime(2025, 1, 1);

void main() {
  const rules = GameRules();

  Game play(Game game, List<int> cells) => cells.fold(game, (game, cell) {
    final updated = rules.applyMove(
      game: game,
      playerId: game.currentPlayerId,
      row: cell ~/ 3,
      col: cell % 3,
      currentDate: _now,
    );
    expect(updated, isNotNull, reason: 'cell $cell should be playable');
    return updated!;
  });

  group('A move', () {
    test('marks the cell with the player mark and passes the turn', () {
      final game = play(_startedGame(), [4]);

      expect(game.moves.single, Move(playerId: _x, index: 4, mark: CellMark.X, round: 0, turn: 0));
      expect(game.currentPlayerId, _o);
      expect(game.status, GameStatus.playing);
    });

    test('is refused when it is not the player turn', () {
      expect(rules.applyMove(game: _startedGame(), playerId: _o, row: 0, col: 0, currentDate: _now), isNull);
    });

    test('is refused on a cell already taken', () {
      final game = play(_startedGame(), [0]);

      expect(rules.applyMove(game: game, playerId: _o, row: 0, col: 0, currentDate: _now), isNull);
    });

    test('is refused outside the board, even when row and column add up to an existing cell', () {
      expect(rules.applyMove(game: _startedGame(), playerId: _x, row: 0, col: 5, currentDate: _now), isNull);
      expect(rules.applyMove(game: _startedGame(), playerId: _x, row: -1, col: 1, currentDate: _now), isNull);
    });

    test('is refused before the game starts and after the round ends', () {
      final notStarted = _startedGame().copyWith(status: GameStatus.setup);
      final finished = play(_startedGame(), [0, 3, 1, 4, 2]);

      expect(rules.applyMove(game: notStarted, playerId: _x, row: 0, col: 0, currentDate: _now), isNull);
      expect(rules.applyMove(game: finished, playerId: _o, row: 2, col: 2, currentDate: _now), isNull);
    });

    test('is refused while no opponent has joined', () {
      final alone = _startedGame().copyWith(toId: null);

      expect(rules.applyMove(game: alone, playerId: _x, row: 0, col: 0, currentDate: _now), isNull);
    });
  });

  group('The round ends', () {
    test('when the first player completes a row', () {
      final game = play(_startedGame(), [0, 3, 1, 4, 2]);

      expect(game.status, GameStatus.finished);
      expect(game.currentWinnerId, _x);
      expect((game.fromWinCount, game.toWinCount), (1, 0));
    });

    test('when the second player completes a column', () {
      final game = play(_startedGame(), [0, 1, 3, 4, 8, 7]);

      expect(game.currentWinnerId, _o);
      expect((game.fromWinCount, game.toWinCount), (0, 1));
    });

    test('when a player completes a diagonal or the anti-diagonal', () {
      expect(play(_startedGame(), [0, 1, 4, 2, 8]).currentWinnerId, _x);
      expect(play(_startedGame(), [2, 0, 4, 1, 6]).currentWinnerId, _x);
    });

    test('in a draw when the board is full without a line', () {
      final game = play(_startedGame(), [0, 1, 2, 4, 3, 5, 7, 6, 8]);

      expect(game.status, GameStatus.finished);
      expect(game.currentWinnerId, isNull);
      expect((game.fromWinCount, game.toWinCount), (0, 0));
    });
  });

  group('A new round', () {
    test('clears the board, keeps the scores and lets the other player start', () {
      final finished = play(_startedGame(), [0, 3, 1, 4, 2]);

      final next = rules.startNewRound(game: finished, currentDate: _now);

      expect(next?.status, GameStatus.playing);
      expect(next?.currentRoundIndex, 1);
      expect(next?.currentPlayerId, _o);
      expect(next?.currentWinnerId, isNull);
      expect(next?.moves, isEmpty);
      expect(next?.boardState, const BoardState());
      expect((next?.fromWinCount, next?.toWinCount), (1, 0));
    });

    test('cannot start while the round is still being played', () {
      final playing = play(_startedGame(), [0]);

      expect(rules.startNewRound(game: playing, currentDate: _now), isNull);
    });
  });
}

Game _startedGame() => Game(
  id: 'game',
  fromId: _x,
  toId: _o,
  status: GameStatus.playing,
  currentPlayerId: _x,
  createdAt: _now,
  updatedAt: _now,
);
