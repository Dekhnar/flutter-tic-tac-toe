import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/design_system/components/lists/right_side_slider.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_pilot.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_provider.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_state.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_displayer.dart';

@RoutePage()
class GameModeSelectionScreen extends ConsumerWidget {
  const GameModeSelectionScreen({super.key, GameModesSelectionPilot pilot = const GameModesSelectionPilot()})
    : _pilot = pilot;

  final GameModesSelectionPilot _pilot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = gameModesSelectionNotifierProvider;
    // Labels are resolved here so the provider stays independent from BuildContext and is not rebuilt on a locale
    // change.
    final gameModes = ref.watch(provider).map((mode) => mode.getPane(I18n.of(context))).toList();
    return MessageDisplayer(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 2),
          child: RightSideSlider(
            items: gameModes,
            ctaLabel: I18n.of(context).play,
            onPaneTap: (index) async {
              // Navigation stays in the presentation layer (widget + pilot) so the provider never depends on the
              // router and remains testable.
              final gameCreateInput = await ref
                  .read(provider.notifier)
                  .requestGameCreationByMode(
                    gameModes[index].value,
                    openOnlineGameCreationDialog: () => _pilot.openOnlineGameCreationDialog(context.router),
                    openOfflineGameCreationDialog: () => _pilot.openOfflineGameCreationDialog(context.router),
                    openOfflineVsAiGameCreationDialog: () => _pilot.openOfflineVsAiGameCreationDialog(context.router),
                  );
              if (context.mounted && gameCreateInput != null) {
                _pilot.navigateToGameBoard(context.router, gameCreateInput);
              }
            },
          ),
        ),
      ),
    );
  }
}
