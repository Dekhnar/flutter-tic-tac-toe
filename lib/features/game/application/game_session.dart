import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

part 'game_session.freezed.dart';

/// A game this device takes part in, created or joined before the board opens.
@freezed
sealed class GameSession with _$GameSession {
  /// Both players on this device, or the host against the AI.
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

  /// Whether the AI plays a seat: the guest's, in a local game against the AI.
  bool get hasAi => switch (this) {
    LocalGameSession(:final vsAi) => vsAi,
    OnlineGameSession() => false,
  };

  bool isAi(Game game, PlayerId player) => hasAi && player == game.guest?.id;

  bool isAiTurn(Game game) => game.status == GameStatus.playing && isAi(game, game.currentPlayerId);

  /// On a local game, whoever's turn it is may play, except the AI.
  bool canPlay(Game game) =>
      game.status == GameStatus.playing && !isAiTurn(game) && (me == null || game.currentPlayerId == me);

  /// Leaving ends the game for someone else only online, once an opponent sits in it.
  bool leaveEndsGameForOpponent(Game game) => switch (this) {
    OnlineGameSession() => game.guest != null && game.status != GameStatus.abandoned,
    LocalGameSession() => false,
  };
}
