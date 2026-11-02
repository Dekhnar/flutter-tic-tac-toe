import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';

part 'game_session.freezed.dart';

/// A game this device takes part in, created or joined before the board opens.
@freezed
sealed class GameSession with _$GameSession {
  /// Both players share this device.
  const factory GameSession.local({required GameId gameId}) = LocalGameSession;

  /// This device plays as [me] against another device.
  const factory GameSession.online({required GameId gameId, required PlayerId me}) = OnlineGameSession;
}

extension GameSessionPlayer on GameSession {
  /// The player this device plays as; null on a local game, where both players share the device.
  PlayerId? get me => switch (this) {
    OnlineGameSession(:final me) => me,
    LocalGameSession() => null,
  };
}
