import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/design_system/components/lists/right_side_slider.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session_start_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/presentation/creation/game_create_offline_dialog.dart';
import 'package:tic_tac_toe_app/features/game/presentation/creation/game_create_online_dialog.dart';
import 'package:tic_tac_toe_app/features/game/presentation/game_error_message.dart';
import 'package:tic_tac_toe_app/features/game/presentation/home/game_mode.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/routing/auto_router.gr.dart';

@RoutePage()
class GameModeSelectionScreen extends ConsumerWidget {
  const GameModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(gameSessionStartProvider, (_, next) {
      if (next case AsyncError(:final error)) _showMessage(context, I18n.of(context).gameError(error));
    });
    final i18n = I18n.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Dimens.sliderWidth),
                child: RightSideSlider<GameMode>(
                  ctaLabel: i18n.play,
                  items: [for (final mode in GameMode.values) mode.toSliderItem(i18n)],
                  onSelected: (mode) => _play(context, ref, mode),
                ),
              ),
            ),
            const _LaunchingIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _play(BuildContext context, WidgetRef ref, GameMode mode) async {
    if (mode == GameMode.online1v1) {
      if (ref.read(onlinePlayProvider) case OnlinePlayUnavailable(:final reason)) {
        _showMessage(context, I18n.of(context).onlineUnavailableBecause(reason));
        return;
      }
    }

    final router = context.router;
    final input = await showDialog<GameCreateInput>(
      context: context,
      builder:
          (_) => switch (mode) {
            GameMode.offline1v1 => const GameCreateOfflineDialog(),
            GameMode.offlineVsAi => const GameCreateOfflineDialog(vsAi: true),
            GameMode.online1v1 => const GameCreateOnlineDialog(),
          },
    );
    if (input == null || !context.mounted) return;

    final session = await ref.read(gameSessionStartProvider.notifier).startSession(input);
    if (session == null || !context.mounted) return;

    await router.push(GameBoardScreenRoute(session: session));
  }

  void _showMessage(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Covers the modes while a game is created or joined, so the player cannot start a second one, and lets them stop
/// waiting.
class _LaunchingIndicator extends ConsumerWidget {
  const _LaunchingIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(gameSessionStartProvider.select((launch) => launch.isLoading))) return const SizedBox.shrink();

    final i18n = I18n.of(context);
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.3)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Dimens.standardSpacing,
            children: [
              CircularProgressIndicator(semanticsLabel: i18n.loading),
              FilledButton.tonal(
                onPressed: () => ref.read(gameSessionStartProvider.notifier).cancel(),
                child: Text(i18n.cancel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
