import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/ai_opponent.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/game_board_provider.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/widgets/game_board_grid.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/widgets/game_header.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/widgets/round_actions.dart';
import 'package:tic_tac_toe_app/features/game/presentation/game_error_message.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/routing/auto_router.gr.dart';

/// Shows the game of [session]; against the AI, the AI plays meanwhile. Leaving the board leaves the game.
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
    ref.listen(gameBoardActionsProvider(session), (_, next) {
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
                  (context, constraints) => switch (_LandscapeBoard.boardSideWithin(constraints)) {
                    final boardSide? => _LandscapeBoard(session: session, boardSide: boardSide),
                    null => _PortraitBoard(session: session),
                  },
            ),
          },
        ),
      ),
    );
  }

  /// Blocks the board while it has no game to show; offers a retry unless the game is gone.
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
              TextButton(
                onPressed: () {
                  // Closes whatever else is open over the board too, like a confirmation to leave.
                  context.router
                    ..popUntilRouteWithName(GameBoardScreenRoute.name)
                    ..pop();
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

/// Every way back from the board leaves the game. When that ends it for an opponent, the player confirms first.
class _LeaveGuard extends ConsumerWidget {
  const _LeaveGuard({required this.child, required this.session});

  final Widget child;
  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: !ref.watch(leaveNeedsConfirmationProvider(session)),
      // Runs for every pop, including the one after a confirmation.
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          unawaited(ref.read(gameBoardActionsProvider(session).notifier).leave());
          return;
        }

        final confirmed = await _confirmLeave(context);
        if (confirmed == true && context.mounted) context.router.pop();
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
  const _LandscapeBoard({required this.session, required this.boardSide});

  final GameSession session;
  final double boardSide;

  /// The side of a board as tall as [constraints] allow, or null when the screen is not wide enough to leave the header
  /// and the actions room beside it.
  static double? boardSideWithin(BoxConstraints constraints) {
    if (constraints.maxWidth <= constraints.maxHeight) return null;

    final boardSide = (constraints.maxHeight - 2 * Dimens.standardPadding).clamp(0.0, Dimens.boardMaxWidth);
    final roomBeside = constraints.maxWidth - boardSide - 2 * Dimens.standardPadding;
    return roomBeside >= Dimens.boardSidePanelMinWidth ? boardSide : null;
  }

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
          child: SizedBox.square(dimension: boardSide, child: GameBoardGrid(session: session)),
        ),
      ],
    );
  }
}
