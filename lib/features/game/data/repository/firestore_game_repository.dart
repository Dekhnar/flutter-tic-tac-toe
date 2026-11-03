import 'dart:math';

import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_app/features/game/data/dto/game_document.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_code.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_rules.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_not_answering_exception.dart';
import 'package:tic_tac_toe_app/shared/exceptions/server_refused_exception.dart';

/// Stores online games in Firestore. Every write applies [GameRules] to the game as the server has it, in a
/// transaction, and `firestore.rules` check the result again.
final class FirestoreGameRepository implements OnlineGameRepository {
  FirestoreGameRepository({
    @visibleForTesting Clock clock = const Clock(),
    required FirebaseFirestore firestore,
    @visibleForTesting Random? random,
  }) : _clock = clock,
       _firestore = firestore,
       _random = random ?? Random.secure();

  /// A TTL policy on `expiresAt` deletes a game once this has passed, see README.
  static const lifetime = Duration(days: 30);

  static const _codeAttempts = 5;
  static const _rules = GameRules();

  final Clock _clock;
  final FirebaseFirestore _firestore;
  final Random _random;

  @override
  Future<GameCode> createGame({required PlayerId host, required String hostName}) => _reachingServer(
    () => _firestore.runTransaction((transaction) async {
      for (var attempt = 0; attempt < _codeAttempts; attempt++) {
        final code = GameCode.random(_random);
        final gameRef = _gameRef(code);
        if ((await transaction.get(gameRef)).exists) continue;

        final game = Game(
          currentPlayerId: host,
          host: Player(id: host, name: hostName),
          id: code,
          status: GameStatus.setup,
        );
        transaction.set(gameRef, GameDocument.write(GameWrite.create, game, expiresAt: _clock.now().add(lifetime)));
        return code;
      }
      throw StateError('No free game code after $_codeAttempts attempts');
    }),
  );

  @override
  Future<void> joinGame(GameCode code, {required PlayerId guest, required String guestName}) =>
      _update(code, GameWrite.join, (game) => _rules.join(game, guest: guest, guestName: guestName));

  /// Leaving a game the server no longer has changes nothing.
  @override
  Future<void> leaveGame(GameId gameId) async {
    try {
      await _update(gameId, GameWrite.leave, _rules.leave);
    } on GameNotFoundException {
      return;
    }
  }

  /// Offline, a game missing from the cache may still be on the server: the stream waits for the server instead.
  @override
  Stream<Game> watchGame(GameId gameId) => _gameRef(
    gameId,
  ).snapshots().where((snapshot) => snapshot.exists || !snapshot.metadata.isFromCache).map(GameDocument.read);

  @override
  Future<void> startGame({required GameId gameId}) => _update(gameId, GameWrite.start, _rules.start);

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell}) => _update(
    gameId,
    GameWrite.move,
    (game) => GameChange.changed(_rules.applyMove(game: game, playerId: playerId, cell: cell)),
  );

  @override
  Future<void> startNewRound({required GameId gameId}) => _update(gameId, GameWrite.newRound, _rules.startNewRound);

  DocumentReference<Map<String, dynamic>> _gameRef(GameId gameId) => _firestore.collection('games').doc(gameId.value);

  /// Applies [change] to the game as the server has it.
  ///
  /// The rules check a write against the game as it is when the write lands. A transaction that read the game before
  /// the other player changed it is therefore refused with `permission-denied` rather than retried by Firestore: it
  /// runs once more when the game did change. A refusal of an unchanged game stands.
  Future<void> _update(GameId gameId, GameWrite write, GameChange Function(Game game) change) {
    final gameRef = _gameRef(gameId);
    Object? readVersion;
    Future<void> attempt() => _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(gameRef);
      readVersion = GameDocument.versionOf(snapshot);
      if (change(GameDocument.read(snapshot)) case GameChanged(:final game)) {
        transaction.update(gameRef, GameDocument.write(write, game));
      }
    });

    return _reachingServer(() async {
      try {
        await attempt();
      } on FirebaseException catch (error) {
        if (error.code != 'permission-denied') rethrow;

        final current = await gameRef.get(const GetOptions(source: Source.server));
        if (GameDocument.versionOf(current) == readVersion) rethrow;

        await attempt();
      }
    });
  }

  /// Turns the failures a player can do something about into the exceptions the app explains.
  static Future<T> _reachingServer<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(switch (error.code) {
        'unavailable' || 'deadline-exceeded' => ServerNotAnsweringException(error),
        'permission-denied' => ServerRefusedException(error),
        _ => error,
      }, stackTrace);
    }
  }
}
