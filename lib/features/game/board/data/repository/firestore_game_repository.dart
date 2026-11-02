import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tic_tac_toe_app/features/game/board/data/dto/game_document.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_ids.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';

/// Stores online games in Firestore. Every write applies [GameRules] to the game as the server has it, in a
/// transaction, and `firestore.rules` check the result again on the server.
final class FirestoreGameRepository implements OnlineGameRepositoryInterface {
  const FirestoreGameRepository({@visibleForTesting Clock clock = const Clock(), required FirebaseFirestore firestore})
    : _clock = clock,
      _firestore = firestore;

  /// How long a game stays on the server: a TTL policy on `expiresAt` deletes it, see README.
  static const lifetime = Duration(days: 30);

  static const _rules = GameRules();

  final Clock _clock;
  final FirebaseFirestore _firestore;

  @override
  Future<void> createGame(GameId gameId, {required PlayerId host, required String hostName}) async {
    final gameRef = _gameRef(gameId);
    final game = Game(currentPlayerId: host, fromId: host, fromName: hostName, id: gameId, status: GameStatus.setup);

    await _runTransaction((transaction) async {
      if ((await transaction.get(gameRef)).exists) throw StateError('A game already uses the id ${gameId.value}');

      transaction.set(gameRef, GameDocument.write(GameWrite.create, game, expiresAt: _clock.now().add(lifetime)));
    });
  }

  @override
  Future<void> joinGame(GameId gameId, {required PlayerId guest, required String guestName}) async {
    // The code is typed by the player: one that cannot be a document id names no game.
    if (!_isDocumentId(gameId.value)) throw GameNotFoundException();

    await _update(gameId, GameWrite.join, (game) => _rules.join(game, guest: guest, guestName: guestName));
  }

  @override
  Stream<Game> watchGame(GameId gameId) => _gameRef(gameId).snapshots().map(GameDocument.read);

  @override
  Future<void> startGame({required GameId gameId}) => _update(gameId, GameWrite.start, _rules.start);

  @override
  Future<void> makeMove({required GameId gameId, required PlayerId playerId, required int row, required int col}) =>
      _update(gameId, GameWrite.move, (game) => _rules.applyMove(game: game, playerId: playerId, row: row, col: col));

  @override
  Future<void> startNewRound({required GameId gameId}) => _update(gameId, GameWrite.newRound, _rules.startNewRound);

  DocumentReference<Map<String, dynamic>> _gameRef(GameId gameId) => _firestore.collection('games').doc(gameId.value);

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
  Future<void> _runTransaction(TransactionHandler<void> write) async {
    try {
      await _firestore.runTransaction(write);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') rethrow;

      await _firestore.runTransaction(write);
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
