// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Game {

 BoardState get boardState; DateTime get createdAt; PlayerId get currentPlayerId; int get currentRoundIndex; PlayerId? get currentWinnerId; DateTime? get expiresAt; PlayerId get fromId; String get fromName; int get fromWinCount; GameId get id; DateTime? get lastPlayAt; List<Move> get moves; GameStatus get status; PlayerId? get toId; String? get toName; int get toWinCount; DateTime get updatedAt; bool get vsAi;
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.boardState, boardState) || other.boardState == boardState)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.currentPlayerId, currentPlayerId) || other.currentPlayerId == currentPlayerId)&&(identical(other.currentRoundIndex, currentRoundIndex) || other.currentRoundIndex == currentRoundIndex)&&(identical(other.currentWinnerId, currentWinnerId) || other.currentWinnerId == currentWinnerId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.fromId, fromId) || other.fromId == fromId)&&(identical(other.fromName, fromName) || other.fromName == fromName)&&(identical(other.fromWinCount, fromWinCount) || other.fromWinCount == fromWinCount)&&(identical(other.id, id) || other.id == id)&&(identical(other.lastPlayAt, lastPlayAt) || other.lastPlayAt == lastPlayAt)&&const DeepCollectionEquality().equals(other.moves, moves)&&(identical(other.status, status) || other.status == status)&&(identical(other.toId, toId) || other.toId == toId)&&(identical(other.toName, toName) || other.toName == toName)&&(identical(other.toWinCount, toWinCount) || other.toWinCount == toWinCount)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.vsAi, vsAi) || other.vsAi == vsAi));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,boardState,createdAt,currentPlayerId,currentRoundIndex,currentWinnerId,expiresAt,fromId,fromName,fromWinCount,id,lastPlayAt,const DeepCollectionEquality().hash(moves),status,toId,toName,toWinCount,updatedAt,vsAi);

@override
String toString() {
  return 'Game(boardState: $boardState, createdAt: $createdAt, currentPlayerId: $currentPlayerId, currentRoundIndex: $currentRoundIndex, currentWinnerId: $currentWinnerId, expiresAt: $expiresAt, fromId: $fromId, fromName: $fromName, fromWinCount: $fromWinCount, id: $id, lastPlayAt: $lastPlayAt, moves: $moves, status: $status, toId: $toId, toName: $toName, toWinCount: $toWinCount, updatedAt: $updatedAt, vsAi: $vsAi)';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 BoardState boardState, DateTime createdAt, PlayerId currentPlayerId, int currentRoundIndex, PlayerId? currentWinnerId, DateTime? expiresAt, PlayerId fromId, String fromName, int fromWinCount, GameId id, DateTime? lastPlayAt, List<Move> moves, GameStatus status, PlayerId? toId, String? toName, int toWinCount, DateTime updatedAt, bool vsAi
});




}
/// @nodoc
class _$GameCopyWithImpl<$Res>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._self, this._then);

  final Game _self;
  final $Res Function(Game) _then;

