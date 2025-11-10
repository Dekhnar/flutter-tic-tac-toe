import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';

extension GameState on Game {
  List<CellMark?> get board {
    final board = List<CellMark?>.filled(9, null);
    for (final m in moves) {
      board[m.index] = m.mark;
    }
    return board;
  }

  bool isMyTurn(String userId) => currentPlayerId == userId;
  String _counterIndicator(int count) => count > 999 ? "999+" : count.toString();

  String get fromWinCounterIndicator => _counterIndicator(fromWinCount);
  String get toWinCounterIndicator => _counterIndicator(toWinCount);
}

sealed class GameCreateInput {
  const GameCreateInput();

  factory GameCreateInput.offline({required String fromLabel, required String toLabel}) = GameCreateInputOffline1v1._;

  factory GameCreateInput.offlineVsAi({required String fromLabel}) = GameCreateInputOfflineVsAi._;

  factory GameCreateInput.createOnlineLobby({required String fromLabel, required String shareLink}) =
      GameCreateInputOnlineLobby._;

  factory GameCreateInput.joinOnlineLobby({required String toLabel, required String shareLink}) =
      GameCreateInputJoinOnlineLobby._;
}

sealed class GameCreateInputOffline extends GameCreateInput {
  const GameCreateInputOffline();
}

final class GameCreateInputOffline1v1 extends GameCreateInputOffline {
  final String fromLabel;
  final String toLabel;

  const GameCreateInputOffline1v1._({required this.fromLabel, required this.toLabel});
}

final class GameCreateInputOfflineVsAi extends GameCreateInputOffline {
  final String fromLabel;
  final String toLabel;

  const GameCreateInputOfflineVsAi._({required this.fromLabel}) : toLabel = "Ai";
}

sealed class GameCreateInputOnline extends GameCreateInput {
  const GameCreateInputOnline();
}

final class GameCreateInputOnlineLobby extends GameCreateInputOnline {
  final String fromLabel;
  final String shareLink;

  const GameCreateInputOnlineLobby._({required this.fromLabel, required this.shareLink});
}

final class GameCreateInputJoinOnlineLobby extends GameCreateInputOnline {
  final String toLabel;
  final String shareLink;

  const GameCreateInputJoinOnlineLobby._({required this.toLabel, required this.shareLink});
}
