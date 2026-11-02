import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/ai_opponent.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/widgets/game_board_grid.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/widgets/game_header.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/widgets/round_actions.dart';
import 'package:tic_tac_toe_app/features/game/presentation/game_error_message.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

/// Shows the game of [session] while the board is open; against the AI, the AI plays meanwhile. Leaving the board
/// leaves the game.
@RoutePage()
class GameBoardScreen extends ConsumerWidget {
  const GameBoardScreen({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(aiOpponentProvider(session));
    final provider = gameProvider(session);
    ref.listen(provider, (_, next) {
      // Invalidating the game to retry reports the error again, flagged as loading.
      if (next case AsyncError(:final error, isLoading: false)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) unawaited(_showBlockingErrorDialog(context, ref, error));
        });
      }
    });
    ref.listen(gameActionsProvider(session), (_, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(I18n.of(context).gameError(error))));
      }
    });
    final (loaded, failed) = ref.watch(provider.select((game) => (game.hasValue, game.hasError && !game.isLoading)));

    return _LeaveGuard(
      session: session,
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: switch ((loaded, failed)) {
            (false, true) => const SizedBox.shrink(),
            (false, false) => Center(child: CircularProgressIndicator(semanticsLabel: I18n.of(context).loading)),
            (true, _) => LayoutBuilder(
              builder:
                  (context, constraints) => switch (constraints.maxWidth > constraints.maxHeight) {
                    true => _LandscapeBoard(session: session, height: constraints.maxHeight),
                    false => _PortraitBoard(session: session),
                  },
            ),
          },
        ),
      ),
    );
  }

  /// The board cannot show a game it failed to load: the dialog blocks the screen, offering to retry when it may help.
  Future<void> _showBlockingErrorDialog(BuildContext context, WidgetRef ref, Object error) {
    final i18n = I18n.of(context);
    final gameIsGone = error is GameNotFoundException;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(i18n.errorTitle),
            content: Text(gameIsGone ? i18n.gameNotFound : i18n.errorRetryLater),
            actions: [
              if (!gameIsGone)
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ref.invalidate(gameProvider(session));
                  },
                  child: Text(i18n.retry),
                ),
              // Closes the board for sure: nothing is left to confirm leaving.
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                },
                child: Text(i18n.quit),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Every way out of the board — back button, back gesture, system back — leaves the game. An online game someone else
/// plays then ends for them too: the player confirms it first.
class _LeaveGuard extends ConsumerWidget {
  const _LeaveGuard({required this.child, required this.session});

  final Widget child;
  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: !ref.watch(leaveNeedsConfirmationProvider(session)),
      // Called for every pop, the one that follows a confirmation included: that is where the game is left.
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          unawaited(ref.read(gameActionsProvider(session).notifier).leave());
          return;
        }

        final confirmed = await _confirmLeave(context);
        if (confirmed == true && context.mounted) Navigator.of(context).pop();
      },
      child: child,
    );
  }

  Future<bool?> _confirmLeave(BuildContext context) {
    final i18n = I18n.of(context);
    return showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(i18n.leaveGameTitle),
            content: Text(i18n.leaveGameMessage),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(i18n.stay)),
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(i18n.leave)),
            ],
          ),
    );
  }
}

class _PortraitBoard extends StatelessWidget {
  const _PortraitBoard({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Dimens.boardMaxWidth),
          child: Column(
            children: [
              GameHeader(session: session),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimens.standardPadding,
                  Dimens.standardPadding,
                  Dimens.standardPadding,
                  0,
                ),
                child: GameBoardGrid(session: session),
              ),
              RoundActions(session: session),
            ],
          ),
        ),
      ),
    );
  }
}

/// The header and the actions beside a board as tall as the screen.
class _LandscapeBoard extends StatelessWidget {
  const _LandscapeBoard({required this.session, required this.height});

  final GameSession session;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [GameHeader(session: session), RoundActions(session: session)]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Dimens.standardPadding),
          child: SizedBox.square(
            dimension: (height - 2 * Dimens.standardPadding).clamp(0, Dimens.boardMaxWidth),
            child: GameBoardGrid(session: session),
          ),
        ),
      ],
    );
  }
}
