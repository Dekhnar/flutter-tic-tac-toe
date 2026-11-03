// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_rules.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameChange {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameChange);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameChange()';
}


}

/// @nodoc
class $GameChangeCopyWith<$Res>  {
$GameChangeCopyWith(GameChange _, $Res Function(GameChange) __);
}


/// Adds pattern-matching-related methods to [GameChange].
extension GameChangePatterns on GameChange {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GameChanged value)?  changed,TResult Function( GameAlreadyDone value)?  alreadyDone,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GameChanged() when changed != null:
return changed(_that);case GameAlreadyDone() when alreadyDone != null:
return alreadyDone(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GameChanged value)  changed,required TResult Function( GameAlreadyDone value)  alreadyDone,}){
final _that = this;
switch (_that) {
case GameChanged():
return changed(_that);case GameAlreadyDone():
return alreadyDone(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GameChanged value)?  changed,TResult? Function( GameAlreadyDone value)?  alreadyDone,}){
final _that = this;
switch (_that) {
case GameChanged() when changed != null:
return changed(_that);case GameAlreadyDone() when alreadyDone != null:
return alreadyDone(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Game game)?  changed,TResult Function()?  alreadyDone,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GameChanged() when changed != null:
return changed(_that.game);case GameAlreadyDone() when alreadyDone != null:
return alreadyDone();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Game game)  changed,required TResult Function()  alreadyDone,}) {final _that = this;
switch (_that) {
case GameChanged():
return changed(_that.game);case GameAlreadyDone():
return alreadyDone();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Game game)?  changed,TResult? Function()?  alreadyDone,}) {final _that = this;
switch (_that) {
case GameChanged() when changed != null:
return changed(_that.game);case GameAlreadyDone() when alreadyDone != null:
return alreadyDone();case _:
  return null;

}
}

}

/// @nodoc


class GameChanged implements GameChange {
  const GameChanged(this.game);
  

 final  Game game;

/// Create a copy of GameChange
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameChangedCopyWith<GameChanged> get copyWith => _$GameChangedCopyWithImpl<GameChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameChanged&&(identical(other.game, game) || other.game == game));
}


@override
int get hashCode => Object.hash(runtimeType,game);

@override
String toString() {
  return 'GameChange.changed(game: $game)';
}


}

/// @nodoc
abstract mixin class $GameChangedCopyWith<$Res> implements $GameChangeCopyWith<$Res> {
  factory $GameChangedCopyWith(GameChanged value, $Res Function(GameChanged) _then) = _$GameChangedCopyWithImpl;
@useResult
$Res call({
 Game game
});


$GameCopyWith<$Res> get game;

}
/// @nodoc
class _$GameChangedCopyWithImpl<$Res>
    implements $GameChangedCopyWith<$Res> {
  _$GameChangedCopyWithImpl(this._self, this._then);

  final GameChanged _self;
  final $Res Function(GameChanged) _then;

/// Create a copy of GameChange
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? game = null,}) {
  return _then(GameChanged(
null == game ? _self.game : game // ignore: cast_nullable_to_non_nullable
as Game,
  ));
}

/// Create a copy of GameChange
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GameCopyWith<$Res> get game {
  
  return $GameCopyWith<$Res>(_self.game, (value) {
    return _then(_self.copyWith(game: value));
  });
}
}

/// @nodoc


class GameAlreadyDone implements GameChange {
  const GameAlreadyDone();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameAlreadyDone);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameChange.alreadyDone()';
}


}




// dart format on
