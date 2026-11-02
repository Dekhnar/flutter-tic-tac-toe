import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/application/start_game_session.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_state.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

part 'game_modes_selection_provider.g.dart';

typedef OpenGameCreationDialogCallback = Future<GameCreateInput?> Function();

/// Whether a game is being created or joined, between the dialog closing and the board opening.
@riverpod
final class GameModesSelectionNotifier extends _$GameModesSelectionNotifier {
  @override
  bool build() => false;

  bool _requesting = false;

  Future<GameSession?> requestGame(
    GameMode mode, {
    required OpenGameCreationDialogCallback openOfflineGameCreationDialog,
    required OpenGameCreationDialogCallback openOfflineVsAiGameCreationDialog,
    required OpenGameCreationDialogCallback openOnlineGameCreationDialog,
  }) async {
    if (_requesting) return null;

    if (mode == GameMode.online1v1 && !ref.read(isOnlineAvailableProvider)) {
      _showMessage(InfoMessage.onlineUnavailable);
      return null;
    }

    _requesting = true;
    try {
      final input =
          await switch (mode) {
            GameMode.offline1v1 => openOfflineGameCreationDialog,
            GameMode.offlineVSAi => openOfflineVsAiGameCreationDialog,
            GameMode.online1v1 => openOnlineGameCreationDialog,
          }();
      if (input == null) return null;

      state = true;
      return await ref.read(startGameSessionProvider)(input);
    } on AppException catch (refusal) {
      ref.read(errorLoggerServiceProvider).logAppException(refusal);
      _showMessage(InfoMessage.explaining(refusal));
      return null;
    } catch (error, stackTrace) {
      ref.read(errorLoggerServiceProvider).logError(error, stackTrace);
      _showMessage(InfoMessage.pleaseRetry);
      return null;
    } finally {
      _requesting = false;
      state = false;
    }
  }

  void _showMessage(InfoMessage message) => ref.read(messageNotifierProvider.notifier).showMessage(message);
}
