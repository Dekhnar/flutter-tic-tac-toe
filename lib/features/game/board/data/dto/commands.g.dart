// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commands.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GamePatchCommand extends GamePatchCommand {
  @override
  final BuiltList<int>? boardStateRow;
  @override
  final BuiltList<int>? boardStateCol;
  @override
  final int? boardStateDiag;
  @override
  final int? boardStateAnti;
  @override
  final int? boardStateMoveCount;
  @override
  final String? status;
  @override
  final String? currentPlayerId;
  @override
  final String? currentWinnerId;
  @override
  final bool? fromWins;
  @override
  final bool? toWins;
  @override
  final bool? hasMoved;
  @override
  final int? currentRoundIndex;

  factory _$GamePatchCommand([
    void Function(GamePatchCommandBuilder)? updates,
  ]) => (GamePatchCommandBuilder()..update(updates))._build();

  _$GamePatchCommand._({
    this.boardStateRow,
    this.boardStateCol,
    this.boardStateDiag,
    this.boardStateAnti,
    this.boardStateMoveCount,
    this.status,
    this.currentPlayerId,
    this.currentWinnerId,
    this.fromWins,
    this.toWins,
    this.hasMoved,
    this.currentRoundIndex,
  }) : super._();
  @override
  GamePatchCommand rebuild(void Function(GamePatchCommandBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GamePatchCommandBuilder toBuilder() =>
      GamePatchCommandBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GamePatchCommand &&
        boardStateRow == other.boardStateRow &&
        boardStateCol == other.boardStateCol &&
        boardStateDiag == other.boardStateDiag &&
        boardStateAnti == other.boardStateAnti &&
        boardStateMoveCount == other.boardStateMoveCount &&
        status == other.status &&
        currentPlayerId == other.currentPlayerId &&
        currentWinnerId == other.currentWinnerId &&
        fromWins == other.fromWins &&
        toWins == other.toWins &&
        hasMoved == other.hasMoved &&
        currentRoundIndex == other.currentRoundIndex;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, boardStateRow.hashCode);
    _$hash = $jc(_$hash, boardStateCol.hashCode);
    _$hash = $jc(_$hash, boardStateDiag.hashCode);
    _$hash = $jc(_$hash, boardStateAnti.hashCode);
    _$hash = $jc(_$hash, boardStateMoveCount.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, currentPlayerId.hashCode);
    _$hash = $jc(_$hash, currentWinnerId.hashCode);
    _$hash = $jc(_$hash, fromWins.hashCode);
    _$hash = $jc(_$hash, toWins.hashCode);
    _$hash = $jc(_$hash, hasMoved.hashCode);
    _$hash = $jc(_$hash, currentRoundIndex.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GamePatchCommand')
          ..add('boardStateRow', boardStateRow)
          ..add('boardStateCol', boardStateCol)
          ..add('boardStateDiag', boardStateDiag)
          ..add('boardStateAnti', boardStateAnti)
          ..add('boardStateMoveCount', boardStateMoveCount)
          ..add('status', status)
          ..add('currentPlayerId', currentPlayerId)
          ..add('currentWinnerId', currentWinnerId)
          ..add('fromWins', fromWins)
          ..add('toWins', toWins)
          ..add('hasMoved', hasMoved)
          ..add('currentRoundIndex', currentRoundIndex))
        .toString();
  }
}

class GamePatchCommandBuilder
    implements Builder<GamePatchCommand, GamePatchCommandBuilder> {
  _$GamePatchCommand? _$v;

  ListBuilder<int>? _boardStateRow;
  ListBuilder<int> get boardStateRow =>
      _$this._boardStateRow ??= ListBuilder<int>();
  set boardStateRow(ListBuilder<int>? boardStateRow) =>
      _$this._boardStateRow = boardStateRow;

  ListBuilder<int>? _boardStateCol;
  ListBuilder<int> get boardStateCol =>
      _$this._boardStateCol ??= ListBuilder<int>();
  set boardStateCol(ListBuilder<int>? boardStateCol) =>
      _$this._boardStateCol = boardStateCol;

  int? _boardStateDiag;
  int? get boardStateDiag => _$this._boardStateDiag;
  set boardStateDiag(int? boardStateDiag) =>
      _$this._boardStateDiag = boardStateDiag;

  int? _boardStateAnti;
  int? get boardStateAnti => _$this._boardStateAnti;
  set boardStateAnti(int? boardStateAnti) =>
      _$this._boardStateAnti = boardStateAnti;

  int? _boardStateMoveCount;
  int? get boardStateMoveCount => _$this._boardStateMoveCount;
  set boardStateMoveCount(int? boardStateMoveCount) =>
      _$this._boardStateMoveCount = boardStateMoveCount;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _currentPlayerId;
  String? get currentPlayerId => _$this._currentPlayerId;
  set currentPlayerId(String? currentPlayerId) =>
      _$this._currentPlayerId = currentPlayerId;

  String? _currentWinnerId;
  String? get currentWinnerId => _$this._currentWinnerId;
  set currentWinnerId(String? currentWinnerId) =>
      _$this._currentWinnerId = currentWinnerId;

  bool? _fromWins;
  bool? get fromWins => _$this._fromWins;
  set fromWins(bool? fromWins) => _$this._fromWins = fromWins;

  bool? _toWins;
  bool? get toWins => _$this._toWins;
  set toWins(bool? toWins) => _$this._toWins = toWins;

  bool? _hasMoved;
  bool? get hasMoved => _$this._hasMoved;
  set hasMoved(bool? hasMoved) => _$this._hasMoved = hasMoved;

  int? _currentRoundIndex;
  int? get currentRoundIndex => _$this._currentRoundIndex;
  set currentRoundIndex(int? currentRoundIndex) =>
      _$this._currentRoundIndex = currentRoundIndex;

  GamePatchCommandBuilder();

  GamePatchCommandBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _boardStateRow = $v.boardStateRow?.toBuilder();
      _boardStateCol = $v.boardStateCol?.toBuilder();
      _boardStateDiag = $v.boardStateDiag;
      _boardStateAnti = $v.boardStateAnti;
      _boardStateMoveCount = $v.boardStateMoveCount;
      _status = $v.status;
      _currentPlayerId = $v.currentPlayerId;
      _currentWinnerId = $v.currentWinnerId;
      _fromWins = $v.fromWins;
      _toWins = $v.toWins;
      _hasMoved = $v.hasMoved;
      _currentRoundIndex = $v.currentRoundIndex;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GamePatchCommand other) {
    _$v = other as _$GamePatchCommand;
  }

  @override
  void update(void Function(GamePatchCommandBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GamePatchCommand build() => _build();

  _$GamePatchCommand _build() {
    _$GamePatchCommand _$result;
    try {
      _$result =
          _$v ??
          _$GamePatchCommand._(
            boardStateRow: _boardStateRow?.build(),
            boardStateCol: _boardStateCol?.build(),
            boardStateDiag: boardStateDiag,
            boardStateAnti: boardStateAnti,
            boardStateMoveCount: boardStateMoveCount,
            status: status,
            currentPlayerId: currentPlayerId,
            currentWinnerId: currentWinnerId,
            fromWins: fromWins,
            toWins: toWins,
            hasMoved: hasMoved,
            currentRoundIndex: currentRoundIndex,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'boardStateRow';
        _boardStateRow?.build();
        _$failedField = 'boardStateCol';
        _boardStateCol?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'GamePatchCommand',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
