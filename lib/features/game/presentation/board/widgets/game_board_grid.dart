import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tic_tac_toe_app/design_system/components/data_display/base/card.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/game_board_provider.dart';
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

/// The cell of the move under way shows a progress indicator.
class _GameCell extends ConsumerWidget {
  const _GameCell({super.key, required this.cell, required this.session});

  final Cell cell;
  final GameSession session;

  bool _isPlayable(AsyncValue<Game> asyncGame) => switch (asyncGame) {
    // A game that failed to load keeps showing its last board, but takes no move.
    AsyncData(value: final game) => game.board[cell] == null && session.canPlay(game),
    _ => false,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mark = ref.watch(gameProvider(session).select((asyncGame) => asyncGame.value?.board[cell]));
    final playable = ref.watch(gameProvider(session).select(_isPlayable));
    final busy = ref.watch(gameBoardActionsProvider(session).select((actions) => actions.isLoading));
    final pending = ref.watch(pendingMoveProvider(session).select((move) => move == cell));

    final onTap =
        playable && !busy ? () => unawaited(ref.read(gameBoardActionsProvider(session).notifier).makeMove(cell)) : null;
    final i18n = I18n.of(context);
    final (row, column) = (cell.row + 1, cell.column + 1);

    return Semantics(
      label: switch (mark) {
        null when pending => i18n.boardCellPlaying(row, column),
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
            null when pending => const Center(child: CircularProgressIndicator()),
            null => const SizedBox.shrink(),
            final mark => Center(child: Text(mark.name, style: Theme.of(context).textTheme.headlineLarge)),
          },
        ),
      ),
    );
  }
}
