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

 Board get board; PlayerId get currentPlayerId; int get currentRoundIndex; PlayerId? get currentWinnerId; PlayerId? get guestId; String? get guestName; int get guestWinCount; PlayerId get hostId; String get hostName; int get hostWinCount; GameId get id; GameStatus get status;
/// Create a copy of Game
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameCopyWith<Game> get copyWith => _$GameCopyWithImpl<Game>(this as Game, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Game&&(identical(other.board, board) || other.board == board)&&(identical(other.currentPlayerId, currentPlayerId) || other.currentPlayerId == currentPlayerId)&&(identical(other.currentRoundIndex, currentRoundIndex) || other.currentRoundIndex == currentRoundIndex)&&(identical(other.currentWinnerId, currentWinnerId) || other.currentWinnerId == currentWinnerId)&&(identical(other.guestId, guestId) || other.guestId == guestId)&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.guestWinCount, guestWinCount) || other.guestWinCount == guestWinCount)&&(identical(other.hostId, hostId) || other.hostId == hostId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.hostWinCount, hostWinCount) || other.hostWinCount == hostWinCount)&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,board,currentPlayerId,currentRoundIndex,currentWinnerId,guestId,guestName,guestWinCount,hostId,hostName,hostWinCount,id,status);

@override
String toString() {
  return 'Game(board: $board, currentPlayerId: $currentPlayerId, currentRoundIndex: $currentRoundIndex, currentWinnerId: $currentWinnerId, guestId: $guestId, guestName: $guestName, guestWinCount: $guestWinCount, hostId: $hostId, hostName: $hostName, hostWinCount: $hostWinCount, id: $id, status: $status)';
}


}

/// @nodoc
abstract mixin class $GameCopyWith<$Res>  {
  factory $GameCopyWith(Game value, $Res Function(Game) _then) = _$GameCopyWithImpl;
@useResult
$Res call({
 Board board, PlayerId currentPlayerId, int currentRoundIndex, PlayerId? currentWinnerId, PlayerId? guestId, String? guestName, int guestWinCount, PlayerId hostId, String hostName, int hostWinCount, GameId id, GameStatus status
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
@pragma('vm:prefer-inline') @override $Res call({Object? board = null,Object? currentPlayerId = null,Object? currentRoundIndex = null,Object? currentWinnerId = freezed,Object? guestId = freezed,Object? guestName = freezed,Object? guestWinCount = null,Object? hostId = null,Object? hostName = null,Object? hostWinCount = null,Object? id = null,Object? status = null,}) {
  return _then(Game(
board: null == board ? _self.board : board // ignore: cast_nullable_to_non_nullable
as Board,currentPlayerId: null == currentPlayerId ? _self.currentPlayerId : currentPlayerId // ignore: cast_nullable_to_non_nullable
as PlayerId,currentRoundIndex: null == currentRoundIndex ? _self.currentRoundIndex : currentRoundIndex // ignore: cast_nullable_to_non_nullable
as int,currentWinnerId: freezed == currentWinnerId ? _self.currentWinnerId : currentWinnerId // ignore: cast_nullable_to_non_nullable
as PlayerId?,guestId: freezed == guestId ? _self.guestId : guestId // ignore: cast_nullable_to_non_nullable
as PlayerId?,guestName: freezed == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String?,guestWinCount: null == guestWinCount ? _self.guestWinCount : guestWinCount // ignore: cast_nullable_to_non_nullable
as int,hostId: null == hostId ? _self.hostId : hostId // ignore: cast_nullable_to_non_nullable
as PlayerId,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,hostWinCount: null == hostWinCount ? _self.hostWinCount : hostWinCount // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as GameId,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GameStatus,
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
mixin _$Board {

 List<CellMark?> get cells;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Board&&const DeepCollectionEquality().equals(other.cells, cells));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(cells));

@override
String toString() {
  return 'Board(cells: $cells)';
}


}




/// Adds pattern-matching-related methods to [Board].
extension BoardPatterns on Board {
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
