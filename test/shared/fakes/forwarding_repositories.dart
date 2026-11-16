import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_code.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';

/// Forwards every call to [inner], so that a fake overrides only what it changes.
class ForwardingLocalGameRepository implements LocalGameRepository {
  ForwardingLocalGameRepository(this.inner);

  final LocalGameRepository inner;

  @override
  Future<GameId> createGame({required String guestName, required String hostName}) =>
      inner.createGame(guestName: guestName, hostName: hostName);

  @override
  Future<void> leaveGame(GameId gameId) => inner.leaveGame(gameId);

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell}) =>
      inner.makeMove(gameId: gameId, playerId: playerId, cell: cell);

  @override
  Future<void> startNewRound({required GameId gameId}) => inner.startNewRound(gameId: gameId);

  @override
  Stream<Game> watchGame(GameId gameId) => inner.watchGame(gameId);
}

/// Forwards every call to [inner], so that a fake overrides only what it changes.
class ForwardingOnlineGameRepository implements OnlineGameRepository {
  ForwardingOnlineGameRepository(this.inner);

  final OnlineGameRepository inner;

  @override
  Future<GameCode> createGame({required PlayerId host, required String hostName}) =>
      inner.createGame(host: host, hostName: hostName);

  @override
  Future<void> joinGame(GameCode code, {required PlayerId guest, required String guestName}) =>
      inner.joinGame(code, guest: guest, guestName: guestName);

  @override
  Future<void> leaveGame(GameId gameId) => inner.leaveGame(gameId);

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell}) =>
      inner.makeMove(gameId: gameId, playerId: playerId, cell: cell);

  @override
  Future<void> startGame({required GameId gameId}) => inner.startGame(gameId: gameId);

  @override
  Future<void> startNewRound({required GameId gameId}) => inner.startNewRound(gameId: gameId);

  @override
  Stream<Game> watchGame(GameId gameId) => inner.watchGame(gameId);
}
