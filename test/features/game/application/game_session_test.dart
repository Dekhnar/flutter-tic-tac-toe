import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

const _gameId = GameId('ABCDEF');
const _jessy = PlayerId('jessy-uid');
const _online = GameSession.online(gameId: _gameId, me: _jessy);
const _local = GameSession.local(gameId: _gameId);

const _waiting = Game(
  currentPlayerId: _jessy,
  host: Player(id: _jessy, name: 'Jessy'),
  id: _gameId,
  status: GameStatus.setup,
);
final _withOpponent = _waiting.copyWith(guest: const Player(id: PlayerId('luigi-uid'), name: 'Luigi'));

void main() {
  group('A move from this device is for', () {
    final playing = _withOpponent.copyWith(status: GameStatus.playing, currentPlayerId: const PlayerId('luigi-uid'));

    test('its own player online, whoever is to play', () {
      expect(_online.playsFor(playing), _jessy);
      expect(_online.canPlay(playing), isFalse);
    });

    test('the player whose turn it is on a local game', () {
      expect(_local.playsFor(playing), const PlayerId('luigi-uid'));
      expect(_local.canPlay(playing), isTrue);
    });

    test('a cell only while it is empty, on the board, and this device may play', () {
      final marked = playing.copyWith(board: playing.board.play(const Cell(0), CellMark.X));

      expect(_local.canPlayAt(marked, const Cell(1)), isTrue);
      expect(_local.canPlayAt(marked, const Cell(0)), isFalse);
      expect(_local.canPlayAt(marked, const Cell(9)), isFalse);
      expect(_online.canPlayAt(marked, const Cell(1)), isFalse);
    });

    test('nobody on the AI\'s turn', () {
      const vsAi = GameSession.local(gameId: _gameId, vsAi: true);

      expect(vsAi.playsFor(playing), isNull);
      expect(vsAi.canPlay(playing), isFalse);
      expect(vsAi.playsFor(playing.copyWith(currentPlayerId: _jessy)), _jessy);
    });
  });

  group('Leaving ends the game for an opponent', () {
    test('who sits in an online game being set up, played or just finished', () {
      for (final status in [GameStatus.setup, GameStatus.playing, GameStatus.finished]) {
        expect(_online.leaveEndsGameForOpponent(_withOpponent.copyWith(status: status)), isTrue, reason: '$status');
      }
    });

    test('but not when nobody joined yet, once the game is over for both, or on a local game', () {
      expect(_online.leaveEndsGameForOpponent(_waiting), isFalse);
      expect(_online.leaveEndsGameForOpponent(_withOpponent.copyWith(status: GameStatus.abandoned)), isFalse);
      expect(_local.leaveEndsGameForOpponent(_withOpponent), isFalse);
    });
  });
}
