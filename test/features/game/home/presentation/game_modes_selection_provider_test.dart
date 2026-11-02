import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_state.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_providers.dart';
import 'package:tic_tac_toe_app/features/game/home/presentation/game_modes_selection_provider.dart';
import 'package:tic_tac_toe_app/shared/firebase/online_availability_provider.dart';

import '../../../../shared/fakes/pending_local_game_repository.dart';

void main() {
  final localGame = GameCreateInput.offline(guestName: 'Mario', hostName: 'Jessy');
  late PendingLocalGameRepository localRepository;
  late ProviderContainer container;

  setUp(() {
    final games = InMemoryGameRepository(stores: {});
    addTearDown(games.dispose);
    localRepository = PendingLocalGameRepository(games);
    container = ProviderContainer(
      overrides: [
        isOnlineAvailableProvider.overrideWithValue(false),
        localGameRepositoryProvider.overrideWithValue(localRepository),
      ],
    );
    addTearDown(container.dispose);
    container.listen(gameModesSelectionProvider, (_, _) {});
  });

  GameModesSelectionNotifier launch() => container.read(gameModesSelectionProvider.notifier);

  test('a game being created shows as loading until its session is ready', () async {
    final session = launch().startSession(localGame);
    expect(container.read(gameModesSelectionProvider).isLoading, isTrue);

    localRepository.created.complete();

    expect(await session, isA<LocalGameSession>());
    expect(container.read(gameModesSelectionProvider), const AsyncData<void>(null));
  });

  test('a game that cannot start leaves the reason to show, and no session', () async {
    final session = launch().startSession(
      GameCreateInput.joinOnlineLobby(gameId: const GameId('ABCDEF'), guestName: 'Luigi'),
    );

    expect(await session, isNull);
    expect(container.read(gameModesSelectionProvider).error, isA<OnlineUnavailableException>());
  });

  test('a second game cannot start while the first one is being created', () async {
    final first = launch().startSession(localGame);
    final second = launch().startSession(localGame);
    localRepository.created.complete();

    expect(await second, isNull);
    expect(await first, isNotNull);
    expect(localRepository.creations, 1);
  });

  test('after a failure, the next game starts normally', () async {
    await launch().startSession(GameCreateInput.joinOnlineLobby(gameId: const GameId('ABCDEF'), guestName: 'Luigi'));
    localRepository.created.complete();

    expect(await launch().startSession(localGame), isA<LocalGameSession>());
    expect(container.read(gameModesSelectionProvider).hasError, isFalse);
  });
}
