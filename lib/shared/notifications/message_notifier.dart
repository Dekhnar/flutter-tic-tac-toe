import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_notifier.g.dart';

enum InfoMessage { onlineUnavailable, pleaseRetry }

/// One message to display. Each call builds a new instance on purpose: Riverpod compares states by identity, so
/// showing the same [InfoMessage] twice in a row still notifies the listeners.
final class MessageEvent {
  MessageEvent(this.message);

  final InfoMessage message;
}

@riverpod
class MessageNotifier extends _$MessageNotifier {
  @override
  MessageEvent? build() => null;

  void showMessage(InfoMessage message) => state = MessageEvent(message);
}
