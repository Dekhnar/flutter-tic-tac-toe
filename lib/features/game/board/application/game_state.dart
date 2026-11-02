import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';

extension GameState on Game {
  List<CellMark?> get board {
    final board = List<CellMark?>.filled(9, null);
    for (final m in moves) {
      board[m.index] = m.mark;
    }
    return board;
  }

  String _counterIndicator(int count) => count > 999 ? "999+" : count.toString();

  String get fromWinCounterIndicator => _counterIndicator(fromWinCount);
  String get toWinCounterIndicator => _counterIndicator(toWinCount);
}

/// What the player chose in the creation dialogs.
sealed class GameCreateInput {
  const GameCreateInput();

  factory GameCreateInput.offline({required String guestName, required String hostName}) = GameCreateInputOffline1v1._;

  factory GameCreateInput.offlineVsAi({required String hostName}) = GameCreateInputOfflineVsAi._;

  factory GameCreateInput.createOnlineLobby({required GameId gameId, required String hostName}) =
      GameCreateInputOnlineLobby._;

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
  final GameId gameId;
  final String hostName;

  const GameCreateInputOnlineLobby._({required this.gameId, required this.hostName});
}

final class GameCreateInputJoinOnlineLobby extends GameCreateInputOnline {
  final GameId gameId;
  final String guestName;

  const GameCreateInputJoinOnlineLobby._({required this.gameId, required this.guestName});
}
