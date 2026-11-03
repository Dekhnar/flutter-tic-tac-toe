// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'online_play.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnlinePlay {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlinePlay);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'OnlinePlay()';
}


}

/// @nodoc
class $OnlinePlayCopyWith<$Res>  {
$OnlinePlayCopyWith(OnlinePlay _, $Res Function(OnlinePlay) __);
}


/// Adds pattern-matching-related methods to [OnlinePlay].
extension OnlinePlayPatterns on OnlinePlay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( OnlinePlayAvailable value)?  available,TResult Function( OnlinePlayUnavailable value)?  unavailable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case OnlinePlayAvailable() when available != null:
return available(_that);case OnlinePlayUnavailable() when unavailable != null:
return unavailable(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( OnlinePlayAvailable value)  available,required TResult Function( OnlinePlayUnavailable value)  unavailable,}){
final _that = this;
switch (_that) {
case OnlinePlayAvailable():
return available(_that);case OnlinePlayUnavailable():
return unavailable(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( OnlinePlayAvailable value)?  available,TResult? Function( OnlinePlayUnavailable value)?  unavailable,}){
final _that = this;
switch (_that) {
case OnlinePlayAvailable() when available != null:
return available(_that);case OnlinePlayUnavailable() when unavailable != null:
return unavailable(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( PlayerIdentity identity,  OnlineGameRepository repository)?  available,TResult Function( OnlineUnavailableReason reason)?  unavailable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case OnlinePlayAvailable() when available != null:
return available(_that.identity,_that.repository);case OnlinePlayUnavailable() when unavailable != null:
return unavailable(_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( PlayerIdentity identity,  OnlineGameRepository repository)  available,required TResult Function( OnlineUnavailableReason reason)  unavailable,}) {final _that = this;
switch (_that) {
case OnlinePlayAvailable():
return available(_that.identity,_that.repository);case OnlinePlayUnavailable():
return unavailable(_that.reason);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( PlayerIdentity identity,  OnlineGameRepository repository)?  available,TResult? Function( OnlineUnavailableReason reason)?  unavailable,}) {final _that = this;
switch (_that) {
case OnlinePlayAvailable() when available != null:
return available(_that.identity,_that.repository);case OnlinePlayUnavailable() when unavailable != null:
return unavailable(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class OnlinePlayAvailable implements OnlinePlay {
  const OnlinePlayAvailable({required this.identity, required this.repository});
  

 final  PlayerIdentity identity;
 final  OnlineGameRepository repository;

/// Create a copy of OnlinePlay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnlinePlayAvailableCopyWith<OnlinePlayAvailable> get copyWith => _$OnlinePlayAvailableCopyWithImpl<OnlinePlayAvailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlinePlayAvailable&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.repository, repository) || other.repository == repository));
}


@override
int get hashCode => Object.hash(runtimeType,identity,repository);

@override
String toString() {
  return 'OnlinePlay.available(identity: $identity, repository: $repository)';
}


}

/// @nodoc
abstract mixin class $OnlinePlayAvailableCopyWith<$Res> implements $OnlinePlayCopyWith<$Res> {
  factory $OnlinePlayAvailableCopyWith(OnlinePlayAvailable value, $Res Function(OnlinePlayAvailable) _then) = _$OnlinePlayAvailableCopyWithImpl;
@useResult
$Res call({
 PlayerIdentity identity, OnlineGameRepository repository
});




}
/// @nodoc
class _$OnlinePlayAvailableCopyWithImpl<$Res>
    implements $OnlinePlayAvailableCopyWith<$Res> {
  _$OnlinePlayAvailableCopyWithImpl(this._self, this._then);

  final OnlinePlayAvailable _self;
  final $Res Function(OnlinePlayAvailable) _then;

/// Create a copy of OnlinePlay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? identity = null,Object? repository = null,}) {
  return _then(OnlinePlayAvailable(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as PlayerIdentity,repository: null == repository ? _self.repository : repository // ignore: cast_nullable_to_non_nullable
as OnlineGameRepository,
  ));
}


}

/// @nodoc


class OnlinePlayUnavailable implements OnlinePlay {
  const OnlinePlayUnavailable(this.reason);
  

 final  OnlineUnavailableReason reason;

/// Create a copy of OnlinePlay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnlinePlayUnavailableCopyWith<OnlinePlayUnavailable> get copyWith => _$OnlinePlayUnavailableCopyWithImpl<OnlinePlayUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnlinePlayUnavailable&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'OnlinePlay.unavailable(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $OnlinePlayUnavailableCopyWith<$Res> implements $OnlinePlayCopyWith<$Res> {
  factory $OnlinePlayUnavailableCopyWith(OnlinePlayUnavailable value, $Res Function(OnlinePlayUnavailable) _then) = _$OnlinePlayUnavailableCopyWithImpl;
@useResult
$Res call({
 OnlineUnavailableReason reason
});




}
/// @nodoc
class _$OnlinePlayUnavailableCopyWithImpl<$Res>
    implements $OnlinePlayUnavailableCopyWith<$Res> {
  _$OnlinePlayUnavailableCopyWithImpl(this._self, this._then);

  final OnlinePlayUnavailable _self;
  final $Res Function(OnlinePlayUnavailable) _then;

/// Create a copy of OnlinePlay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(OnlinePlayUnavailable(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as OnlineUnavailableReason,
  ));
}


}

// dart format on
