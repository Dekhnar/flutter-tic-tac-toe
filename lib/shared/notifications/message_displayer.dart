import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

class MessageDisplayer extends ConsumerWidget {
  final Widget child;
  const MessageDisplayer({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(messageNotifierProvider, (previous, next) {
      // j’affiche tous les messages ; la page décide d’en envoyer un ou non, même le même si elle veut
      final message = switch (next) {
        InfoMessage(:final name) => Intl.message(name, name: name),
        _ => null,
      };
      if (message != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    return child;
  }
}
