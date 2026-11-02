import 'dart:async';

import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_app/features/game/board/data/dto/commands.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';

final class FirestoreGameRepository implements OnlineGameRepositoryInterface {
  const FirestoreGameRepository({
    @visibleForTesting Clock clock = const Clock(),
    required FirebaseFirestore firestore,
    @visibleForTesting GameRules rules = const GameRules(),
  }) : _clock = clock,
       _firestore = firestore,
       _rules = rules;

  /// How long a game stays on the server: a TTL policy on `expiresAt` deletes it, see README.
  static const lifetime = Duration(days: 30);

  final Clock _clock;
  final FirebaseFirestore _firestore;
  final GameRules _rules;

  DocumentReference<Map<String, dynamic>> _gameRef(GameId gameId) => _firestore.collection('games').doc(gameId.value);

  @override
  Future<void> createGame(GameId gameId, {required PlayerId host, required String hostName}) async {
    final gameRef = _gameRef(gameId);

    await _runTransaction((transaction) async {
      if ((await transaction.get(gameRef)).exists) throw StateError('A game already uses the id ${gameId.value}');

      final expiresAt = _clock.now().add(lifetime);
      transaction.set(gameRef, CreateGameCommand(expiresAt: expiresAt, host: host, hostName: hostName).toFirestore());
    });
  }

  @override
  Future<void> joinGame(GameId gameId, {required PlayerId guest, required String guestName}) async {
    final gameRef = _gameRef(gameId);

    await _runTransaction((transaction) async {
      final snapshot = await transaction.get(gameRef);
      if (!snapshot.exists) throw GameNotFoundException();

      final game = _parseGame(snapshot);
      if (guest == game.fromId || guest == game.toId) return;
      if (game.toId != null) throw GameAlreadyFullException();

      transaction.update(gameRef, JoinGameCommand(guest: guest, guestName: guestName).toFirestore());
    });
  }

  @override
  Stream<Game> watchGame(GameId gameId) {
    final gameRef = _gameRef(gameId);

    final controller = StreamController<Game>();
    StreamSubscription? gameSubscription;
    StreamSubscription? movesSubscription;
    Game? latestGame;
    List<Move> latestMoves = const [];

    // The game and its moves arrive through two listeners: a game is emitted only once both describe the same turn,
    // so the board never shows the moves of another round or misses the last one.
    void emitWhenConsistent() {
      if (latestGame case final game? when latestMoves.length == game.boardState.moveCount) {
        controller.add(game.copyWith(moves: latestMoves));
      }
    }

    // A listener that throws would escape to the zone: the error goes to the game stream instead.
    void forwardErrors(VoidCallback onSnapshot) {
      try {
        onSnapshot();
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    void listenMoves(int round) {
      movesSubscription?.cancel();
      latestMoves = const [];

      movesSubscription = gameRef
          .collection('moves')
          .where('round', isEqualTo: round)
          .snapshots()
          .listen(
            (movesSnapshot) => forwardErrors(() {
              latestMoves = movesSnapshot.docs.map((move) => Move.fromJson(move.data())).toList(growable: false)..sort(
                (a, b) => a.turn.compareTo(b.turn),
              ); // sorted client-side: `where` + `orderBy` needs a composite index
              emitWhenConsistent();
            }),
            onError: controller.addError,
          );
    }

    gameSubscription = gameRef.snapshots().listen(
      (snapshot) => forwardErrors(() {
        if (!snapshot.exists) throw GameNotFoundException();

        final game = _parseGame(snapshot);
        final previousRound = latestGame?.currentRoundIndex;

        latestGame = game;

        if (previousRound != game.currentRoundIndex) {
          listenMoves(game.currentRoundIndex);
        }

        emitWhenConsistent();
      }),
      onError: controller.addError,
      onDone: controller.close,
    );

    controller.onCancel = () {
      gameSubscription?.cancel();
      movesSubscription?.cancel();
    };

    return controller.stream;
  }

  @override
  Future<void> makeMove({
    required GameId gameId,
    required PlayerId playerId,
    required int row,
    required int col,
  }) async {
    await _runTransaction((transaction) async {
      final gameRef = _gameRef(gameId);
      final currentGame = _parseGame(await transaction.get(gameRef));
      final updatedGame = _rules.applyMove(
        game: currentGame,
        playerId: playerId,
        row: row,
        col: col,
        currentDate: _clock.now(),
      );
      final move = updatedGame.moves.last;

      // The stored game carries no moves: the rules cannot see the cell taken, its move document does.
      final moveRef = gameRef.collection('moves').doc('${move.round}:${move.index}');
      final moveSnapshot = await transaction.get(moveRef);
      if (moveSnapshot.exists) throw MoveCellAlreadyTakenException();

      // The rules require a move to expire with its game.
      final expiresAt = currentGame.expiresAt ?? (throw StateError('The game ${gameId.value} has no expiry date'));
      transaction.set(moveRef, MoveEventCommand(expiresAt: expiresAt, move: move).toFirestore());
      transaction.update(gameRef, MovePlayedCommand(game: updatedGame).toFirestore());
    });
  }

  @override
  Future<void> startNewRound({required GameId gameId}) async {
    await _runTransaction((transaction) async {
      final gameRef = _gameRef(gameId);
      final currentGame = _parseGame(await transaction.get(gameRef));

      // Both players see "play again": the second request finds the round already started and does nothing.
      final nextRound = _rules.startNewRound(game: currentGame, currentDate: _clock.now());
      if (nextRound == null) return;

      transaction.update(gameRef, RoundStartedCommand(game: nextRound).toFirestore());
    });
  }

  @override
  Future<void> startGame({required GameId gameId}) async {
    await _runTransaction((transaction) async {
      final gameRef = _gameRef(gameId);
      final currentGame = _parseGame(await transaction.get(gameRef));

      if (currentGame.status != GameStatus.setup) return;
      if (currentGame.toId == null) throw MoveOpponentMissingException();

      transaction.update(gameRef, const StartGameCommand().toFirestore());
    });
  }

  /// A transaction that read the game before the other player changed it is refused by the rules, which check the
  /// write against the new game, rather than retried by Firestore: it runs once more, against the game as it is now.
  Future<void> _runTransaction(TransactionHandler<void> write) async {
    try {
      await _firestore.runTransaction(write);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;

      await _firestore.runTransaction(write);
    }
  }

  Game _parseGame(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return switch (snapshot.data()) {
      null => throw GameNotFoundException(),
      final data => Game.fromJson({
        ...data,
        'id': snapshot.id,
        'createdAt': _dateOf(data['createdAt']) ?? _clock.now().toIso8601String(),
        'updatedAt': _dateOf(data['updatedAt']) ?? _clock.now().toIso8601String(),
        'expiresAt': _dateOf(data['expiresAt']),
        'lastPlayAt': _dateOf(data['lastPlayAt']),
      }),
    };
  }

  /// A server timestamp is still null in the local snapshot that precedes the server acknowledgement.
  String? _dateOf(Object? timestamp) => switch (timestamp) {
    Timestamp() => timestamp.toDate().toIso8601String(),
    _ => null,
  };
}
