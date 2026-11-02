import 'package:auto_route/auto_route.dart';
import 'package:tic_tac_toe_app/shared/routing/auto_router.gr.dart';
import 'package:tic_tac_toe_app/shared/routing/dialog_route.dart';

@AutoRouterConfig(replaceInRouteName: null)
class AppRouter extends RootStackRouter {
  static const boardPath = '/game';

  /// A board needs the session the home screen starts: an address that points at one, like a reloaded web page,
  /// opens the home screen instead.
  static DeepLink openBoardsFromHome(PlatformDeepLink link) =>
      link.path.startsWith(boardPath) ? DeepLink.defaultPath : link;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      initial: true,
      path: '/home',
      page: EmptyRouter.page,
      children: [
        AutoRoute(initial: true, page: GameModeSelectionScreenRoute.page),
        CustomDialogRoute(page: GameCreateOnlineDialogRoute.page, path: 'create/online', barrierDismissible: true),
        CustomDialogRoute(page: GameCreateOfflineDialogRoute.page, path: 'create/offline', barrierDismissible: true),
      ],
    ),
    AutoRoute(path: boardPath, page: GameBoardScreenRoute.page),
  ];
}
