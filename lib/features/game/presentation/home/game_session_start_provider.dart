import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session_starter.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

part 'game_session_start_provider.g.dart';

/// Starting the game the player chose: loading meanwhile, then the error if it failed. The player stops waiting by
/// cancelling, or after [timeLimit].
@riverpod
final class GameSessionStartNotifier extends _$GameSessionStartNotifier {
  static const timeLimit = Duration(seconds: 15);

  Completer<GameSession?>? _stopWaiting;

  @override
  FutureOr<void> build() {}

  /// The session to open the board with. Null while another one is starting, or when this one failed or was cancelled.
  Future<GameSession?> startSession(GameCreateInput input) async {
    if (state.isLoading) return null;

    final starter = ref.read(gameSessionStarterProvider);
    final errorLogger = ref.read(errorLoggerProvider);
    final stopWaiting = _stopWaiting = Completer();
    final timer = Timer(timeLimit, () => stopWaiting.completeError(ServerNotAnsweringException.after(timeLimit)));
    state = const AsyncLoading();

    final starting = starter.start(input);
    final result = await AsyncValue.guard(() => Future.any([starting, stopWaiting.future]));
    timer.cancel();
    _stopWaiting = null;

    if (stopWaiting.isCompleted || !ref.mounted) {
      // No board opens for a session that comes now.
      unawaited(starting.then((session) => starter.dropLate(input, session)).onError(errorLogger.log));
    }
    if (!ref.mounted) return null;

    state = result.whenData((_) {});
    return result.value;
  }

  void cancel() {
    if (_stopWaiting case final stopWaiting? when !stopWaiting.isCompleted) stopWaiting.complete(null);
  }
}
