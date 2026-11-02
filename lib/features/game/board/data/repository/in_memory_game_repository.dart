import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';
import 'package:tic_tac_toe_app/shared/data/in_memory_store.dart';

/// Stores the games played on this device, for as long as the app runs.
final class InMemoryGameRepository implements LocalGameRepositoryInterface {
  static const guestId = PlayerId('guest');
  static const hostId = PlayerId('host');

  static const _rules = GameRules();

  final _stores = <GameId, InMemoryStore<Game>>{};
  var _createdGames = 0;

  @override
  Stream<Game> watchGame(GameId gameId) => switch (_stores[gameId]) {
    final store? => store.stream,
    null => Stream.error(GameNotFoundException()),
  };

  @override
  Future<GameId> createGame({required String guestName, required String hostName, required bool vsAi}) async {
    final gameId = GameId('local-${++_createdGames}');
    _stores[gameId] = InMemoryStore<Game>(
      Game(
        currentPlayerId: hostId,
        fromId: hostId,
        fromName: hostName,
        id: gameId,
        status: GameStatus.setup,
        toId: guestId,
        toName: guestName,
        vsAi: vsAi,
      ),
    );
    return gameId;
  }

  @override
  Future<void> startGame({required GameId gameId}) async => _update(gameId, _rules.start);

  @override
  Future<void> startNewRound({required GameId gameId}) async => _update(gameId, _rules.startNewRound);

  @override
  Future<void> makeMove({
    required GameId gameId,
    required PlayerId playerId,
    required int row,
    required int col,
  }) async => _update(gameId, (game) => _rules.applyMove(game: game, playerId: playerId, row: row, col: col));

  @override
  void endGame(GameId gameId) => _stores.remove(gameId)?.close();

  void dispose() {
    for (final store in _stores.values) {
      store.close();
    }
    _stores.clear();
  }

  /// Applies [change] to the stored game; a null change, a request already fulfilled, stores nothing.
  void _update(GameId gameId, Game? Function(Game game) change) {
    final store = _stores[gameId] ?? (throw GameNotFoundException());
    if (change(store.value) case final changed?) store.value = changed;
  }
}
