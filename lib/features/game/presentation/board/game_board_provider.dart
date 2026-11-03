import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';

part 'game_board_provider.g.dart';

/// Whether the board asks before leaving: only a game it shows can end for an opponent, not one that failed to load,
/// since nothing is left to leave.
@riverpod
bool leaveNeedsConfirmation(Ref ref, GameSession session) => switch (ref.watch(gameProvider(session))) {
  AsyncData(:final value) => session.leaveEndsGameForOpponent(value),
  _ => false,
};
