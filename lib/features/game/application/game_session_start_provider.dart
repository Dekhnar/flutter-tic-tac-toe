import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session_starter.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

part 'game_session_start_provider.g.dart';

/// Creating or joining the game the player chose: loading meanwhile, the error when it failed. The player stops waiting
/// by cancelling, or after [timeLimit] with a [ServerNotAnsweringException]. A session that comes afterwards is left at once:
/// nobody opens its board, and an opponent must not wait in it.
@riverpod
final class GameSessionStartNotifier extends _$GameSessionStartNotifier {
  static const timeLimit = Duration(seconds: 15);

  Completer<GameSession?>? _waiting;

  @override
  FutureOr<void> build() {}

  /// The session to open the board with; null when the player cancelled, or when it failed: the state then holds the
  /// error.
  Future<GameSession?> startSession(GameCreateInput input) async {
    // The loading barrier covers the modes while a game starts.
    if (state.isLoading) return null;

    final starter = ref.read(gameSessionStarterProvider);
    final errorLogger = ref.read(errorLoggerProvider);
    final waiting = _waiting = Completer();
    state = const AsyncLoading();

    final timeout = Timer(timeLimit, () {
      if (waiting.isCompleted) return;

      waiting.completeError(ServerNotAnsweringException(TimeoutException('No session after $timeLimit', timeLimit)));
    });
    unawaited(
      starter
          .start(input)
          .then<void>(
            (session) async {
              if (waiting.isCompleted) {
                await starter.leave(session);
              } else {
                waiting.complete(session);
              }
            },
            onError: (Object error, StackTrace stackTrace) {
              if (waiting.isCompleted) {
                errorLogger.log(error, stackTrace);
              } else {
                waiting.completeError(error, stackTrace);
              }
            },
          )
          .onError(errorLogger.log),
    );

    final result = await AsyncValue.guard(() => waiting.future);
    timeout.cancel();
    if (!ref.mounted) {
      if (result.value case final session?) unawaited(starter.leave(session).onError(errorLogger.log));
      return null;
    }

    _waiting = null;
    state = result.whenData((_) {});
    return result.value;
  }

  /// Stops waiting for the session being started.
  void cancel() {
    if (_waiting case final waiting? when !waiting.isCompleted) waiting.complete(null);
  }
}
