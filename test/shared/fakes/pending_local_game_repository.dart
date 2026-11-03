import 'dart:async';

import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

import 'forwarding_repositories.dart';

/// Local games that are created only once [created] completes.
final class PendingLocalGameRepository extends ForwardingLocalGameRepository {
  PendingLocalGameRepository(super.inner);

  final created = Completer<void>();

  int creations = 0;

  final createdGames = <GameId>[];

  @override
  Future<GameId> createGame({required String guestName, required String hostName}) async {
    creations++;
    await created.future;
    final gameId = await inner.createGame(guestName: guestName, hostName: hostName);
    createdGames.add(gameId);
    return gameId;
  }
}
