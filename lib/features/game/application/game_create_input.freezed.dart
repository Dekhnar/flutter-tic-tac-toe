// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_create_input.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameCreateInput {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameCreateInput);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameCreateInput()';
}


}

/// @nodoc
class $GameCreateInputCopyWith<$Res>  {
$GameCreateInputCopyWith(GameCreateInput _, $Res Function(GameCreateInput) __);
}


/// Adds pattern-matching-related methods to [GameCreateInput].
extension GameCreateInputPatterns on GameCreateInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LocalGameInput value)?  local,TResult Function( LocalVsAiGameInput value)?  localVsAi,TResult Function( CreateOnlineGameInput value)?  createOnline,TResult Function( JoinOnlineGameInput value)?  joinOnline,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LocalGameInput() when local != null:
return local(_that);case LocalVsAiGameInput() when localVsAi != null:
return localVsAi(_that);case CreateOnlineGameInput() when createOnline != null:
return createOnline(_that);case JoinOnlineGameInput() when joinOnline != null:
return joinOnline(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LocalGameInput value)  local,required TResult Function( LocalVsAiGameInput value)  localVsAi,required TResult Function( CreateOnlineGameInput value)  createOnline,required TResult Function( JoinOnlineGameInput value)  joinOnline,}){
final _that = this;
switch (_that) {
case LocalGameInput():
return local(_that);case LocalVsAiGameInput():
return localVsAi(_that);case CreateOnlineGameInput():
return createOnline(_that);case JoinOnlineGameInput():
return joinOnline(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LocalGameInput value)?  local,TResult? Function( LocalVsAiGameInput value)?  localVsAi,TResult? Function( CreateOnlineGameInput value)?  createOnline,TResult? Function( JoinOnlineGameInput value)?  joinOnline,}){
final _that = this;
switch (_that) {
case LocalGameInput() when local != null:
return local(_that);case LocalVsAiGameInput() when localVsAi != null:
return localVsAi(_that);case CreateOnlineGameInput() when createOnline != null:
return createOnline(_that);case JoinOnlineGameInput() when joinOnline != null:
return joinOnline(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String guestName,  String hostName)?  local,TResult Function( String hostName)?  localVsAi,TResult Function( String hostName)?  createOnline,TResult Function( GameCode code,  String guestName)?  joinOnline,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LocalGameInput() when local != null:
return local(_that.guestName,_that.hostName);case LocalVsAiGameInput() when localVsAi != null:
return localVsAi(_that.hostName);case CreateOnlineGameInput() when createOnline != null:
return createOnline(_that.hostName);case JoinOnlineGameInput() when joinOnline != null:
return joinOnline(_that.code,_that.guestName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String guestName,  String hostName)  local,required TResult Function( String hostName)  localVsAi,required TResult Function( String hostName)  createOnline,required TResult Function( GameCode code,  String guestName)  joinOnline,}) {final _that = this;
switch (_that) {
case LocalGameInput():
return local(_that.guestName,_that.hostName);case LocalVsAiGameInput():
return localVsAi(_that.hostName);case CreateOnlineGameInput():
return createOnline(_that.hostName);case JoinOnlineGameInput():
return joinOnline(_that.code,_that.guestName);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String guestName,  String hostName)?  local,TResult? Function( String hostName)?  localVsAi,TResult? Function( String hostName)?  createOnline,TResult? Function( GameCode code,  String guestName)?  joinOnline,}) {final _that = this;
switch (_that) {
case LocalGameInput() when local != null:
return local(_that.guestName,_that.hostName);case LocalVsAiGameInput() when localVsAi != null:
return localVsAi(_that.hostName);case CreateOnlineGameInput() when createOnline != null:
return createOnline(_that.hostName);case JoinOnlineGameInput() when joinOnline != null:
return joinOnline(_that.code,_that.guestName);case _:
  return null;

}
}

}

/// @nodoc


class LocalGameInput implements GameCreateInput {
  const LocalGameInput({required this.guestName, required this.hostName});
  

 final  String guestName;
 final  String hostName;

/// Create a copy of GameCreateInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalGameInputCopyWith<LocalGameInput> get copyWith => _$LocalGameInputCopyWithImpl<LocalGameInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalGameInput&&(identical(other.guestName, guestName) || other.guestName == guestName)&&(identical(other.hostName, hostName) || other.hostName == hostName));
}


@override
int get hashCode => Object.hash(runtimeType,guestName,hostName);

@override
String toString() {
  return 'GameCreateInput.local(guestName: $guestName, hostName: $hostName)';
}


}

