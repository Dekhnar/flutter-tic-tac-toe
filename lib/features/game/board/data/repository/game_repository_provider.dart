import 'dart:async';

import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/data/dto/commands.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

part 'game_repository_provider.g.dart';

@riverpod
GameRepository gameRepository(Ref ref) => GameRepository(firestore: FirebaseFirestore.instance);

final class GameRepository implements GameRepositoryInterface {
  const GameRepository({
    @visibleForTesting AsyncCallback? beforeMakeMove,
    @visibleForTesting Clock clock = const Clock(),
    required FirebaseFirestore firestore,
    @visibleForTesting GameRules rules = const GameRules(),
  }) : _beforeMakeMove = beforeMakeMove,
       _clock = clock,
       _firestore = firestore,
       _rules = rules;

  final AsyncCallback? _beforeMakeMove;
  final Clock _clock;
  final FirebaseFirestore _firestore;
  final GameRules _rules;

  CollectionReference<Map<String, dynamic>> get _games => _firestore.collection('games');

  Future<Game> createGame({required String authorUid, required String shareLink}) async {
    final gameRef = await _games.add(CreateGameCommand(fromId: authorUid, shareLink: shareLink).toFirestore());
    final snapshot = await gameRef.get();

    return _parseGame(snapshot);
  }

  Future<Game> joinGame({required String shareLink, required String joinerUid}) async {
    final games = await _games.where('shareLink', isEqualTo: shareLink).limit(1).get();
    if (games.docs.isEmpty) {
      throw GameNotFoundException();
    }
    final gameRef = games.docs.first.reference;

    await _firestore.runTransaction((transaction) async {
      final game = _parseGame(await transaction.get(gameRef));
      if (game.toId != null) throw GameAlreadyFullException();

      transaction.update(gameRef, JoinGameCommand(joinerUid: joinerUid).toFirestore());
    });

    return _parseGame(await gameRef.get());
  }

  @override
  Stream<Game> watchGame(String gameId) {
    final gameRef = _games.doc(gameId);

    final controller = StreamController<Game>();
    StreamSubscription? gameSubscription;
    StreamSubscription? movesSubscription;
    Game? latestGame;

    List<Move> latestMoves = const [];

    void emit() {
      if (latestGame case final latestGame?) {
        controller.add(latestGame.copyWith(moves: latestMoves));
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

      movesSubscription = gameRef
          .collection('moves')
          .where('round', isEqualTo: round)
          .snapshots()
          .listen(
            (movesSnapshot) => forwardErrors(() {
              latestMoves = movesSnapshot.docs.map((move) => Move.fromJson(move.data())).toList(growable: false)..sort(
                (a, b) => a.turn.compareTo(b.turn),
              ); // sorted client-side: `where` + `orderBy` needs a composite index
              emit();
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

        emit();
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
  Future<void> makeMove({required String gameId, required String playerId, required int row, required int col}) async {
    if (!_rules.isOnBoard(row: row, col: col)) throw MoveCellIndexInvalidException();
    final index = row * GameRules.boardSize + col;

    await _beforeMakeMove?.call();

    await _firestore.runTransaction((transaction) async {
      final gameRef = _games.doc(gameId);
      final currentGame = _parseGame(await transaction.get(gameRef));

      if (currentGame.status == GameStatus.finished) throw MoveGameFinishedException();
      if (currentGame.status == GameStatus.setup) throw MoveGameNotStartedException();
      if (currentGame.toId == null) throw MoveOpponentMissingException();
      if (currentGame.currentPlayerId != playerId) throw MoveNotYourTurnException();

      final moveRef = gameRef.collection('moves').doc('${currentGame.currentRoundIndex}:$index');
      final moveSnapshot = await transaction.get(moveRef);
      if (moveSnapshot.exists) throw MoveCellAlreadyTakenException();

      final updatedGame = _rules.applyMove(
        game: currentGame,
        playerId: playerId,
        row: row,
        col: col,
        currentDate: _clock.now(),
      );

      if (updatedGame == null) throw StateError('Move rejected by the rules after passing every check');

      transaction.set(moveRef, MoveEventCommand(move: updatedGame.moves.last).toFirestore());
      transaction.update(gameRef, GameStateCommand(game: updatedGame).toFirestore());
    });
  }

  @override
  Future<void> startNewRound({required String gameId}) async {
    await _firestore.runTransaction((transaction) async {
      final gameRef = _games.doc(gameId);
      final currentGame = _parseGame(await transaction.get(gameRef));

      // Both players see "play again": the second request finds the round already started and does nothing.
      final nextRound = _rules.startNewRound(game: currentGame, currentDate: _clock.now());
      if (nextRound == null) return;

      transaction.update(gameRef, GameStateCommand(game: nextRound).toFirestore());
    });
  }

  @override
  Future<void> startGame({required String gameId}) async {
    await _firestore.runTransaction((transaction) async {
      final gameRef = _games.doc(gameId);
      final currentGame = _parseGame(await transaction.get(gameRef));

      if (currentGame.status != GameStatus.setup) return;
      if (currentGame.toId == null) throw MoveOpponentMissingException();

      transaction.update(gameRef, const StartGameCommand().toFirestore());
    });
  }

  Game _parseGame(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return switch (snapshot.data()) {
      null => throw GameCreationDataMissingException(),
      final data => Game.fromJson({
        'id': snapshot.id,
        ...data,
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
        'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
        'lastPlayAt': (data['lastPlayAt'] as Timestamp?)?.toDate().toIso8601String(),
      }),
    };
  }
}
