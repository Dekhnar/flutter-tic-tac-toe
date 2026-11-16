import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/data/dto/game_document.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/firestore_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_code.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/presentation/home/game_session_start_provider.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';

import '../../../../shared/fakes/forwarding_repositories.dart';
import '../../../../shared/fakes/pending_local_game_repository.dart';
import '../../../../shared/fakes/signed_in_identity.dart';

const _jessy = PlayerId('jessy-uid');
const _luigi = PlayerId('luigi-uid');

void main() {
  const localGame = GameCreateInput.local(guestName: 'Mario', hostName: 'Jessy');
  late InMemoryGameRepository games;
  late PendingLocalGameRepository localRepository;
  late FakeFirebaseFirestore firestore;
  late _SlowServer server;
  late ProviderContainer container;

  /// The home screen's starter. Local games are created once [PendingLocalGameRepository.created] completes, online
  /// games once [_SlowServer.answer] completes.
  void setUpStarter() {
    games = InMemoryGameRepository();
    addTearDown(games.dispose);
    localRepository = PendingLocalGameRepository(games);
    firestore = FakeFirebaseFirestore();
    server = _SlowServer(FirestoreGameRepository(firestore: firestore));
    container = ProviderContainer(
      overrides: [
        localGameRepositoryProvider.overrideWithValue(localRepository),
        onlinePlayProvider.overrideWithValue(
          OnlinePlay.available(identity: SignedInIdentity(_luigi), repository: server),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(gameSessionStartProvider, (_, _) {});
  }

  setUp(setUpStarter);

  GameSessionStartNotifier starter() => container.read(gameSessionStartProvider.notifier);

  /// Whether the game created last is still on the device.
  Future<bool> createdGameIsKept() async {
    await pumpEventQueue();
    return games.watchGame(localRepository.createdGames.single).first.then((_) => true, onError: (_) => false);
  }

  test('a game being created shows as loading until its session is ready', () async {
    final session = starter().startSession(localGame);
    expect(container.read(gameSessionStartProvider).isLoading, isTrue);

    localRepository.created.complete();

    expect(await session, isA<LocalGameSession>());
    expect(container.read(gameSessionStartProvider), const AsyncData<void>(null));
    expect(await createdGameIsKept(), isTrue);
  });

  test('a game that cannot start leaves the reason to show, and no session', () async {
    server.answer.complete();

    final session = starter().startSession(GameCreateInput.joinOnline(code: GameCode.parse('AB3CD4'), guestName: 'L'));

    expect(await session, isNull);
    expect(container.read(gameSessionStartProvider).error, isA<GameNotFoundException>());
  });

  test('a second game cannot start while the first one is being created', () async {
    final first = starter().startSession(localGame);
    final second = starter().startSession(localGame);
    localRepository.created.complete();

    expect(await second, isNull);
    expect(await first, isNotNull);
    expect(localRepository.creations, 1);
  });

  test('after a failure, the next game starts normally', () async {
    server.answer.complete();
    await starter().startSession(GameCreateInput.joinOnline(code: GameCode.parse('AB3CD4'), guestName: 'Luigi'));
    localRepository.created.complete();

    expect(await starter().startSession(localGame), isA<LocalGameSession>());
    expect(container.read(gameSessionStartProvider).hasError, isFalse);
  });

  test('the player who stops waiting gets no session and no error, and the game created afterwards is left', () async {
    final session = starter().startSession(localGame);

    starter().cancel();

    expect(await session, isNull);
    expect(container.read(gameSessionStartProvider), const AsyncData<void>(null));
    localRepository.created.complete();
    expect(await createdGameIsKept(), isFalse);
  });

  group('After the time limit', () {
    /// Runs [body] in fake time, the starter set up there: a future completes in the zone that created it.
    void inFakeTime(void Function(FakeAsync time) body) => fakeAsync((time) {
      setUpStarter();
      body(time);
    });

    /// Starts [input] and waits for the time limit to run out.
    GameSession? startAndWaitTooLong(FakeAsync time, GameCreateInput input) {
      GameSession? session;
      unawaited(starter().startSession(input).then((started) => session = started));

      time.elapse(GameSessionStartNotifier.timeLimit - const Duration(milliseconds: 1));
      expect(container.read(gameSessionStartProvider).isLoading, isTrue);
      time.elapse(const Duration(milliseconds: 1));
      return session;
    }

    test('a game is given up, saying the server is not answering, and left when it comes later', () {
      inFakeTime((time) {
        expect(startAndWaitTooLong(time, localGame), isNull);
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

    test('a seat taken late in a friend\'s game is kept: joining again opens that game', () {
      inFakeTime((time) {
        late GameCode code;
        unawaited(server.inner.createGame(host: _jessy, hostName: 'Jessy').then((created) => code = created));
        time.flushMicrotasks();
        final join = GameCreateInput.joinOnline(code: code, guestName: 'Luigi');

        expect(startAndWaitTooLong(time, join), isNull);
        server.answer.complete();
        time.flushMicrotasks();

        GameSession? again;
        unawaited(starter().startSession(join).then((session) => again = session));
        time.flushMicrotasks();
        Map<String, Object?>? stored;
        unawaited(firestore.collection('games').doc(code.value).get().then((game) => stored = game.data()));
        time.flushMicrotasks();

        expect(again, GameSession.online(gameId: code, me: _luigi));
        expect(
          (stored?[GameField.guestId.name], stored?[GameField.status.name]),
          (_luigi.value, GameStatus.setup.name),
        );
      });
    });
  });
}

/// The online games, on a server that answers a join only once [answer] completes.
final class _SlowServer extends ForwardingOnlineGameRepository {
  _SlowServer(super.inner);

  final answer = Completer<void>();

  @override
  Future<void> joinGame(GameCode code, {required PlayerId guest, required String guestName}) async {
    await answer.future;
    await inner.joinGame(code, guest: guest, guestName: guestName);
  }
}
