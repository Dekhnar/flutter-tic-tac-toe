import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tic_tac_toe_app/design_system/components/data_display/base/card.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/board/application/ai_opponent.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/presentation/game_error_message.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

/// Shows the game of [session] while the board is open; against the AI, the AI plays meanwhile.
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
          if (context.mounted) _showBlockingErrorDialog(context, ref, error);
        });
      }
    });
    ref.listen(gameActionsProvider(session), (_, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(I18n.of(context).gameError(error))));
      }
    });
    final (loaded, failed) = ref.watch(provider.select((game) => (game.hasValue, game.hasError && !game.isLoading)));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: switch ((loaded, failed)) {
          (false, true) => const SizedBox.shrink(),
          (false, false) => Center(child: CircularProgressIndicator(semanticsLabel: I18n.of(context).loading)),
          (true, _) => SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Dimens.boardMaxWidth),
                child: Column(
                  children: [
                    _GameHeader(session: session),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: Dimens.standardPadding) +
                          const EdgeInsets.only(top: Dimens.standardPadding),
                      child: _GameBoardGrid(session: session),
                    ),
                    _RoundActions(session: session),
                  ],
                ),
              ),
            ),
          ),
        },
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
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.router.maybePop();
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

class _GameHeader extends ConsumerWidget {
  const _GameHeader({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider(session).select((game) => game.value));
    if (game == null) return const SizedBox.shrink();

    final i18n = I18n.of(context);
    final theme = Theme.of(context);
    final nameStyle = theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onInverseSurface);
    final scoreStyle = theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.primary);
    final opponentId = game.toId;

    String playerLabel(PlayerId player) =>
        i18n.playerWithMark(game.vsAi && player == game.toId ? i18n.ai : game.nameOf(player), game.markOf(player).name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.standardPadding, vertical: Dimens.halfPadding),
      color: theme.colorScheme.inverseSurface,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: theme.colorScheme.onInverseSurface),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(playerLabel(game.fromId), style: nameStyle, overflow: TextOverflow.ellipsis),
                      Text(game.fromWinCounterIndicator, style: scoreStyle),
                    ],
                  ),
                ),
                if (opponentId != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(playerLabel(opponentId), style: nameStyle, overflow: TextOverflow.ellipsis),
                        Text(game.toWinCounterIndicator, style: scoreStyle),
                      ],
                    ),
                  ),
              ],
            ),
            switch (game.status) {
              GameStatus.setup when opponentId == null => _WaitingForOpponent(gameId: game.id),
              GameStatus.setup => const SizedBox.shrink(),
              GameStatus.playing => Text(
                game.currentPlayerId == session.me ? i18n.yourTurn : i18n.turnOf(playerLabel(game.currentPlayerId)),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onInverseSurface),
                textAlign: TextAlign.center,
              ),
              GameStatus.finished => Text(switch (game.currentWinnerId) {
                final winner? => i18n.playerWins(playerLabel(winner)),
                null => i18n.draw,
              }),
            },
            const SizedBox(height: Dimens.halfPadding),
          ],
        ),
      ),
    );
  }
}

/// Until the opponent joins, the host can copy the game code to send it.
class _WaitingForOpponent extends StatelessWidget {
  const _WaitingForOpponent({required this.gameId});

  final GameId gameId;

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    return Column(
      children: [
        Text(i18n.waitingForOpponent),
        Row(
          children: [
            Expanded(
              child: Text(
                i18n.gameCodeValue(gameId.value),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              color: Theme.of(context).colorScheme.onInverseSurface,
              tooltip: i18n.copy,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: gameId.value));
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.linkCopied)));
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _GameBoardGrid extends StatelessWidget {
  const _GameBoardGrid({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Board.size,
        crossAxisSpacing: Dimens.halfSpacing,
        mainAxisSpacing: Dimens.halfSpacing,
      ),
      itemCount: Board.cellCount,
      itemBuilder: (_, index) => _GameCell(key: Key('cell_$index'), index: index, session: session),
    );
  }
}

class _GameCell extends ConsumerWidget {
  const _GameCell({super.key, required this.index, required this.session});

  final int index;
  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (mark, playable) = ref.watch(
      gameProvider(session).select((asyncGame) {
        final game = asyncGame.value;
        final mark = game?.board[index];
        return (mark, mark == null && (game?.isPlayableBy(session.me) ?? false));
      }),
    );
    final busy = ref.watch(gameActionsProvider(session).select((actions) => actions.isLoading));

    final row = index ~/ Board.size;
    final col = index % Board.size;
    final onTap = playable && !busy ? () => ref.read(gameActionsProvider(session).notifier).makeMove(row, col) : null;
    final i18n = I18n.of(context);

    return Semantics(
      label: switch (mark) {
        null => i18n.boardCellEmpty(row + 1, col + 1),
        CellMark.X => i18n.boardCellCross(row + 1, col + 1),
        CellMark.O => i18n.boardCellCircle(row + 1, col + 1),
      },
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      child: ExcludeSemantics(
        child: BaseCardButton(
          onTap: onTap,
          child: switch (mark) {
            null => const SizedBox.shrink(),
            final mark => Center(child: Text(mark.name, style: Theme.of(context).textTheme.headlineLarge)),
          },
        ),
      ),
    );
  }
}

class _RoundActions extends ConsumerWidget {
  const _RoundActions({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (status, hasOpponent) = ref.watch(
      gameProvider(session).select((asyncGame) => (asyncGame.value?.status, asyncGame.value?.toId != null)),
    );
    final busy = ref.watch(gameActionsProvider(session).select((actions) => actions.isLoading));
    GameActions actions() => ref.read(gameActionsProvider(session).notifier);
    final i18n = I18n.of(context);

    return Container(
      padding: const EdgeInsets.only(top: Dimens.standardPadding, right: Dimens.standardPadding),
      alignment: Alignment.centerRight,
      child: switch (status) {
        GameStatus.setup when hasOpponent => FilledButton(
          onPressed: busy ? null : () => actions().startGame(),
          child: Text(i18n.startGame),
        ),
        GameStatus.finished => OutlinedButton(
          onPressed: busy ? null : () => actions().startNewRound(),
          child: Text(i18n.playAgain),
        ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
