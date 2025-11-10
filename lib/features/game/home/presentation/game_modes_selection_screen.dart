import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tic_tac_toe_app/index.dart';

@RoutePage()
class GameModeSelectionScreen extends ConsumerWidget {
  const GameModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = gameModesSelectionNotifierProvider;
    const pilot = GameModesSelectionPilot();
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
            final input = await ref
                .read(provider.notifier)
                .requestGameCreationByMode(
                  gameModes[index].value,
                  openOnlineGameCreationDialog: () => pilot.openOnlineGameCreationDialog(context.router),
                  openOfflineGameCreationDialog: () => pilot.openOfflineGameCreationDialog(context.router),
                  openOfflineVsAiGameCreationDialog: () => pilot.openOfflineVsAiGameCreationDialog(context.router),
                );
            if (context.mounted && input != null) {
              pilot.navigateToGameBoard(context.router, input);
            }
          },
        ),
      ),
    );
  }
}
