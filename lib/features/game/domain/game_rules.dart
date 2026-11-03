import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

part 'game_rules.freezed.dart';

/// What a rule makes of a request the game accepts. Both players can make the same request at once, so the second one
/// finds it already done.
@freezed
sealed class GameChange with _$GameChange {
  const factory GameChange.changed(Game game) = GameChanged;

  const factory GameChange.alreadyDone() = GameAlreadyDone;
}

/// Every change a game can go through, local or online: repositories store what these return, and `firestore.rules`
/// enforce the same rules on the server. A refusal throws the [GameException] that says why.
final class GameRules {
  const GameRules();

  GameChange join(Game game, {required PlayerId guest, required String guestName}) {
    if (game.status == GameStatus.abandoned) throw GameAbandonedException();
    if (guest == game.host.id || guest == game.guest?.id) return const GameChange.alreadyDone();
    if (game.guest != null) throw GameAlreadyFullException();

    return GameChange.changed(game.copyWith(guest: Player(id: guest, name: guestName)));
  }

  GameChange start(Game game) {
    if (game.status != GameStatus.setup) return const GameChange.alreadyDone();
    if (game.guest == null) throw GameOpponentMissingException();

    return GameChange.changed(game.copyWith(status: GameStatus.playing));
  }

  Game applyMove({required Game game, required PlayerId playerId, required Cell cell}) {
    if (game.status == GameStatus.abandoned) throw GameAbandonedException();
    if (game.status == GameStatus.finished) throw MoveGameFinishedException();
    if (game.status == GameStatus.setup) throw MoveGameNotStartedException();

    final guest = game.guest;
    if (guest == null) throw GameOpponentMissingException();
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

  /// The next round starts on an empty board, the players taking turns to start; asked during a round, it is already
  /// there.
  GameChange startNewRound(Game game) {
    final guest = game.guest;
    if (game.status != GameStatus.finished || guest == null) return const GameChange.alreadyDone();

    final nextRoundIndex = game.currentRoundIndex + 1;
    return GameChange.changed(
      game.copyWith(
        board: Board.empty,
        currentPlayerId: nextRoundIndex.isEven ? game.host.id : guest.id,
        currentRoundIndex: nextRoundIndex,
        currentWinnerId: null,
        status: GameStatus.playing,
      ),
    );
  }

  /// A player leaves for good: the other one can no longer play.
  GameChange leave(Game game) => switch (game.status) {
    GameStatus.abandoned => const GameChange.alreadyDone(),
    _ => GameChange.changed(game.copyWith(status: GameStatus.abandoned)),
  };
}
