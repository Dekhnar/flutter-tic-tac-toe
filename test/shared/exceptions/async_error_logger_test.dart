import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/application/game_create_input.dart';
import 'package:tic_tac_toe_app/features/game/application/game_dependencies.dart';
import 'package:tic_tac_toe_app/features/game/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/application/game_session_start_provider.dart';
import 'package:tic_tac_toe_app/features/game/application/online_play.dart';
import 'package:tic_tac_toe_app/features/game/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/shared/exceptions/async_error_logger.dart';
import 'package:tic_tac_toe_app/shared/exceptions/error_logger.dart';

void main() {
  late _RecordingLogger logger;
  late InMemoryGameRepository games;
  late ProviderContainer container;

  setUp(() {
    logger = _RecordingLogger();
    games = InMemoryGameRepository();
    addTearDown(games.dispose);
    container = ProviderContainer(
      observers: [const AsyncErrorLogger()],
      overrides: [
        errorLoggerProvider.overrideWithValue(logger),
        localGameRepositoryProvider.overrideWithValue(games),
        onlinePlayProvider.overrideWithValue(const OnlinePlayUnavailable(OnlineUnavailableReason.notConfigured)),
      ],
    );
    addTearDown(container.dispose);
  });

  test('a move the game refuses is reported once', () async {
    final gameId = await games.createGame(guestName: 'Mario', hostName: 'Jessy');
    final session = GameSession.local(gameId: gameId);
    container.listen(gameProvider(session), (_, _) {});
    container.listen(gameActionsProvider(session), (_, _) {});
    await container.read(gameProvider(session).future);
    final actions = container.read(gameActionsProvider(session).notifier);

    await actions.makeMove(const Cell(9));

    expect(logger.errors, [isA<MoveCellIndexInvalidException>()]);
  });

  test('a game that cannot be loaded is reported once', () async {
    const session = GameSession.local(gameId: GameId('gone'));
    container.listen(gameProvider(session), (_, _) {});

    await expectLater(container.read(gameProvider(session).future), throwsA(isA<GameNotFoundException>()));

    expect(logger.errors, [isA<GameNotFoundException>()]);
  });

  test('a game that cannot start from the home screen is reported once', () async {
    container.listen(gameSessionStartProvider, (_, _) {});

    await container
        .read(gameSessionStartProvider.notifier)
        .startSession(GameCreateInput.joinOnlineLobby(gameId: const GameId('ABCDEF'), guestName: 'Luigi'));

    expect(logger.errors, [isA<OnlineUnavailableException>()]);
  });
}

final class _RecordingLogger implements ErrorLogger {
  final errors = <Object>[];

  @override
  void log(Object error, StackTrace? stackTrace, {bool fatal = false}) => errors.add(error);
}
