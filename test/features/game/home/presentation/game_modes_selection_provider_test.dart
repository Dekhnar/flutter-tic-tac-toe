import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_provider.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_state.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

void main() {
  final onlineInput = GameCreateInput.createOnlineLobby(fromLabel: 'Jessy', shareLink: 'ABCDEF');

  ProviderContainer containerWith({required bool isOnlineAvailable}) {
    final container = ProviderContainer(overrides: [isOnlineAvailableProvider.overrideWithValue(isOnlineAvailable)]);
    addTearDown(container.dispose);
    container.listen(messageNotifierProvider, (_, _) {});
    return container;
  }

  Future<GameCreateInput?> chooseOnline(ProviderContainer container, {required void Function() onDialogOpened}) {
    return container
        .read(gameModesSelectionNotifierProvider.notifier)
        .requestGameCreationByMode(
          GameMode.online1v1,
          openOnlineGameCreationDialog: () async {
            onDialogOpened();
            return onlineInput;
          },
          openOfflineGameCreationDialog: () async => null,
          openOfflineVsAiGameCreationDialog: () async => null,
        );
  }

  test('choosing the online mode without Firebase explains it is unavailable', () async {
    final container = containerWith(isOnlineAvailable: false);
    var dialogOpened = false;

    final input = await chooseOnline(container, onDialogOpened: () => dialogOpened = true);

    expect(input, isNull);
    expect(dialogOpened, isFalse);
    expect(container.read(messageNotifierProvider)?.message, InfoMessage.onlineUnavailable);
  });

  test('choosing the online mode with Firebase opens the online game dialog', () async {
    final container = containerWith(isOnlineAvailable: true);
    var dialogOpened = false;

    final input = await chooseOnline(container, onDialogOpened: () => dialogOpened = true);

    expect(input, onlineInput);
    expect(dialogOpened, isTrue);
    expect(container.read(messageNotifierProvider), isNull);
  });
}
