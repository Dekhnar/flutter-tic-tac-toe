import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/tic_tac_toe_ai.dart';

const _player = PlayerId('host');
const _ai = PlayerId('guest');

void main() {
  const ai = TicTacToeAI();

  test('the AI does not play during the player turn', () {
    expect(ai.nextMove(_game(xCells: [], oCells: [], currentPlayerId: _player)), isNull);
  });

  test('the AI does not play for a human opponent', () {
    final game = _game(xCells: [0], oCells: [], currentPlayerId: _ai).copyWith(vsAi: false);

    expect(ai.nextMove(game), isNull);
  });

  test('the AI wins rather than blocks when it can do both', () {
    // X X .      The AI (O) can block the top row on 2, or win the middle row on 4.
    // O . O
    // X . .
    final game = _game(xCells: [0, 1, 6], oCells: [3, 5], currentPlayerId: _ai);

    expect(ai.nextMove(game), 4);
  });

  test('the AI blocks the line the player is about to complete', () {
    final game = _game(xCells: [0, 4], oCells: [1], currentPlayerId: _ai);

    expect(ai.nextMove(game), 8);
  });

  test('the AI takes the center first, then a corner', () {
    expect(ai.nextMove(_game(xCells: [0], oCells: [], currentPlayerId: _ai)), 4);
    expect(ai.nextMove(_game(xCells: [4], oCells: [], currentPlayerId: _ai)), 0);
  });

  for (final (opener, firstPlayer) in [('the player', _player), ('the AI', _ai)]) {
    test('the AI never loses, whatever the player does, when $opener opens the round', () {
      const rules = GameRules();
      final finishedGames = <Game>[];

      Game play(Game game, PlayerId player, int cell) =>
          rules.applyMove(game: game, playerId: player, row: cell ~/ Board.size, col: cell % Board.size);

      void playEveryAnswer(Game game) {
        if (game.status == GameStatus.finished) {
          finishedGames.add(game);
          return;
        }
        if (game.isAiTurn) {
          final cell = ai.nextMove(game) ?? (throw TestFailure('The AI passed its turn on ${game.board}'));
          return playEveryAnswer(play(game, _ai, cell));
        }

        for (final cell in Iterable.generate(Board.cellCount).where((cell) => game.board[cell] == null)) {
          playEveryAnswer(play(game, _player, cell));
        }
      }

      playEveryAnswer(_game(xCells: [], oCells: [], currentPlayerId: firstPlayer));

      expect(finishedGames, isNotEmpty);
      expect(finishedGames.where((game) => game.currentWinnerId == _player), isEmpty);
    });
  }
}

Game _game({required List<int> xCells, required List<int> oCells, required PlayerId currentPlayerId}) {
  var board = Board.empty;
  for (final cell in xCells) {
    board = board.play(cell, CellMark.X);
  }
  for (final cell in oCells) {
    board = board.play(cell, CellMark.O);
  }
  return Game(
    board: board,
    currentPlayerId: currentPlayerId,
    fromId: _player,
    fromName: 'Jessy',
    id: const GameId('game'),
    status: GameStatus.playing,
    toId: _ai,
    toName: '',
    vsAi: true,
  );
}
