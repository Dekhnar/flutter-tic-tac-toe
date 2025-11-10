import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tic_tac_toe_app/features/game/board/application/game_repository_interface.dart';
import 'package:tic_tac_toe_app/features/game/board/data/dto/commands.dart';
import 'package:tic_tac_toe_app/features/game/board/domain/game.dart';
import 'package:tic_tac_toe_app/shared/exceptions/app_exception.dart';

part 'game_repository_provider.g.dart';

@riverpod
GameRepository gameRepository(Ref ref) => GameRepository(firestore: FirebaseFirestore.instance);

final class GameRepository extends GameRepositoryInterface {
  final FirebaseFirestore _firestore;
  final AsyncCallback? _beforeMakeMove;

  const GameRepository({required FirebaseFirestore firestore, @visibleForTesting AsyncCallback? beforeMakeMove})
    : _firestore = firestore,
      _beforeMakeMove = beforeMakeMove;

  Future<Game> createGame({required String authorUid, required String shareLink}) async {
    final ref = await _firestore
        .collection('games')
        .add(CreateGameCommand(fromId: authorUid, shareLink: shareLink).toFirestore());
    final snapshot = await ref.get();

    return _parseGame(snapshot);
  }

  Future<Game> joinGame({required String shareLink, required String joinerUid}) async {
    final qs = await _firestore.collection('games').where('shareLink', isEqualTo: shareLink).limit(1).get();
    if (qs.docs.isEmpty) {
      throw GameNotFoundException();
    }
    final gameRef = qs.docs.first.reference;
    await gameRef.update(JoinGameCommand(joinerUid: joinerUid).toFirestore());
    final snapshot = await gameRef.get();

    return _parseGame(snapshot);
  }

  @override
  Stream<Game> watchGame(String gameId) {
    final gameRef = _firestore.collection('games').doc(gameId);

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
          ..sort((a, b) => a.turn.compareTo(b.turn)); // tri côté Dart
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
  Future<void> makeMove({required Game game, required String playerId, required int row, required int col}) async {
    final index = row * 3 + col;
    if (index >= 9) throw MoveCellIndexInvalidException();

    await _beforeMakeMove?.call();

    await _firestore.runTransaction((tx) async {
      final currentGame = _parseGame(await tx.get(_firestore.collection('games').doc(game.id)));

      if (currentGame.status == GameStatus.finished) throw MoveGameFinishedException();
      if (currentGame.status == GameStatus.setup) throw MoveGameNotStartedException();
      if (currentGame.toId == null) throw MoveOpponentMissingException();
      if (currentGame.currentPlayerId != playerId) throw MoveNotYourTurnException();
      if (currentGame.boardState.moveCount >= 9) throw MoveGameFinishedException();

      final gameRef = _firestore.collection('games').doc(currentGame.id);
      final moveRef = gameRef.collection('moves').doc('${currentGame.currentRoundIndex}:$index');
      final moveSnap = await tx.get(moveRef);
      if (moveSnap.exists) throw MoveCellAlreadyTakenException();

      final (opponentId, sign, mark) =
          (playerId == currentGame.fromId)
              ? (currentGame.toId, 1, CellMark.X.name)
              : (currentGame.fromId, -1, CellMark.O.name);

      final nextRow = List<int>.of(currentGame.boardState.row, growable: false);
      final nextCol = List<int>.of(currentGame.boardState.col, growable: false);
      nextRow[row] = nextRow[row] + sign;
      nextCol[col] = nextCol[col] + sign;

      final nextDiag = (row == col) ? (currentGame.boardState.diag + sign) : currentGame.boardState.diag;
      final nextAnti = (row + col == 2) ? (currentGame.boardState.anti + sign) : currentGame.boardState.anti;
      final nextMoveCount = currentGame.boardState.moveCount + 1;

      final win = nextRow[row].abs() == 3 || nextCol[col].abs() == 3 || nextDiag.abs() == 3 || nextAnti.abs() == 3;
      final draw = !win && nextMoveCount == 9;

      tx.set(
        moveRef,
        MoveEventCommand(
          mark: mark,
          playerId: playerId,
          index: index,
          round: currentGame.currentRoundIndex,
          turn: currentGame.boardState.moveCount,
        ).toFirestore(),
      );

      final patchCmd = GamePatchCommand(
        (b) =>
            b
              ..boardStateRow = ListBuilder<int>(nextRow)
              ..boardStateCol = ListBuilder<int>(nextCol)
              ..boardStateDiag = nextDiag
              ..boardStateAnti = nextAnti
              ..boardStateMoveCount = nextMoveCount
              ..status = (win || draw) ? GameStatus.finished.name : GameStatus.playing.name
              ..currentWinnerId = win ? playerId : null
              ..currentPlayerId = (win || draw) ? null : opponentId
              ..fromWins = win && playerId == currentGame.fromId
              ..toWins = win && playerId == currentGame.toId
              ..hasMoved = true,
      );

      tx.update(gameRef, patchCmd.toFirestore());
    });
  }

  @override
  Future<void> startNewRound({required Game game}) async {
    await _firestore.runTransaction((tx) async {
      final nextRound = game.currentRoundIndex + 1;
      final nextStarter = game.currentRoundIndex.isEven ? game.toId : game.fromId;

      tx.update(
        _firestore.doc('games/${game.id}'),
        GamePatchCommand(
          (b) =>
              b
                ..boardStateRow = ListBuilder<int>([0, 0, 0])
                ..boardStateCol = ListBuilder<int>([0, 0, 0])
                ..boardStateDiag = 0
                ..boardStateAnti = 0
                ..boardStateMoveCount = 0
                ..currentRoundIndex = nextRound
                ..status = GameStatus.playing.name
                ..currentWinnerId = null
                ..currentPlayerId = nextStarter
                ..hasMoved = false,
        ).toFirestore(),
      );
    });
  }

  @override
  Future<void> startGame({required Game game}) async {
    await _firestore.runTransaction((tx) async {
      tx.update(
        _firestore.doc('games/${game.id}'),
        GamePatchCommand(
          (b) =>
              b
                ..status = GameStatus.playing.name
                ..hasMoved = false,
        ).toFirestore(),
      );
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
