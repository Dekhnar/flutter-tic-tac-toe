import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_notifier.g.dart';

enum InfoMessage { pleaseRetry }

@riverpod
class MessageNotifier extends _$MessageNotifier {
  @override
  InfoMessage? build() => null;

  void showMessage(InfoMessage message) => state = message;
}
