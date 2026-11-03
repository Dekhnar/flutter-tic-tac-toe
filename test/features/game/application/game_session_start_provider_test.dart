import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session_start_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

import '../../../shared/fakes/pending_local_game_repository.dart';

void main() {
  final localGame = GameCreateInput.offline(guestName: 'Mario', hostName: 'Jessy');
  late InMemoryGameRepository games;
  late PendingLocalGameRepository localRepository;
  late ProviderContainer container;

  /// The home screen's launcher, local games being created only once [PendingLocalGameRepository.created] completes.
  void setUpLauncher() {
    games = InMemoryGameRepository();
    addTearDown(games.dispose);
    localRepository = PendingLocalGameRepository(games);
    container = ProviderContainer(
      overrides: [
        localGameRepositoryProvider.overrideWithValue(localRepository),
        onlinePlayProvider.overrideWithValue(const OnlinePlayUnavailable(OnlineUnavailableReason.notConfigured)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(gameSessionStartProvider, (_, _) {});
  }

  setUp(setUpLauncher);

  GameSessionStartNotifier launch() => container.read(gameSessionStartProvider.notifier);

  /// Whether the game created last is still on the device.
  Future<bool> createdGameIsKept() async {
    await pumpEventQueue();
    return games.watchGame(localRepository.createdGames.single).first.then((_) => true, onError: (_) => false);
  }

  test('a game being created shows as loading until its session is ready', () async {
    final session = launch().startSession(localGame);
    expect(container.read(gameSessionStartProvider).isLoading, isTrue);

    localRepository.created.complete();

    expect(await session, isA<LocalGameSession>());
    expect(container.read(gameSessionStartProvider), const AsyncData<void>(null));
    expect(await createdGameIsKept(), isTrue);
  });

  test('a game that cannot start leaves the reason to show, and no session', () async {
    final session = launch().startSession(
      GameCreateInput.joinOnlineLobby(gameId: const GameId('ABCDEF'), guestName: 'Luigi'),
    );

    expect(await session, isNull);
    expect(container.read(gameSessionStartProvider).error, isA<OnlineUnavailableException>());
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
    expect(container.read(gameSessionStartProvider).hasError, isFalse);
  });

  test('the player who stops waiting gets no session and no error, and the game created afterwards is left', () async {
    final session = launch().startSession(localGame);

    launch().cancel();

    expect(await session, isNull);
    expect(container.read(gameSessionStartProvider), const AsyncData<void>(null));
    localRepository.created.complete();
    expect(await createdGameIsKept(), isFalse);
  });

  test('a game the server does not create in time is given up, and left if it comes later', () {
    fakeAsync((time) {
      // Futures complete in the zone that created them: the pending creation has to come from fake time too.
      setUpLauncher();
      GameSession? session;
      unawaited(launch().startSession(localGame).then((started) => session = started));

      time.elapse(GameSessionStartNotifier.timeLimit - const Duration(milliseconds: 1));
      expect(container.read(gameSessionStartProvider).isLoading, isTrue);
      time.elapse(const Duration(milliseconds: 1));

      expect(session, isNull);
      expect(container.read(gameSessionStartProvider).error, isA<ServerNotAnsweringException>());
      localRepository.created.complete();
      time.flushMicrotasks();
      Object? lateGame;
      games
          .watchGame(localRepository.createdGames.single)
          .first
          .then((game) => lateGame = game, onError: (Object error) => lateGame = error)
          .ignore();
      time.flushMicrotasks();
      expect(lateGame, isA<GameNotFoundException>());
    });
  });
}
