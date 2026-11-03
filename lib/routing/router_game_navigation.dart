import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/presentation/game_navigation.dart';
import 'package:tic_tac_toe_app/routing/app_router.gr.dart';

final class RouterGameNavigation implements GameNavigation {
  const RouterGameNavigation();

  @override
  Future<void> openBoard(BuildContext context, GameSession session) =>
      context.router.push(GameBoardScreenRoute(session: session));

  @override
  Future<void> leaveBoard(BuildContext context) => context.router.maybePop();

  @override
  void closeBoard(BuildContext context) =>
      context.router
        ..popUntilRouteWithName(GameBoardScreenRoute.name)
        ..pop();
}
