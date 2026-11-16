import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/presentation/board/game_board_provider.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';

class GameHeader extends ConsumerWidget {
  const GameHeader({super.key, required this.session});

  final GameSession session;

  static const _maxShownScore = 999;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider(session).select((game) => game.value));
    if (game == null) return const SizedBox.shrink();

    final i18n = I18n.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final nameStyle = theme.textTheme.headlineMedium?.copyWith(color: colors.onInverseSurface);
    final scoreStyle = theme.textTheme.headlineMedium?.copyWith(color: colors.inversePrimary);

    String playerLabel(PlayerId player) =>
        i18n.playerWithMark(session.isAi(game, player) ? i18n.ai : game.nameOf(player), game.markOf(player).name);
    String score(int wins) => wins > _maxShownScore ? '$_maxShownScore+' : '$wins';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.standardPadding, vertical: Dimens.halfPadding),
      color: colors.inverseSurface,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: colors.onInverseSurface),
        textAlign: TextAlign.center,
        child: Column(
          children: [
            Row(
              children: [
                for (final (player, alignment) in [
                  (game.host, CrossAxisAlignment.start),
                  if (game.guest case final guest?) (guest, CrossAxisAlignment.end),
                ])
                  Expanded(
                    child: Column(
                      crossAxisAlignment: alignment,
                      children: [
                        Text(playerLabel(player.id), style: nameStyle, overflow: TextOverflow.ellipsis),
                        Text(score(player.wins), style: scoreStyle),
                      ],
                    ),
                  ),
              ],
            ),
            switch (game.status) {
              GameStatus.setup when game.guest == null => _WaitingForOpponent(gameId: game.id),
              GameStatus.setup => const SizedBox.shrink(),
              GameStatus.playing => Text(
                game.currentPlayerId == session.me ? i18n.yourTurn : i18n.turnOf(playerLabel(game.currentPlayerId)),
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(color: colors.onInverseSurface),
              ),
              GameStatus.finished => Text(switch (game.currentWinnerId) {
                final winner? => i18n.playerWins(playerLabel(winner)),
                null => i18n.draw,
              }),
              GameStatus.abandoned => Text(i18n.opponentLeft),
            },
            if (game.status == GameStatus.playing)
              _OpponentInactive(session: session, opponent: playerLabel(game.currentPlayerId)),
            const SizedBox(height: Dimens.halfPadding),
          ],
        ),
      ),
    );
  }
}

class _OpponentInactive extends ConsumerWidget {
  const _OpponentInactive({required this.opponent, required this.session});

  final String opponent;
  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(opponentInactiveProvider(session))) return const SizedBox.shrink();

    return Text(I18n.of(context).opponentInactive(opponent));
  }
}

class _WaitingForOpponent extends StatelessWidget {
  const _WaitingForOpponent({required this.gameId});

  final GameId gameId;

  @override
  Widget build(BuildContext context) {
    final i18n = I18n.of(context);
    final color = Theme.of(context).colorScheme.onInverseSurface;
    return Column(
      children: [
        Text(i18n.waitingForOpponent),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                i18n.gameCodeValue(gameId.value),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              color: color,
              tooltip: i18n.copy,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: gameId.value));
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(i18n.codeCopied)));
              },
            ),
            Builder(
              builder:
                  (buttonContext) => IconButton(
                    icon: const Icon(Icons.share),
                    color: color,
                    tooltip: i18n.share,
                    onPressed: () => _share(buttonContext, i18n.shareInvitation(gameId.value)),
                  ),
            ),
          ],
        ),
      ],
    );
  }

  /// On a tablet the share sheet points at the button that opened it.
  Future<void> _share(BuildContext buttonContext, String invitation) {
    final button = buttonContext.findRenderObject();
    final origin = button is RenderBox ? button.localToGlobal(Offset.zero) & button.size : null;
    return SharePlus.instance.share(ShareParams(text: invitation, sharePositionOrigin: origin));
  }
}
