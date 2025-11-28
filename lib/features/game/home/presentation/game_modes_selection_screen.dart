import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tic_tac_toe_app/index.dart';

@RoutePage()
class GameModeSelectionScreen extends ConsumerWidget {
  const GameModeSelectionScreen({super.key, GameModesSelectionPilot pilot = const GameModesSelectionPilot()})
    : _pilot = pilot;

  final GameModesSelectionPilot _pilot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = gameModesSelectionNotifierProvider;
    // On garde l'i18n dans le widget pour ne pas coupler le provider à la couche UI/contexte
    // et éviter de rebuild tout le graphe Riverpod juste quand la langue change.
    final gameModes = ref.watch(provider).map((mode) => mode.getPane(I18n.of(context))).toList();
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: MediaQuery.of(context).size.width / 2),
        child: RightSideSlider(
          items: gameModes,
          ctaLabel: I18n.of(context).play,
          onPaneTap: (index) async {
            // La navigation reste dans la couche présentation (widget/pilot) pour ne pas faire
            // dépendre le provider de BuildContext/Router et garder la logique testable.
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
    );
  }
}
