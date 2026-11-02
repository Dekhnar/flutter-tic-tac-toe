import 'dart:async';

import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/data/dto/commands.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game_rules.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

part 'game_repository_provider.g.dart';

@riverpod
GameRepository gameRepository(Ref ref) => GameRepository(firestore: FirebaseFirestore.instance);

final class GameRepository extends GameRepositoryInterface {
  final FirebaseFirestore _firestore;
  final AsyncCallback? _beforeMakeMove;

  const GameRepository({
    required FirebaseFirestore firestore,
    @visibleForTesting AsyncCallback? beforeMakeMove,
    @visibleForTesting Clock clock = const Clock(),
    @visibleForTesting GameRules rules = const GameRules(),
  }) : _firestore = firestore,
       _beforeMakeMove = beforeMakeMove,
       _clock = clock,
       _rules = rules;

  final GameRules _rules;
  final Clock _clock;

  CollectionReference<Map<String, dynamic>> get _games => _firestore.collection('games');

  Future<Game> createGame({required String authorUid, required String shareLink}) async {
    final ref = await _games.add(CreateGameCommand(fromId: authorUid, shareLink: shareLink).toFirestore());
    final snapshot = await ref.get();

    return _parseGame(snapshot);
  }

  Future<Game> joinGame({required String shareLink, required String joinerUid}) async {
    final qs = await _games.where('shareLink', isEqualTo: shareLink).limit(1).get();
    if (qs.docs.isEmpty) {
      throw GameNotFoundException();
    }
    final gameRef = qs.docs.first.reference;

    await _firestore.runTransaction((tx) async {
      final game = _parseGame(await tx.get(gameRef));
      if (game.toId != null) throw GameAlreadyFullException();

      tx.update(gameRef, JoinGameCommand(joinerUid: joinerUid).toFirestore());
    });

    return _parseGame(await gameRef.get());
  }

  @override
  Stream<Game> watchGame(String gameId) {
    final gameRef = _games.doc(gameId);

    final controller = StreamController<Game>();
    StreamSubscription? gameSub;
    StreamSubscription? movesSub;
    Game? latestGame;

    List<Move> latestMoves = const [];

    void emit() {
      if (latestGame case final latestGame?) {
        controller.add(latestGame.copyWith(moves: latestMoves));
      }
    }

    void listenMoves(int round) {
      movesSub?.cancel();

      movesSub = gameRef.collection('moves').where('round', isEqualTo: round).snapshots().listen((qs) {
        final moves = qs.docs.map((d) => Move.fromJson(d.data())).toList(growable: false)
          ..sort((a, b) => a.turn.compareTo(b.turn)); // sorted client-side: `where` + `orderBy` needs a composite index
        latestMoves = moves;
        emit();
      }, onError: controller.addError);
    }

    gameSub = gameRef.snapshots().listen(
      (snap) {
        if (!snap.exists) return;

        final game = _parseGame(snap);
        final prevRound = latestGame?.currentRoundIndex;

        latestGame = game;

        if (prevRound != game.currentRoundIndex) {
          listenMoves(game.currentRoundIndex);
        }

        emit();
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    controller.onCancel = () {
      gameSub?.cancel();
      movesSub?.cancel();
    };

    return controller.stream;
  }

  @override
  Future<void> makeMove({required String gameId, required String playerId, required int row, required int col}) async {
    if (!_rules.isOnBoard(row: row, col: col)) throw MoveCellIndexInvalidException();
    final index = row * GameRules.boardSize + col;

    await _beforeMakeMove?.call();

    await _firestore.runTransaction((tx) async {
      final gameRef = _games.doc(gameId);
      final currentGame = _parseGame(await tx.get(gameRef));

      if (currentGame.status == GameStatus.finished) throw MoveGameFinishedException();
      if (currentGame.status == GameStatus.setup) throw MoveGameNotStartedException();
      if (currentGame.toId == null) throw MoveOpponentMissingException();
      if (currentGame.currentPlayerId != playerId) throw MoveNotYourTurnException();

      final moveRef = gameRef.collection('moves').doc('${currentGame.currentRoundIndex}:$index');
      final moveSnap = await tx.get(moveRef);
      if (moveSnap.exists) throw MoveCellAlreadyTakenException();

      final updatedGame = _rules.applyMove(
        game: currentGame,
        playerId: playerId,
        row: row,
        col: col,
        currentDate: _clock.now(),
      );

      if (updatedGame == null) throw StateError('Move rejected by the rules after passing every check');

      tx.set(moveRef, MoveEventCommand(move: updatedGame.moves.last).toFirestore());
      tx.update(gameRef, GameStateCommand(game: updatedGame).toFirestore());
    });
  }

  @override
  Future<void> startNewRound({required String gameId}) async {
    await _firestore.runTransaction((tx) async {
      final gameRef = _games.doc(gameId);
      final currentGame = _parseGame(await tx.get(gameRef));

      // Both players see "play again": the second request finds the round already started and does nothing.
      final nextRound = _rules.startNewRound(game: currentGame, currentDate: _clock.now());
      if (nextRound == null) return;

      tx.update(gameRef, GameStateCommand(game: nextRound).toFirestore());
    });
  }

  @override
  Future<void> startGame({required String gameId}) async {
    await _firestore.runTransaction((tx) async {
      final gameRef = _games.doc(gameId);
      final currentGame = _parseGame(await tx.get(gameRef));

      if (currentGame.status != GameStatus.setup) return;
      if (currentGame.toId == null) throw MoveOpponentMissingException();

      tx.update(gameRef, const StartGameCommand().toFirestore());
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
