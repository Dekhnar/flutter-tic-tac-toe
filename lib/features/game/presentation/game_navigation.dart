import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';

part 'game_navigation.g.dart';

/// How the game's screens move between each other. The app implements it with its router, which knows the screens:
/// the screens do not know the router.
abstract interface class GameNavigation {
  Future<void> openBoard(BuildContext context, GameSession session);

  /// Goes back from the board as the back button does: the board asks first when leaving ends the game for an
  /// opponent.
  Future<void> leaveBoard(BuildContext context);

  /// Closes the board, and any dialog over it, without asking: the player confirmed.
  void closeBoard(BuildContext context);
}

/// Bound in `lib/composition.dart`.
@Riverpod(keepAlive: true)
GameNavigation gameNavigation(Ref ref) => throw UnimplementedError('gameNavigationProvider is bound in composition');
