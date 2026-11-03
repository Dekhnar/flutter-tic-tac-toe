import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

import 'forwarding_repositories.dart';

/// The online games as a device sees them: a move may wait before it reaches the server, and the game stream may lag
/// behind the server.
final class LaggingOnlineGameRepository extends ForwardingOnlineGameRepository {
  LaggingOnlineGameRepository(super.inner);

  /// Runs once the player tapped a cell, before the move reaches the server.
  AsyncCallback? beforeMakeMove;

  bool _lagging = false;
  final _catchUps = <VoidCallback>[];

  /// From now on, the game stream holds back what the server sends.
  void lag() => _lagging = true;

  /// The game stream delivers the latest game it held back: Firestore skips the states in between.
  void catchUp() {
    _lagging = false;
    for (final catchUp in [..._catchUps]) {
      catchUp();
    }
  }

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell}) async {
    await beforeMakeMove?.call();
    await inner.makeMove(gameId: gameId, playerId: playerId, cell: cell);
  }

  @override
  Stream<Game> watchGame(GameId gameId) {
    late final StreamController<Game> controller;
    StreamSubscription<Game>? server;
    Game? heldBack;
    void catchUp() {
      if (heldBack case final game?) controller.add(game);
      heldBack = null;
    }

    controller = StreamController<Game>(
      onListen: () {
        _catchUps.add(catchUp);
        server = inner
            .watchGame(gameId)
            .listen(
              (game) => _lagging ? heldBack = game : controller.add(game),
              onError: controller.addError,
              onDone: controller.close,
            );
      },
      onCancel: () {
        _catchUps.remove(catchUp);
        return server?.cancel();
      },
    );
    return controller.stream;
  }
}
