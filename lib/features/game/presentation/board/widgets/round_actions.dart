import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/game_board_provider.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

class RoundActions extends ConsumerWidget {
  const RoundActions({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (status, hasOpponent) = ref.watch(
      // A game that failed to load offers nothing to start.
      gameProvider(session).select(
        (asyncGame) => switch (asyncGame) {
          AsyncData(value: final game) => (game.status, game.guest != null),
          _ => (null, false),
        },
      ),
    );
    final busy = ref.watch(gameBoardActionsProvider(session).select((actions) => actions.isLoading));
    GameBoardActionsNotifier actions() => ref.read(gameBoardActionsProvider(session).notifier);
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
