import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_rules.dart';
import 'package:tic_tac_toe_app/features/game/domain/tic_tac_toe_ai.dart';

const _player = PlayerId('host');
const _ai = PlayerId('guest');

void main() {
  const ai = TicTacToeAI();

  test('the AI wins rather than blocks when it can do both', () {
    // X X .      The AI (O) can block the top row on 2, or win the middle row on 4.
    // O . O
    // X . .
    expect(ai.nextMove(_board(x: [0, 1, 6], o: [3, 5]), mark: CellMark.O), const Cell(4));
  });

  test('the AI blocks the line the player is about to complete', () {
    expect(ai.nextMove(_board(x: [0, 4], o: [1]), mark: CellMark.O), const Cell(8));
  });

  test('the AI takes the center first, then a corner', () {
    expect(ai.nextMove(_board(x: [0]), mark: CellMark.O), const Cell(4));
    expect(ai.nextMove(_board(x: [4]), mark: CellMark.O), const Cell(0));
  });

  test('the AI has no move once the round is over', () {
    expect(ai.nextMove(_board(x: [0, 1, 2], o: [3, 4]), mark: CellMark.O), isNull);
    expect(ai.nextMove(_board(x: [0, 1, 5, 6, 8], o: [2, 3, 4, 7]), mark: CellMark.O), isNull);
  });

  for (final (opener, firstPlayer) in [('the player', _player), ('the AI', _ai)]) {
    test('the AI never loses, whatever the player does, when $opener opens the round', () {
      const rules = GameRules();
      final finishedGames = <Game>[];

      Game play(Game game, PlayerId player, Cell cell) => rules.applyMove(game: game, playerId: player, cell: cell);

      void playEveryAnswer(Game game) {
        if (game.status == GameStatus.finished) {
          finishedGames.add(game);
          return;
        }
        if (game.currentPlayerId == _ai) {
          final cell =
              ai.nextMove(game.board, mark: CellMark.O) ??
              (throw TestFailure('The AI passed its turn on ${game.board}'));
          return playEveryAnswer(play(game, _ai, cell));
        }

        for (final cell in game.board.emptyCells) {
          playEveryAnswer(play(game, _player, cell));
        }
      }

      playEveryAnswer(
        Game(
          currentPlayerId: firstPlayer,
          guest: const Player(id: _ai, name: ''),
          host: const Player(id: _player, name: 'Jessy'),
          id: const GameId('game'),
          status: GameStatus.playing,
        ),
      );

      expect(finishedGames, isNotEmpty);
      expect(finishedGames.where((game) => game.currentWinnerId == _player), isEmpty);
    });
  }
}

Board _board({List<int> x = const [], List<int> o = const []}) => [
  for (final cell in x) (Cell(cell), CellMark.X),
  for (final cell in o) (Cell(cell), CellMark.O),
].fold(Board.empty, (board, move) => board.play(move.$1, move.$2));
