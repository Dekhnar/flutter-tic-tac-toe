// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameSession {

 GameId get gameId;
/// Create a copy of GameSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameSessionCopyWith<GameSession> get copyWith => _$GameSessionCopyWithImpl<GameSession>(this as GameSession, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameSession&&(identical(other.gameId, gameId) || other.gameId == gameId));
}


@override
int get hashCode => Object.hash(runtimeType,gameId);

@override
String toString() {
  return 'GameSession(gameId: $gameId)';
}


}

/// @nodoc
abstract mixin class $GameSessionCopyWith<$Res>  {
  factory $GameSessionCopyWith(GameSession value, $Res Function(GameSession) _then) = _$GameSessionCopyWithImpl;
@useResult
$Res call({
 GameId gameId
});




}
/// @nodoc
class _$GameSessionCopyWithImpl<$Res>
    implements $GameSessionCopyWith<$Res> {
  _$GameSessionCopyWithImpl(this._self, this._then);

  final GameSession _self;
  final $Res Function(GameSession) _then;

/// Create a copy of GameSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gameId = null,}) {
  return _then(_self.copyWith(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as GameId,
  ));
}

}


/// Adds pattern-matching-related methods to [GameSession].
extension GameSessionPatterns on GameSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LocalGameSession value)?  local,TResult Function( OnlineGameSession value)?  online,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LocalGameSession() when local != null:
return local(_that);case OnlineGameSession() when online != null:
return online(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LocalGameSession value)  local,required TResult Function( OnlineGameSession value)  online,}){
final _that = this;
switch (_that) {
case LocalGameSession():
return local(_that);case OnlineGameSession():
return online(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LocalGameSession value)?  local,TResult? Function( OnlineGameSession value)?  online,}){
final _that = this;
switch (_that) {
case LocalGameSession() when local != null:
return local(_that);case OnlineGameSession() when online != null:
return online(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( GameId gameId)?  local,TResult Function( GameId gameId,  PlayerId me)?  online,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LocalGameSession() when local != null:
return local(_that.gameId);case OnlineGameSession() when online != null:
return online(_that.gameId,_that.me);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( GameId gameId)  local,required TResult Function( GameId gameId,  PlayerId me)  online,}) {final _that = this;
switch (_that) {
case LocalGameSession():
return local(_that.gameId);case OnlineGameSession():
return online(_that.gameId,_that.me);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( GameId gameId)?  local,TResult? Function( GameId gameId,  PlayerId me)?  online,}) {final _that = this;
switch (_that) {
case LocalGameSession() when local != null:
return local(_that.gameId);case OnlineGameSession() when online != null:
return online(_that.gameId,_that.me);case _:
  return null;

}
}

}

/// @nodoc


class LocalGameSession implements GameSession {
  const LocalGameSession({required this.gameId});
  

@override final  GameId gameId;

/// Create a copy of GameSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalGameSessionCopyWith<LocalGameSession> get copyWith => _$LocalGameSessionCopyWithImpl<LocalGameSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalGameSession&&(identical(other.gameId, gameId) || other.gameId == gameId));
}


@override
int get hashCode => Object.hash(runtimeType,gameId);

@override
String toString() {
  return 'GameSession.local(gameId: $gameId)';
}


}

/// @nodoc
abstract mixin class $LocalGameSessionCopyWith<$Res> implements $GameSessionCopyWith<$Res> {
  factory $LocalGameSessionCopyWith(LocalGameSession value, $Res Function(LocalGameSession) _then) = _$LocalGameSessionCopyWithImpl;
@override @useResult
$Res call({
 GameId gameId
});




}
/// @nodoc
class _$LocalGameSessionCopyWithImpl<$Res>
    implements $LocalGameSessionCopyWith<$Res> {
  _$LocalGameSessionCopyWithImpl(this._self, this._then);

  final LocalGameSession _self;
  final $Res Function(LocalGameSession) _then;

/// Create a copy of GameSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gameId = null,}) {
  return _then(LocalGameSession(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as GameId,
  ));
}


}

/// @nodoc


class OnlineGameSession implements GameSession {
  const OnlineGameSession({required this.gameId, required this.me});
  

@override final  GameId gameId;
 final  PlayerId me;

/// Create a copy of GameSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnlineGameSessionCopyWith<OnlineGameSession> get copyWith => _$OnlineGameSessionCopyWithImpl<OnlineGameSession>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlineGameSession&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.me, me) || other.me == me));
}


@override
int get hashCode => Object.hash(runtimeType,gameId,me);

@override
String toString() {
  return 'GameSession.online(gameId: $gameId, me: $me)';
}


}

/// @nodoc
abstract mixin class $OnlineGameSessionCopyWith<$Res> implements $GameSessionCopyWith<$Res> {
  factory $OnlineGameSessionCopyWith(OnlineGameSession value, $Res Function(OnlineGameSession) _then) = _$OnlineGameSessionCopyWithImpl;
@override @useResult
$Res call({
 GameId gameId, PlayerId me
});




}
/// @nodoc
class _$OnlineGameSessionCopyWithImpl<$Res>
    implements $OnlineGameSessionCopyWith<$Res> {
  _$OnlineGameSessionCopyWithImpl(this._self, this._then);

  final OnlineGameSession _self;
  final $Res Function(OnlineGameSession) _then;

/// Create a copy of GameSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gameId = null,Object? me = null,}) {
  return _then(OnlineGameSession(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as GameId,me: null == me ? _self.me : me // ignore: cast_nullable_to_non_nullable
as PlayerId,
  ));
}


}

// dart format on
