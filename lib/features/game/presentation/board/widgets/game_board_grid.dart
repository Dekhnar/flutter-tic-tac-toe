import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tic_tac_toe_app/design_system/components/data_display/base/card.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

class GameBoardGrid extends StatelessWidget {
  const GameBoardGrid({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: Board.size,
      crossAxisSpacing: Dimens.halfSpacing,
      mainAxisSpacing: Dimens.halfSpacing,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [for (final cell in Cell.all) _GameCell(key: Key('cell_${cell.index}'), cell: cell, session: session)],
    );
  }
}

class _GameCell extends ConsumerWidget {
  const _GameCell({super.key, required this.cell, required this.session});

  final Cell cell;
  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (mark, playable) = ref.watch(
      gameProvider(session).select((asyncGame) {
        final mark = asyncGame.value?.board[cell];
        // A game that failed to load keeps showing its last board, but takes no move.
        final playable = switch (asyncGame) {
          AsyncData(value: final game) => mark == null && session.canPlay(game),
          _ => false,
        };
        return (mark, playable);
      }),
    );
    final busy = ref.watch(gameActionsProvider(session).select((actions) => actions.isLoading));

    final onTap = playable && !busy ? () => ref.read(gameActionsProvider(session).notifier).makeMove(cell) : null;
    final i18n = I18n.of(context);
    final (row, column) = (cell.row + 1, cell.column + 1);

    return Semantics(
      label: switch (mark) {
        null => i18n.boardCellEmpty(row, column),
        CellMark.X => i18n.boardCellCross(row, column),
        CellMark.O => i18n.boardCellCircle(row, column),
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
