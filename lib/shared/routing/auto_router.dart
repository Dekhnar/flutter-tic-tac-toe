import 'package:auto_route/auto_route.dart';
import 'package:tic_tac_toe_app/shared/routing/auto_router.gr.dart';
import 'package:tic_tac_toe_app/shared/routing/dialog_route.dart';

@AutoRouterConfig(replaceInRouteName: null)
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      initial: true,
      path: '/home',
      page: EmptyRouter.page,
      children: [
        AutoRoute(initial: true, page: GameModeSelectionScreenRoute.page),
        CustomDialogRoute(
          page: GameCreateOnlineDialogRoute.page,
          path: 'create/online',
          barrierDismissible: true,
          fullscreenDialog: true,
        ),
        CustomDialogRoute(
          page: GameCreateOfflineDialogRoute.page,
          path: 'create/offline',
          barrierDismissible: true,
          fullscreenDialog: true,
        ),
      ],
    ),
    AutoRoute(path: '/game', page: GameBoardScreenRoute.page),
  ];
}
