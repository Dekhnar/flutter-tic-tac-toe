import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_state.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

part 'game_modes_selection_provider.g.dart';

typedef OpenGameCreationDialogCallback = Future<GameCreateInput?> Function();

@riverpod
final class GameModesSelectionNotifier extends _$GameModesSelectionNotifier {
  @override
  List<GameMode> build() => GameMode.values.toList();

  bool _isRequestingGameCreation = false;

  Future<GameCreateInput?> requestGameCreationByMode(
    GameMode mode, {
    required OpenGameCreationDialogCallback openOnlineGameCreationDialog,
    required OpenGameCreationDialogCallback openOfflineGameCreationDialog,
    required OpenGameCreationDialogCallback openOfflineVsAiGameCreationDialog,
  }) async {
    if (_isRequestingGameCreation) return null;

    if (mode == GameMode.online1v1 && !ref.read(isOnlineAvailableProvider)) {
      ref.read(messageNotifierProvider.notifier).showMessage(InfoMessage.onlineUnavailable);
      return null;
    }

    _isRequestingGameCreation = true;
    try {
      // Awaited so the lock holds until the dialog closes, not until it opens.
      return await switch (mode) {
        GameMode.online1v1 => openOnlineGameCreationDialog,
        GameMode.offline1v1 => openOfflineGameCreationDialog,
        GameMode.offlineVSAi => openOfflineVsAiGameCreationDialog,
      }();
    } finally {
      _isRequestingGameCreation = false;
    }
  }
}
