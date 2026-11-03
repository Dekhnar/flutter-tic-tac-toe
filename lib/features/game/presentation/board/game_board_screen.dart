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
import 'package:tic_tac_toe_app/features/game/presentation/game_navigation.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

/// Leaving the board leaves the game.
@RoutePage()
class GameBoardScreen extends ConsumerWidget {
  const GameBoardScreen({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(aiOpponentProvider(session));
    ref.listen(gameBoardActionsProvider(session), (_, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(I18n.of(context).gameError(error))));
      }
    });
    // A retry flags the failure as loading: the board waits for the game again.
    final (loaded, failure) = ref.watch(
      gameProvider(session).select((game) => (game.hasValue, game.isLoading ? null : game.error)),
    );

    return _LeaveGuard(
      session: session,
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: switch ((loaded, failure)) {
            (_, final error?) => _GameUnavailable(error: error, session: session),
            (false, null) => Center(child: CircularProgressIndicator(semanticsLabel: I18n.of(context).loading)),
            (true, null) => LayoutBuilder(
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
}

/// Shown instead of the board while it has no game to show, until the game shows again. Offers a retry unless the game
/// is gone.
class _GameUnavailable extends ConsumerWidget {
  const _GameUnavailable({required this.error, required this.session});

  final Object error;
  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = I18n.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimens.standardPadding),
        child: Column(
          spacing: Dimens.standardSpacing,
          children: [
            Text(i18n.errorTitle, style: textTheme.headlineSmall),
            Text(switch (error) {
              GameNotFoundException() => i18n.gameNotFound,
              ServerNotAnsweringException() => i18n.serverNotAnswering,
              _ => i18n.errorRetryLater,
            }, textAlign: TextAlign.center),
            Wrap(
              spacing: Dimens.standardSpacing,
              children: [
                OutlinedButton(
                  onPressed: () => ref.read(gameNavigationProvider).leaveBoard(context),
                  child: Text(i18n.quit),
                ),
                if (error is! GameNotFoundException)
                  FilledButton(onPressed: () => ref.invalidate(gameProvider(session)), child: Text(i18n.retry)),
              ],
            ),
          ],
        ),
      ),
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
        if (confirmed == true && context.mounted) ref.read(gameNavigationProvider).closeBoard(context);
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
