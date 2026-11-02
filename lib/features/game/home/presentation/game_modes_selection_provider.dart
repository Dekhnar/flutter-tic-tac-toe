import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session_starter.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

part 'game_modes_selection_provider.g.dart';

/// Creating or joining the game the player chose: loading meanwhile, the error when it failed.
@riverpod
final class GameModesSelectionNotifier extends _$GameModesSelectionNotifier {
  @override
  FutureOr<void> build() {}

  /// The session to open the board with, or null when it failed: the state then holds the error.
  Future<GameSession?> startSession(GameCreateInput input) async {
    // The loading barrier covers the modes while a game starts.
    if (state.isLoading) return null;

    final starter = ref.read(gameSessionStarterProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => starter.start(input));
    if (!ref.mounted) return null;

    if (result case AsyncError(:final error, :final stackTrace)) {
      ref.read(errorLoggerServiceProvider).log(error, stackTrace);
    }
    state = result.whenData((_) {});
    return result.value;
  }
}
