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
      if (next == null || !context.mounted) return;

      final i18n = I18n.of(context);
      final text = switch (next.message) {
        InfoMessage.onlineUnavailable => i18n.onlineUnavailable,
        InfoMessage.pleaseRetry => i18n.pleaseRetry,
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    });
    return child;
  }
}