/// @nodoc
abstract mixin class $LocalGameInputCopyWith<$Res> implements $GameCreateInputCopyWith<$Res> {
  factory $LocalGameInputCopyWith(LocalGameInput value, $Res Function(LocalGameInput) _then) = _$LocalGameInputCopyWithImpl;
@useResult
$Res call({
 String guestName, String hostName
});




}
/// @nodoc
class _$LocalGameInputCopyWithImpl<$Res>
    implements $LocalGameInputCopyWith<$Res> {
  _$LocalGameInputCopyWithImpl(this._self, this._then);

  final LocalGameInput _self;
  final $Res Function(LocalGameInput) _then;

/// Create a copy of GameCreateInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? guestName = null,Object? hostName = null,}) {
  return _then(LocalGameInput(
guestName: null == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LocalVsAiGameInput implements GameCreateInput {
  const LocalVsAiGameInput({required this.hostName});
  

 final  String hostName;

/// Create a copy of GameCreateInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalVsAiGameInputCopyWith<LocalVsAiGameInput> get copyWith => _$LocalVsAiGameInputCopyWithImpl<LocalVsAiGameInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalVsAiGameInput&&(identical(other.hostName, hostName) || other.hostName == hostName));
}


@override
int get hashCode => Object.hash(runtimeType,hostName);

@override
String toString() {
  return 'GameCreateInput.localVsAi(hostName: $hostName)';
}


}

/// @nodoc
abstract mixin class $LocalVsAiGameInputCopyWith<$Res> implements $GameCreateInputCopyWith<$Res> {
  factory $LocalVsAiGameInputCopyWith(LocalVsAiGameInput value, $Res Function(LocalVsAiGameInput) _then) = _$LocalVsAiGameInputCopyWithImpl;
@useResult
$Res call({
 String hostName
});




}
/// @nodoc
class _$LocalVsAiGameInputCopyWithImpl<$Res>
    implements $LocalVsAiGameInputCopyWith<$Res> {
  _$LocalVsAiGameInputCopyWithImpl(this._self, this._then);

  final LocalVsAiGameInput _self;
  final $Res Function(LocalVsAiGameInput) _then;

/// Create a copy of GameCreateInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hostName = null,}) {
  return _then(LocalVsAiGameInput(
hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CreateOnlineGameInput implements GameCreateInput {
  const CreateOnlineGameInput({required this.hostName});
  

 final  String hostName;

/// Create a copy of GameCreateInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateOnlineGameInputCopyWith<CreateOnlineGameInput> get copyWith => _$CreateOnlineGameInputCopyWithImpl<CreateOnlineGameInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateOnlineGameInput&&(identical(other.hostName, hostName) || other.hostName == hostName));
}


@override
int get hashCode => Object.hash(runtimeType,hostName);

@override
String toString() {
  return 'GameCreateInput.createOnline(hostName: $hostName)';
}


}

/// @nodoc
abstract mixin class $CreateOnlineGameInputCopyWith<$Res> implements $GameCreateInputCopyWith<$Res> {
  factory $CreateOnlineGameInputCopyWith(CreateOnlineGameInput value, $Res Function(CreateOnlineGameInput) _then) = _$CreateOnlineGameInputCopyWithImpl;
@useResult
$Res call({
 String hostName
});




}
/// @nodoc
class _$CreateOnlineGameInputCopyWithImpl<$Res>
    implements $CreateOnlineGameInputCopyWith<$Res> {
  _$CreateOnlineGameInputCopyWithImpl(this._self, this._then);

  final CreateOnlineGameInput _self;
  final $Res Function(CreateOnlineGameInput) _then;

/// Create a copy of GameCreateInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hostName = null,}) {
  return _then(CreateOnlineGameInput(
hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class JoinOnlineGameInput implements GameCreateInput {
  const JoinOnlineGameInput({required this.code, required this.guestName});
  

 final  GameCode code;
 final  String guestName;

/// Create a copy of GameCreateInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinOnlineGameInputCopyWith<JoinOnlineGameInput> get copyWith => _$JoinOnlineGameInputCopyWithImpl<JoinOnlineGameInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinOnlineGameInput&&(identical(other.code, code) || other.code == code)&&(identical(other.guestName, guestName) || other.guestName == guestName));
}


@override
int get hashCode => Object.hash(runtimeType,code,guestName);

@override
String toString() {
  return 'GameCreateInput.joinOnline(code: $code, guestName: $guestName)';
}


}

/// @nodoc
abstract mixin class $JoinOnlineGameInputCopyWith<$Res> implements $GameCreateInputCopyWith<$Res> {
  factory $JoinOnlineGameInputCopyWith(JoinOnlineGameInput value, $Res Function(JoinOnlineGameInput) _then) = _$JoinOnlineGameInputCopyWithImpl;
@useResult
$Res call({
 GameCode code, String guestName
});




}
/// @nodoc
class _$JoinOnlineGameInputCopyWithImpl<$Res>
    implements $JoinOnlineGameInputCopyWith<$Res> {
  _$JoinOnlineGameInputCopyWithImpl(this._self, this._then);

  final JoinOnlineGameInput _self;
  final $Res Function(JoinOnlineGameInput) _then;

/// Create a copy of GameCreateInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,Object? guestName = null,}) {
  return _then(JoinOnlineGameInput(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as GameCode,guestName: null == guestName ? _self.guestName : guestName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
