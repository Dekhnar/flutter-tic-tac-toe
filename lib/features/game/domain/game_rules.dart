import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

/// Every change a game can go through, local or online: the repositories only store what these return, and
/// `firestore.rules` check the same rules on the server. A refusal throws the [GameException] that says why; a null
/// result means the change already happened, both players being able to ask for it at once.
final class GameRules {
  const GameRules();

  /// The game once [guest] took the free seat, or null when [guest] already plays it.
  Game? join(Game game, {required PlayerId guest, required String guestName}) {
    if (game.status == GameStatus.abandoned) throw GameAbandonedException();
    if (guest == game.host.id || guest == game.guest?.id) return null;
    if (game.guest != null) throw GameAlreadyFullException();

    return game.copyWith(guest: Player(id: guest, name: guestName));
  }

  /// The game once started, or null when it already is.
  Game? start(Game game) {
    if (game.status != GameStatus.setup) return null;
    if (game.guest == null) throw MoveOpponentMissingException();

    return game.copyWith(status: GameStatus.playing);
  }

  Game applyMove({required Game game, required PlayerId playerId, required Cell cell}) {
    if (game.status == GameStatus.abandoned) throw GameAbandonedException();
    if (game.status == GameStatus.finished) throw MoveGameFinishedException();
    if (game.status == GameStatus.setup) throw MoveGameNotStartedException();

    final guest = game.guest;
    if (guest == null) throw MoveOpponentMissingException();
    if (game.currentPlayerId != playerId) throw MoveNotYourTurnException();
    if (!cell.isOnBoard) throw MoveCellIndexInvalidException();
    if (game.board[cell] != null) throw MoveCellAlreadyTakenException();

    final mark = game.markOf(playerId);
    final board = game.board.play(cell, mark);
    final played = game.copyWith(board: board);
    final hasLine = board.hasLine(mark);

    if (!hasLine && !board.isFull) {
      return played.copyWith(currentPlayerId: playerId == game.host.id ? guest.id : game.host.id);
    }

    Player scored(Player player) => hasLine && player.id == playerId ? player.copyWith(wins: player.wins + 1) : player;
    return played.copyWith(
      currentWinnerId: hasLine ? playerId : null,
      guest: scored(guest),
      host: scored(game.host),
      status: GameStatus.finished,
    );
  }

  /// The next round, on an empty board, the players taking turns to start; null while the round is being played.
  Game? startNewRound(Game game) {
    if (game.status != GameStatus.finished) return null;

    final guest = game.guest;
    if (guest == null) return null;

    final nextRoundIndex = game.currentRoundIndex + 1;
    return game.copyWith(
      board: Board.empty,
      currentPlayerId: nextRoundIndex.isEven ? game.host.id : guest.id,
      currentRoundIndex: nextRoundIndex,
      currentWinnerId: null,
      status: GameStatus.playing,
    );
  }

  /// The game once a player left it: the other one can no longer play it.
  Game? leave(Game game) {
    if (game.status == GameStatus.abandoned) return null;

    return game.copyWith(status: GameStatus.abandoned);
  }
}
