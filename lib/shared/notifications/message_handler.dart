import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

mixin MessageHandler {
  Ref get _ref => (this as dynamic).ref as Ref;

  MessageNotifier get messageNotifier => _ref.read(messageNotifierProvider.notifier);

  void showMessage(InfoMessage message) => messageNotifier.showMessage(message);
}
