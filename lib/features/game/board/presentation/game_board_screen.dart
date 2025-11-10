import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:tic_tac_toe_app/design_system/components/data_display/base/card.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_displayer.dart';

@RoutePage()
class GameBoardScreen extends ConsumerWidget {
  final GameCreateInput input;
  const GameBoardScreen({super.key, required this.input});

  static const rowCount = 3;
  static const columnCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = gameNotifierProvider(gameCreateInput: input);
    final gameAsync = ref.watch(provider);
    ref.listen(provider, (previous, next) {
      // la modale est bloquante est fait sortir du jeu
      if (next.hasError && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showBlockingErrorDialog(context));
      }
    });

    return MessageDisplayer(
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (gameAsync case AsyncData(value: final game)) ...[
                    DefaultTextStyle.merge(
                      style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
                      child: _GameHeader(game: game),
                    ),
                  ],
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: Dimens.standardPadding) +
                        const EdgeInsets.only(top: Dimens.standardPadding),
                    child: _GameBoardGrid(
                      rowCount: rowCount,
                      columnCount: columnCount,
                      cellBuilder: (context, index) {
                        final rowIndex = index ~/ columnCount;
                        final columnIndex = index % columnCount;
                        final value = switch (gameAsync) {
                          AsyncData(value: final game) => game.board[rowIndex * columnCount + columnIndex],
                          _ => null,
                        };
                        return _GameCell(
                          key: Key('cell_$index'),
                          rowIndex: rowIndex,
                          columnIndex: columnIndex,
                          value: value,
                          onTap: switch (value) {
                            null => () => ref.read(provider.notifier).makeMove(rowIndex, columnIndex),
                            _ => null,
                          },
                        );
                      },
                    ),
                  ),
                  if (gameAsync case AsyncData(value: final game)) ...[
                    Container(
                      padding: const EdgeInsets.only(top: Dimens.standardPadding, right: Dimens.standardPadding),
                      alignment: Alignment.centerRight,
                      child: switch (game.status) {
                        GameStatus.setup when game.toId != null => FilledButton(
                          onPressed: () => ref.read(provider.notifier).startGame(),
                          child: Text(I18n.of(context).startGame),
                        ),
                        GameStatus.finished => OutlinedButton(
                          onPressed: () => ref.read(provider.notifier).startNewRound(),
                          child: Text(I18n.of(context).playAgain),
                        ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showBlockingErrorDialog(BuildContext context) {
    final i18n = I18n.of(context);
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(i18n.errorTitle),
            content: Text(i18n.errorRetryLater),
            actions: [
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

class _GameBoardGrid extends StatelessWidget {
  const _GameBoardGrid({required this.rowCount, required this.columnCount, required this.cellBuilder});

  final int rowCount;
  final int columnCount;
  final NullableIndexedWidgetBuilder cellBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: rowCount,
        crossAxisSpacing: Dimens.halfSpacing,
        mainAxisSpacing: Dimens.halfSpacing,
      ),
      itemCount: rowCount * columnCount,
      itemBuilder: cellBuilder,
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.standardPadding, vertical: Dimens.halfPadding),
      color: Theme.of(context).colorScheme.inverseSurface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.fromId,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
                    ),
                    Text(
                      game.fromWinCounterIndicator,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (game.toId case final toId?)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        toId,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
                      ),
                      Text(
                        game.toWinCounterIndicator,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (game.status == GameStatus.setup) ...[
            if (game.toId == null) Text(I18n.of(context).waitingForOpponent),
          ] else ...[
            if (game.status == GameStatus.finished)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(switch (game.currentWinnerId) {
                    final currentWinnerId? when currentWinnerId == game.fromId => I18n.of(context).playerXWins,
                    final currentWinnerId? when currentWinnerId == game.toId => I18n.of(context).playerOWins,
                    _ => I18n.of(context).draw,
                  }),
                ],
              )
            else if (game.status == GameStatus.playing) ...[
              Text(
                'Tour: ${game.currentPlayerId}',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onInverseSurface),
                textAlign: TextAlign.center,
              ),
            ],
          ],
          const SizedBox(height: Dimens.halfPadding),
        ],
      ),
    );
  }
}

class _GameCell extends StatelessWidget {
  final CellMark? value;
  final VoidCallback? onTap;
  final int rowIndex;
  final int columnIndex;

  const _GameCell({super.key, required this.value, required this.rowIndex, required this.columnIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: switch (value) {
        null => I18n.of(context).boardCellEmpty(rowIndex + 1, columnIndex + 1),
        CellMark.X => I18n.of(context).boardCellCross(rowIndex + 1, columnIndex + 1),
        CellMark.O => I18n.of(context).boardCellCircle(rowIndex + 1, columnIndex + 1),
      },
      button: true,
      onTap: onTap,
      child: ExcludeSemantics(
        child: BaseCardButton(
          onTap: onTap,
          child: switch (value) {
            null => const SizedBox.shrink(),
            final value => Center(child: Text(value.name, style: Theme.of(context).textTheme.headlineLarge)),
          },
        ),
      ),
    );
  }
}
