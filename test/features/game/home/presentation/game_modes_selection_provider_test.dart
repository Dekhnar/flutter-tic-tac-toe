import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/application/start_game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_provider.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_state.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';
import 'package:tic_tac_toe_app/shared/notifications/message_notifier.dart';

const _gameId = GameId('ABCDEF');
const _onlineSession = GameSession.online(gameId: _gameId, me: PlayerId('jessy-uid'));

void main() {
  final onlineInput = GameCreateInput.createOnlineLobby(gameId: _gameId, hostName: 'Jessy');

  ProviderContainer containerWith({required bool isOnlineAvailable, StartGameSession? startGameSession}) {
    final container = ProviderContainer(
      overrides: [
        isOnlineAvailableProvider.overrideWithValue(isOnlineAvailable),
        startGameSessionProvider.overrideWithValue(startGameSession ?? (_) async => _onlineSession),
      ],
    );
    addTearDown(container.dispose);
    container.listen(messageNotifierProvider, (_, _) {});
    container.listen(gameModesSelectionNotifierProvider, (_, _) {});
    return container;
  }

  Future<GameSession?> chooseOnline(ProviderContainer container, {void Function()? onDialogOpened}) {
    return container
        .read(gameModesSelectionNotifierProvider.notifier)
        .requestGame(
          GameMode.online1v1,
          openOfflineGameCreationDialog: () async => null,
          openOfflineVsAiGameCreationDialog: () async => null,
          openOnlineGameCreationDialog: () async {
            onDialogOpened?.call();
            return onlineInput;
          },
        );
  }

  test('choosing the online mode without Firebase explains it is unavailable', () async {
    final container = containerWith(isOnlineAvailable: false);
    var dialogOpened = false;

    final session = await chooseOnline(container, onDialogOpened: () => dialogOpened = true);

    expect(session, isNull);
    expect(dialogOpened, isFalse);
    expect(container.read(messageNotifierProvider)?.message, InfoMessage.onlineUnavailable);
  });

  test('a game chosen in the dialog is created before the board opens', () async {
    GameCreateInput? started;
    final container = containerWith(
      isOnlineAvailable: true,
      startGameSession: (input) async {
        started = input;
        return _onlineSession;
      },
    );

    final session = await chooseOnline(container);

    expect(started, onlineInput);
    expect(session, _onlineSession);
    expect(container.read(messageNotifierProvider), isNull);
  });

  test('the home screen shows the game is being created until it is ready', () async {
    final creation = Completer<GameSession>();
    final container = containerWith(isOnlineAvailable: true, startGameSession: (_) => creation.future);

    final session = chooseOnline(container);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(gameModesSelectionNotifierProvider), isTrue);

    creation.complete(_onlineSession);
    await session;
    expect(container.read(gameModesSelectionNotifierProvider), isFalse);
  });

  test('joining a game that already has two players says so and stays on the home screen', () async {
    final container = containerWith(
      isOnlineAvailable: true,
      startGameSession: (_) async => throw GameAlreadyFullException(),
    );

    final session = await chooseOnline(container);

    expect(session, isNull);
    expect(container.read(messageNotifierProvider)?.message, InfoMessage.gameAlreadyFull);
    expect(container.read(gameModesSelectionNotifierProvider), isFalse);
  });

  test('an unexpected failure asks to retry', () async {
    final container = containerWith(
      isOnlineAvailable: true,
      startGameSession: (_) async => throw Exception('network unreachable'),
    );

    final session = await chooseOnline(container);

    expect(session, isNull);
    expect(container.read(messageNotifierProvider)?.message, InfoMessage.pleaseRetry);
  });

  test('choosing a mode again while its dialog is still open does not open a second one', () async {
    final container = containerWith(isOnlineAvailable: true);
    final openDialog = Completer<GameCreateInput?>();
    var openedDialogs = 0;

    Future<GameSession?> chooseLocal() => container
        .read(gameModesSelectionNotifierProvider.notifier)
        .requestGame(
          GameMode.offline1v1,
          openOfflineGameCreationDialog: () {
            openedDialogs++;
            return openDialog.future;
          },
          openOfflineVsAiGameCreationDialog: () async => null,
          openOnlineGameCreationDialog: () async => null,
        );

    final choices = [chooseLocal(), chooseLocal()];
    openDialog.complete(null);
    await Future.wait(choices);

    expect(openedDialogs, 1);
  });
}
