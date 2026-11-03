import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

part 'game_session.freezed.dart';

@freezed
sealed class GameSession with _$GameSession {
  /// Both players on this device, or the host against the AI.
  const factory GameSession.local({required GameId gameId, @Default(false) bool vsAi}) = LocalGameSession;

  const factory GameSession.online({required GameId gameId, required PlayerId me}) = OnlineGameSession;
}

extension GameSessionPlayers on GameSession {
  PlayerId? get me => switch (this) {
    OnlineGameSession(:final me) => me,
    LocalGameSession() => null,
  };

  bool get hasAi => switch (this) {
    LocalGameSession(:final vsAi) => vsAi,
    OnlineGameSession() => false,
  };

  bool isAi(Game game, PlayerId player) => hasAi && player == game.guest?.id;

  bool isAiTurn(Game game) => game.status == GameStatus.playing && isAi(game, game.currentPlayerId);

  /// Who a move from this device is for: this device's player online, the player whose turn it is on a local game.
  /// Null on the AI's turn: nobody on this device plays for it.
  PlayerId? playsFor(Game game) => switch (this) {
    OnlineGameSession(:final me) => me,
    LocalGameSession() when isAiTurn(game) => null,
    LocalGameSession() => game.currentPlayerId,
  };

  bool canPlay(Game game) => game.status == GameStatus.playing && playsFor(game) == game.currentPlayerId;

  bool leaveEndsGameForOpponent(Game game) => switch (this) {
    OnlineGameSession() => game.guest != null && game.status != GameStatus.abandoned,
    LocalGameSession() => false,
  };
}
