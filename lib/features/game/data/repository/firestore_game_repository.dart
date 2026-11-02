import 'dart:math';

import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_app/features/game/data/dto/game_document.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_repository.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_rules.dart';

/// Stores online games in Firestore. Every write applies [GameRules] to the game as the server has it, in a
/// transaction, and `firestore.rules` check the result again on the server.
final class FirestoreGameRepository implements OnlineGameRepository {
  FirestoreGameRepository({
    @visibleForTesting Clock clock = const Clock(),
    required FirebaseFirestore firestore,
    @visibleForTesting Random? random,
  }) : _clock = clock,
       _firestore = firestore,
       _random = random ?? Random.secure();

  /// How long a game stays on the server: a TTL policy on `expiresAt` deletes it, see README.
  static const lifetime = Duration(days: 30);

  /// Codes are read and typed by players: no 0/O or 1/I to confuse.
  static const _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _codeLength = 6;
  static const _codeAttempts = 5;

  static const _rules = GameRules();

  final Clock _clock;
  final FirebaseFirestore _firestore;
  final Random _random;

  /// Creates the game under a short code no other game uses.
  @override
  Future<GameId> createGame({required PlayerId host, required String hostName}) => _runTransaction((transaction) async {
    for (var attempt = 0; attempt < _codeAttempts; attempt++) {
      final gameId = _newCode();
      final gameRef = _gameRef(gameId);
      if ((await transaction.get(gameRef)).exists) continue;

      final game = Game(
        currentPlayerId: host,
        host: Player(id: host, name: hostName),
        id: gameId,
        status: GameStatus.setup,
      );
      transaction.set(gameRef, GameDocument.write(GameWrite.create, game, expiresAt: _clock.now().add(lifetime)));
      return gameId;
    }
    throw StateError('No free game code after $_codeAttempts attempts');
  });

  @override
  Future<void> joinGame(GameId gameId, {required PlayerId guest, required String guestName}) async {
    // The code is typed by the player: one that cannot be a document id names no game.
    if (!_isDocumentId(gameId.value)) throw GameNotFoundException();

    await _update(gameId, GameWrite.join, (game) => _rules.join(game, guest: guest, guestName: guestName));
  }

  /// Leaving a game the server no longer has changes nothing.
  @override
  Future<void> leaveGame(GameId gameId) async {
    try {
      await _update(gameId, GameWrite.leave, _rules.leave);
    } on GameNotFoundException {
      return;
    }
  }

  /// Offline, a game missing from the cache is not known to be missing: the stream waits for the server instead.
  @override
  Stream<Game> watchGame(GameId gameId) => _gameRef(
    gameId,
  ).snapshots().where((snapshot) => snapshot.exists || !snapshot.metadata.isFromCache).map(GameDocument.read);

  @override
  Future<void> startGame({required GameId gameId}) => _update(gameId, GameWrite.start, _rules.start);

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required Cell cell}) =>
      _update(gameId, GameWrite.move, (game) => _rules.applyMove(game: game, playerId: playerId, cell: cell));

  @override
  Future<void> startNewRound({required GameId gameId}) => _update(gameId, GameWrite.newRound, _rules.startNewRound);

  DocumentReference<Map<String, dynamic>> _gameRef(GameId gameId) => _firestore.collection('games').doc(gameId.value);

  GameId _newCode() => GameId(
    String.fromCharCodes([
      for (var i = 0; i < _codeLength; i++) _codeAlphabet.codeUnitAt(_random.nextInt(_codeAlphabet.length)),
    ]),
  );

  /// Applies [change] to the game as the server has it; a null change, a request already fulfilled, writes nothing.
  Future<void> _update(GameId gameId, GameWrite write, Game? Function(Game game) change) {
    final gameRef = _gameRef(gameId);

    return _runTransaction((transaction) async {
      final changed = change(GameDocument.read(await transaction.get(gameRef)));
      if (changed != null) transaction.update(gameRef, GameDocument.write(write, changed));
    });
  }

  /// A transaction that read the game before the other player changed it is refused by the rules, which check the
  /// write against the new game, rather than retried by Firestore: it runs once more, against the game as it is now.
  Future<T> _runTransaction<T>(TransactionHandler<T> write) async {
    try {
      return await _firestore.runTransaction(write);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;

      return _firestore.runTransaction(write);
    }
  }

  static bool _isDocumentId(String id) =>
      id.isNotEmpty &&
      id.length <= 1500 &&
      !id.contains('/') &&
      id != '.' &&
      id != '..' &&
      !(id.startsWith('__') && id.endsWith('__'));
}
