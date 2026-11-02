import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tic_tac_toe_app/generated/l10n.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

class MessageDisplayer extends ConsumerWidget {
  final Widget child;
  const MessageDisplayer({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(messageNotifierProvider, (_, next) {
      // Every screen mounts a displayer and the screens below the current one stay mounted: only the visible one
      // shows the message.
      if (next == null || !context.mounted || ModalRoute.isCurrentOf(context) == false) return;

      final i18n = I18n.of(context);
      final text = switch (next.message) {
        InfoMessage.cellAlreadyTaken => i18n.cellAlreadyTaken,
        InfoMessage.gameAlreadyFull => i18n.gameAlreadyFull,
        InfoMessage.gameNotFound => i18n.gameNotFound,
        InfoMessage.gameNotStartedYet => i18n.gameNotStartedYet,
        InfoMessage.invalidCellIndex => i18n.invalidCellIndex,
        InfoMessage.notYourTurn => i18n.notYourTurn,
        InfoMessage.onlineUnavailable => i18n.onlineUnavailable,
        InfoMessage.opponentMustJoin => i18n.opponentMustJoin,
        InfoMessage.pleaseRetry => i18n.pleaseRetry,
        InfoMessage.roundIsOver => i18n.roundIsOver,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    });
    return child;
  }
}
