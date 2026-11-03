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

final class GameCreateInputOffline1v1 extends GameCreateInput {
  const GameCreateInputOffline1v1._({required this.guestName, required this.hostName});

  final String guestName;
  final String hostName;
}

final class GameCreateInputOfflineVsAi extends GameCreateInput {
  const GameCreateInputOfflineVsAi._({required this.hostName});

  final String hostName;
}

final class GameCreateInputOnlineLobby extends GameCreateInput {
  const GameCreateInputOnlineLobby._({required this.hostName});

  final String hostName;
}

final class GameCreateInputJoinOnlineLobby extends GameCreateInput {
  const GameCreateInputJoinOnlineLobby._({required this.gameId, required this.guestName});

  final GameId gameId;
  final String guestName;
}
