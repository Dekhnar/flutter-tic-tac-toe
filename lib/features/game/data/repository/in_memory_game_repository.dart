import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_rules.dart';
import 'package:tic_tac_toe_app/shared/data/in_memory_store.dart';

/// Stores the games played on this device, for as long as the app runs.
final class InMemoryGameRepository implements LocalGameRepository {
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
  Future<GameId> createGame({required String guestName, required String hostName}) async {
    final gameId = GameId('local-${++_createdGames}');
    final seated = Game(
      currentPlayerId: hostId,
      guest: Player(id: guestId, name: guestName),
      host: Player(id: hostId, name: hostName),
      id: gameId,
      status: GameStatus.setup,
    );
    // Both players are on this device from the start: the game starts at once.
    _stores[gameId] = InMemoryStore(switch (_rules.start(seated)) {
      GameChanged(:final game) => game,
      GameAlreadyDone() => seated,
    });
    return gameId;
  }

  @override
  Future<void> startNewRound({required GameId gameId}) async => _update(gameId, _rules.startNewRound);

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell}) async =>
      _update(gameId, (game) => _rules.applyMove(game: game, playerId: playerId, cell: cell));

  @override
  Future<void> leaveGame(GameId gameId) async => _stores.remove(gameId)?.close();

  void dispose() {
    for (final store in _stores.values) {
      store.close();
    }
    _stores.clear();
  }

  void _update(GameId gameId, GameChange Function(Game game) change) {
    final store = _stores[gameId] ?? (throw GameNotFoundException());
    if (change(store.value) case GameChanged(:final game)) store.value = game;
  }
}
