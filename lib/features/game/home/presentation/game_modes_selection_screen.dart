import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/design_system/components/lists/right_side_slider.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
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
    final i18n = I18n.of(context);
    final gameModes = GameMode.values.map((mode) => mode.getPane(i18n)).toList();

    return MessageDisplayer(
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Dimens.sliderWidth),
                  child: RightSideSlider(
                    items: gameModes,
                    ctaLabel: i18n.play,
                    onPaneTap: (index) async {
                      // Navigation stays in the presentation layer (widget + pilot) so the provider never depends on
                      // the router and remains testable.
                      final session = await ref
                          .read(provider.notifier)
                          .requestGame(
                            gameModes[index].value,
                            openOfflineGameCreationDialog: () => _pilot.openOfflineGameCreationDialog(context.router),
                            openOfflineVsAiGameCreationDialog:
                                () => _pilot.openOfflineVsAiGameCreationDialog(context.router),
                            openOnlineGameCreationDialog: () => _pilot.openOnlineGameCreationDialog(context.router),
                          );
                      if (context.mounted && session != null) {
                        _pilot.navigateToGameBoard(context.router, session);
                      }
                    },
                  ),
                ),
              ),
              const _LaunchingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Covers the modes while a game is created or joined, so the player cannot start a second one.
class _LaunchingIndicator extends ConsumerWidget {
  const _LaunchingIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(gameModesSelectionNotifierProvider)) return const SizedBox.shrink();

    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.3)),
        Center(child: CircularProgressIndicator(semanticsLabel: I18n.of(context).loading)),
      ],
    );
  }
}
