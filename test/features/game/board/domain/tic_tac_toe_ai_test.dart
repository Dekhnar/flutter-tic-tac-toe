import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
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
}

Game _game({required List<int> xCells, required List<int> oCells, required PlayerId currentPlayerId}) {
  final moves = [
    for (final cell in xCells) Move(index: cell, mark: CellMark.X, playerId: _player, round: 0, turn: 0),
    for (final cell in oCells) Move(index: cell, mark: CellMark.O, playerId: _ai, round: 0, turn: 0),
  ];
  return Game(
    createdAt: DateTime(2025, 1, 1),
    currentPlayerId: currentPlayerId,
    fromId: _player,
    fromName: 'Jessy',
    id: const GameId('game'),
    moves: moves,
    status: GameStatus.playing,
    toId: _ai,
    toName: '',
    updatedAt: DateTime(2025, 1, 1),
    vsAi: true,
  );
}
