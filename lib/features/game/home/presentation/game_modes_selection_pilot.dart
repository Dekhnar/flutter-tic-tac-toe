import 'package:auto_route/auto_route.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/shared/routing/auto_router.gr.dart';

final class GameModesSelectionPilot {
  const GameModesSelectionPilot();

  Future<GameCreateInputOnline?> openOnlineGameCreationDialog(StackRouter router) =>
      router.push(GameCreateOnlineDialogRoute());
  Future<GameCreateInputOffline?> openOfflineGameCreationDialog(StackRouter router) =>
      router.push(GameCreateOfflineDialogRoute());
  Future<GameCreateInputOffline?> openOfflineVsAiGameCreationDialog(StackRouter router) =>
      router.push(GameCreateOfflineDialogRoute(vsAi: true));

  void navigateToGameBoard(StackRouter router, GameCreateInput input) =>
      router.push(GameBoardScreenRoute(input: input));
}
