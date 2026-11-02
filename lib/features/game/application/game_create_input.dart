import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

/// What the player chose in the creation dialogs.
sealed class GameCreateInput {
  const GameCreateInput();

  factory GameCreateInput.offline({required String guestName, required String hostName}) = GameCreateInputOffline1v1._;

  factory GameCreateInput.offlineVsAi({required String hostName}) = GameCreateInputOfflineVsAi._;

  factory GameCreateInput.createOnlineLobby({required String hostName}) = GameCreateInputOnlineLobby._;

  factory GameCreateInput.joinOnlineLobby({required GameId gameId, required String guestName}) =
      GameCreateInputJoinOnlineLobby._;
}

sealed class GameCreateInputOffline extends GameCreateInput {
  const GameCreateInputOffline();
}

final class GameCreateInputOffline1v1 extends GameCreateInputOffline {
  final String guestName;
  final String hostName;

  const GameCreateInputOffline1v1._({required this.guestName, required this.hostName});
}

final class GameCreateInputOfflineVsAi extends GameCreateInputOffline {
  final String hostName;

  const GameCreateInputOfflineVsAi._({required this.hostName});
}

sealed class GameCreateInputOnline extends GameCreateInput {
  const GameCreateInputOnline();
}

final class GameCreateInputOnlineLobby extends GameCreateInputOnline {
  final String hostName;

  const GameCreateInputOnlineLobby._({required this.hostName});
}

final class GameCreateInputJoinOnlineLobby extends GameCreateInputOnline {
  final GameId gameId;
  final String guestName;

  const GameCreateInputJoinOnlineLobby._({required this.gameId, required this.guestName});
}
