import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tic_tac_toe_app/features/game/domain/game.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_exceptions.dart';
import 'package:tic_tac_toe_app/features/game/domain/game_ids.dart';

/// The fields of a game document, named as `firestore.rules` name them: no other Dart file spells one.
enum GameField {
  board,
  createdAt,
  currentPlayerId,
  currentRoundIndex,
  currentWinnerId,
  expiresAt,
  guestId,
  guestName,
  guestWinCount,
  hostId,
  hostName,
  hostWinCount,
  lastPlayAt,
  status,
  updatedAt,
}

/// The writes `firestore.rules` accept, each with exactly the fields its rule lets it change.
enum GameWrite {
  create({
    GameField.board,
    GameField.createdAt,
    GameField.currentPlayerId,
    GameField.currentRoundIndex,
    GameField.currentWinnerId,
    GameField.expiresAt,
    GameField.hostId,
    GameField.hostName,
    GameField.hostWinCount,
    GameField.status,
    GameField.guestId,
    GameField.guestName,
    GameField.guestWinCount,
    GameField.updatedAt,
  }),
  join({GameField.guestId, GameField.guestName, GameField.updatedAt}),
  start({GameField.status, GameField.updatedAt}),
  leave({GameField.status, GameField.updatedAt}),
  move({
    GameField.board,
    GameField.currentPlayerId,
    GameField.currentWinnerId,
    GameField.hostWinCount,
    GameField.lastPlayAt,
    GameField.status,
    GameField.guestWinCount,
    GameField.updatedAt,
  }),
  newRound({
    GameField.board,
    GameField.currentPlayerId,
    GameField.currentRoundIndex,
    GameField.currentWinnerId,
    GameField.lastPlayAt,
    GameField.status,
    GameField.updatedAt,
  });

  const GameWrite(this.fields);

  final Set<GameField> fields;

  /// The fields the server sets to the time of the write.
  static const serverTimeFields = {GameField.createdAt, GameField.lastPlayAt, GameField.updatedAt};
}

/// Maps a [Game] to its Firestore document and back. The document also holds what only the server needs: when it was
/// written, and when a TTL policy deletes it.
abstract final class GameDocument {
  /// The fields [write] changes, taken from [game] as it is once changed. Only a creation sets [expiresAt].
  static Map<String, Object?> write(GameWrite write, Game game, {DateTime? expiresAt}) => {
    for (final field in write.fields) field.name: _encode(field, game, expiresAt: expiresAt),
  };

  static Game read(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw GameNotFoundException();

    T field<T>(GameField field) => switch (data[field.name]) {
      final T value => value,
      final value => throw FormatException('${field.name} of game ${snapshot.id} is not a $T', value),
    };
    PlayerId? player(GameField seat) => switch (field<String?>(seat)) {
      final id? => PlayerId(id),
      null => null,
    };

    return Game(
      board: Board(cells: List.unmodifiable(field<List<Object?>>(GameField.board).map(_markOf))),
      currentPlayerId: PlayerId(field<String>(GameField.currentPlayerId)),
      currentRoundIndex: field<int>(GameField.currentRoundIndex),
      currentWinnerId: player(GameField.currentWinnerId),
      hostId: PlayerId(field<String>(GameField.hostId)),
      hostName: field<String>(GameField.hostName),
      hostWinCount: field<int>(GameField.hostWinCount),
      id: GameId(snapshot.id),
      status: GameStatus.values.byName(field<String>(GameField.status)),
      guestId: player(GameField.guestId),
      guestName: field<String?>(GameField.guestName),
      guestWinCount: field<int>(GameField.guestWinCount),
    );
  }

  static Object? _encode(GameField field, Game game, {DateTime? expiresAt}) => switch (field) {
    GameField.board => [for (final mark in game.board.cells) mark?.name ?? _emptyCell],
    GameField.createdAt || GameField.lastPlayAt || GameField.updatedAt => FieldValue.serverTimestamp(),
    GameField.currentPlayerId => game.currentPlayerId.value,
    GameField.currentRoundIndex => game.currentRoundIndex,
    GameField.currentWinnerId => game.currentWinnerId?.value,
    GameField.expiresAt => Timestamp.fromDate(expiresAt ?? (throw ArgumentError.notNull('expiresAt'))),
    GameField.hostId => game.hostId.value,
    GameField.hostName => game.hostName,
    GameField.hostWinCount => game.hostWinCount,
    GameField.status => game.status.name,
    GameField.guestId => game.guestId?.value,
    GameField.guestName => game.guestName,
    GameField.guestWinCount => game.guestWinCount,
  };

  // The rules compare cells to strings: an empty one is an empty string rather than null.
  static const _emptyCell = '';

  static CellMark? _markOf(Object? cell) => switch (cell) {
    _emptyCell => null,
    final String mark => CellMark.values.byName(mark),
    _ => throw FormatException('Not a cell of the board', cell),
  };
}