/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? boardState = null,Object? createdAt = null,Object? currentPlayerId = null,Object? currentRoundIndex = null,Object? currentWinnerId = freezed,Object? expiresAt = freezed,Object? fromId = null,Object? fromName = null,Object? fromWinCount = null,Object? id = null,Object? lastPlayAt = freezed,Object? moves = null,Object? status = null,Object? toId = freezed,Object? toName = freezed,Object? toWinCount = null,Object? updatedAt = null,Object? vsAi = null,}) {
  return _then(Game(
boardState: null == boardState ? _self.boardState : boardState // ignore: cast_nullable_to_non_nullable
as BoardState,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,currentPlayerId: null == currentPlayerId ? _self.currentPlayerId : currentPlayerId // ignore: cast_nullable_to_non_nullable
as PlayerId,currentRoundIndex: null == currentRoundIndex ? _self.currentRoundIndex : currentRoundIndex // ignore: cast_nullable_to_non_nullable
as int,currentWinnerId: freezed == currentWinnerId ? _self.currentWinnerId : currentWinnerId // ignore: cast_nullable_to_non_nullable
as PlayerId?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,fromId: null == fromId ? _self.fromId : fromId // ignore: cast_nullable_to_non_nullable
as PlayerId,fromName: null == fromName ? _self.fromName : fromName // ignore: cast_nullable_to_non_nullable
as String,fromWinCount: null == fromWinCount ? _self.fromWinCount : fromWinCount // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as GameId,lastPlayAt: freezed == lastPlayAt ? _self.lastPlayAt : lastPlayAt // ignore: cast_nullable_to_non_nullable
as DateTime?,moves: null == moves ? _self.moves : moves // ignore: cast_nullable_to_non_nullable
as List<Move>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,toId: freezed == toId ? _self.toId : toId // ignore: cast_nullable_to_non_nullable
as PlayerId?,toName: freezed == toName ? _self.toName : toName // ignore: cast_nullable_to_non_nullable
as String?,toWinCount: null == toWinCount ? _self.toWinCount : toWinCount // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,vsAi: null == vsAi ? _self.vsAi : vsAi // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Game].
extension GamePatterns on Game {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}


/// @nodoc
mixin _$Move {

 int get index; CellMark get mark; PlayerId get playerId; int get round; int get turn;
/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveCopyWith<Move> get copyWith => _$MoveCopyWithImpl<Move>(this as Move, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Move&&(identical(other.index, index) || other.index == index)&&(identical(other.mark, mark) || other.mark == mark)&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.round, round) || other.round == round)&&(identical(other.turn, turn) || other.turn == turn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,mark,playerId,round,turn);

@override
String toString() {
  return 'Move(index: $index, mark: $mark, playerId: $playerId, round: $round, turn: $turn)';
}


}

/// @nodoc
abstract mixin class $MoveCopyWith<$Res>  {
  factory $MoveCopyWith(Move value, $Res Function(Move) _then) = _$MoveCopyWithImpl;
@useResult
$Res call({
 int index, CellMark mark, PlayerId playerId, int round, int turn
});




}
/// @nodoc
class _$MoveCopyWithImpl<$Res>
    implements $MoveCopyWith<$Res> {
  _$MoveCopyWithImpl(this._self, this._then);

  final Move _self;
  final $Res Function(Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? mark = null,Object? playerId = null,Object? round = null,Object? turn = null,}) {
  return _then(Move(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,mark: null == mark ? _self.mark : mark // ignore: cast_nullable_to_non_nullable
as CellMark,playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as PlayerId,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as int,turn: null == turn ? _self.turn : turn // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Move].
extension MovePatterns on Move {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}


/// @nodoc
mixin _$BoardState {

 int get anti; List<int> get col; int get diag; int get moveCount; List<int> get row;
/// Create a copy of BoardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BoardStateCopyWith<BoardState> get copyWith => _$BoardStateCopyWithImpl<BoardState>(this as BoardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BoardState&&(identical(other.anti, anti) || other.anti == anti)&&const DeepCollectionEquality().equals(other.col, col)&&(identical(other.diag, diag) || other.diag == diag)&&(identical(other.moveCount, moveCount) || other.moveCount == moveCount)&&const DeepCollectionEquality().equals(other.row, row));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,anti,const DeepCollectionEquality().hash(col),diag,moveCount,const DeepCollectionEquality().hash(row));

@override
String toString() {
  return 'BoardState(anti: $anti, col: $col, diag: $diag, moveCount: $moveCount, row: $row)';
}


}

/// @nodoc
abstract mixin class $BoardStateCopyWith<$Res>  {
  factory $BoardStateCopyWith(BoardState value, $Res Function(BoardState) _then) = _$BoardStateCopyWithImpl;
@useResult
$Res call({
 int anti, List<int> col, int diag, int moveCount, List<int> row
});




}
/// @nodoc
class _$BoardStateCopyWithImpl<$Res>
    implements $BoardStateCopyWith<$Res> {
  _$BoardStateCopyWithImpl(this._self, this._then);

  final BoardState _self;
  final $Res Function(BoardState) _then;

/// Create a copy of BoardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? anti = null,Object? col = null,Object? diag = null,Object? moveCount = null,Object? row = null,}) {
  return _then(BoardState(
anti: null == anti ? _self.anti : anti // ignore: cast_nullable_to_non_nullable
as int,col: null == col ? _self.col : col // ignore: cast_nullable_to_non_nullable
as List<int>,diag: null == diag ? _self.diag : diag // ignore: cast_nullable_to_non_nullable
as int,moveCount: null == moveCount ? _self.moveCount : moveCount // ignore: cast_nullable_to_non_nullable
as int,row: null == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [BoardState].
extension BoardStatePatterns on BoardState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
