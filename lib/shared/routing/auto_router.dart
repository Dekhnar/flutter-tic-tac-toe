import 'package:auto_route/auto_route.dart';
import 'package:tic_tac_toe_app/shared/routing/auto_router.gr.dart';

/// The app's screens, navigated with this router. Dialogs are not routes: a screen opens one with `showDialog` and
/// awaits its result, which the dialog returns by closing itself with `Navigator.pop`.
@AutoRouterConfig(replaceInRouteName: null)
class AppRouter extends RootStackRouter {
  static const boardPath = '/game';

  /// A board needs the session the home screen starts: an address that points at one, like a reloaded web page,
  /// opens the home screen instead.
  static DeepLink openBoardsFromHome(PlatformDeepLink link) =>
      link.path.startsWith(boardPath) ? DeepLink.defaultPath : link;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(initial: true, path: '/', page: GameModeSelectionScreenRoute.page),
    AutoRoute(path: boardPath, page: GameBoardScreenRoute.page),
  ];
}
