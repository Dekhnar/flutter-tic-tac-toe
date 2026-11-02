import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_app/features/game/board/application/ai_opponent.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_provider.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_session.dart';
import 'package:tic_tac_toe_app/features/game/board/data/repository/in_memory_game_repository.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_providers.dart';

const _thinkingTime = Duration(milliseconds: 20);

void main() {
  late InMemoryGameRepository games;
  late ProviderContainer container;

  setUp(() {
    games = InMemoryGameRepository();
    addTearDown(games.dispose);
    container = ProviderContainer(
      overrides: [
        aiThinkingTimeProvider.overrideWithValue(_thinkingTime),
        localGameRepositoryProvider.overrideWithValue(games),
      ],
    );
    addTearDown(container.dispose);
  });

  /// A started game, its board open: the game and the AI are watched.
  Future<(GameSession, ProviderSubscription<void>)> openBoard({required bool vsAi}) async {
    final gameId = await games.createGame(guestName: vsAi ? '' : 'Mario', hostName: 'Jessy', vsAi: vsAi);
    await games.startGame(gameId: gameId);
    final session = GameSession.local(gameId: gameId);
    container.listen(gameProvider(session), (_, _) {});
    final ai = container.listen(aiOpponentProvider(session), (_, _) {});
    await container.read(gameProvider(session).future);
    return (session, ai);
  }

  Future<void> playerPlays(GameSession session, int cell) =>
      container.read(gameActionsProvider(session).notifier).makeMove(cell ~/ Board.size, cell % Board.size);

  Future<Game> currentGame(GameSession session) async {
    await Future<void>.delayed(_thinkingTime * 3);
    return container.read(gameProvider(session).future);
  }

  test('the AI answers the player once it is done thinking, and gives the turn back', () async {
    final (session, _) = await openBoard(vsAi: true);

    await playerPlays(session, 0);
    expect((await games.watchGame(session.gameId).first).board.cells.nonNulls, hasLength(1));

    final answered = await currentGame(session);
    expect(answered.board[4], CellMark.O);
    expect(answered.currentPlayerId, InMemoryGameRepository.hostId);
  });

  test('a human opponent is never played by the AI', () async {
    final (session, _) = await openBoard(vsAi: false);

    await playerPlays(session, 0);

    final game = await currentGame(session);
    expect(game.board.cells.nonNulls, hasLength(1));
    expect(game.currentPlayerId, InMemoryGameRepository.guestId);
  });

  test('the AI stops playing once the board closes, even mid-thought', () async {
    final (session, ai) = await openBoard(vsAi: true);

    await playerPlays(session, 0);
    ai.close();

    expect((await currentGame(session)).board.cells.nonNulls, hasLength(1));
  });
}
