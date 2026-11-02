import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

part 'game_session.freezed.dart';

/// A game this device takes part in, created or joined before the board opens.
@freezed
sealed class GameSession with _$GameSession {
  /// Both players share this device, or the guest is the AI: who plays a seat is up to this device, not the game.
  const factory GameSession.local({required GameId gameId, @Default(false) bool vsAi}) = LocalGameSession;

  /// This device plays as [me] against another device.
  const factory GameSession.online({required GameId gameId, required PlayerId me}) = OnlineGameSession;
}

extension GameSessionPlayers on GameSession {
  /// The player this device plays as; null on a local game, where both players share the device.
  PlayerId? get me => switch (this) {
    OnlineGameSession(:final me) => me,
    LocalGameSession() => null,
  };

  /// Whether the AI plays [player]: the guest of a local game against the AI.
  bool isAi(Game game, PlayerId player) => switch (this) {
    LocalGameSession(vsAi: true) => player == game.guest?.id,
    _ => false,
  };

  bool isAiTurn(Game game) => game.status == GameStatus.playing && isAi(game, game.currentPlayerId);

  /// Whether a player of this device may play now: on a local game, whoever's turn it is, except the AI.
  bool canPlay(Game game) =>
      game.status == GameStatus.playing && !isAiTurn(game) && (me == null || game.currentPlayerId == me);

  /// Whether leaving ends the game for someone else: an online game an opponent sits in, and that is not over.
  bool leaveEndsGameForOpponent(Game game) => switch (this) {
    OnlineGameSession() => game.guest != null && game.status != GameStatus.abandoned,
    LocalGameSession() => false,
  };
}
