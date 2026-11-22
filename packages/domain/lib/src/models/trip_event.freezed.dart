// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TripEvent {

 String get id; String get tripId; TripStage get stage; DateTime get occurredAt; String? get actorId; String? get note; double? get latitude; double? get longitude;
/// Create a copy of TripEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripEventCopyWith<TripEvent> get copyWith => _$TripEventCopyWithImpl<TripEvent>(this as TripEvent, _$identity);

  /// Serializes this TripEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TripEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.tripId, _this.tripId) || other.tripId == _this.tripId)&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.actorId, _this.actorId) || other.actorId == _this.actorId)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TripEvent;
  return Object.hash(runtimeType,_this.id,_this.tripId,_this.stage,_this.occurredAt,_this.actorId,_this.note,_this.latitude,_this.longitude);
}

@override
String toString() {
  final _this = this as TripEvent;
  return 'TripEvent(id: ${_this.id}, tripId: ${_this.tripId}, stage: ${_this.stage}, occurredAt: ${_this.occurredAt}, actorId: ${_this.actorId}, note: ${_this.note}, latitude: ${_this.latitude}, longitude: ${_this.longitude})';
}


}

/// @nodoc
abstract mixin class $TripEventCopyWith<$Res>  {
  factory $TripEventCopyWith(TripEvent value, $Res Function(TripEvent) _then) = _$TripEventCopyWithImpl;
@useResult
$Res call({
 String id, String tripId, TripStage stage, DateTime occurredAt, String? actorId, String? note, double? latitude, double? longitude
});




}
/// @nodoc
class _$TripEventCopyWithImpl<$Res>
    implements $TripEventCopyWith<$Res> {
  _$TripEventCopyWithImpl(this._self, this._then);

  final TripEvent _self;
  final $Res Function(TripEvent) _then;

/// Create a copy of TripEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tripId = null,Object? stage = null,Object? occurredAt = null,Object? actorId = freezed,Object? note = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(TripEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as TripStage,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [TripEvent].
extension TripEventPatterns on TripEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripEvent() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripEvent value)  $default,){
final _that = this;
switch (_that) {
case _TripEvent():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripEvent value)?  $default,){
final _that = this;
switch (_that) {
case _TripEvent() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String tripId,  TripStage stage,  DateTime occurredAt,  String? actorId,  String? note,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripEvent() when $default != null:
return $default(_that.id,_that.tripId,_that.stage,_that.occurredAt,_that.actorId,_that.note,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String tripId,  TripStage stage,  DateTime occurredAt,  String? actorId,  String? note,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _TripEvent():
return $default(_that.id,_that.tripId,_that.stage,_that.occurredAt,_that.actorId,_that.note,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String tripId,  TripStage stage,  DateTime occurredAt,  String? actorId,  String? note,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _TripEvent() when $default != null:
return $default(_that.id,_that.tripId,_that.stage,_that.occurredAt,_that.actorId,_that.note,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TripEvent implements TripEvent {
  const _TripEvent({required this.id, required this.tripId, required this.stage, required this.occurredAt, this.actorId, this.note, this.latitude, this.longitude});
  factory _TripEvent.fromJson(Map<String, dynamic> json) => _$TripEventFromJson(json);

@override final  String id;
@override final  String tripId;
@override final  TripStage stage;
@override final  DateTime occurredAt;
@override final  String? actorId;
@override final  String? note;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of TripEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripEventCopyWith<_TripEvent> get copyWith => __$TripEventCopyWithImpl<_TripEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripEventToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.note, note) || other.note == note)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,tripId,stage,occurredAt,actorId,note,latitude,longitude);
}

@override
String toString() {
    return 'TripEvent(id: $id, tripId: $tripId, stage: $stage, occurredAt: $occurredAt, actorId: $actorId, note: $note, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$TripEventCopyWith<$Res> implements $TripEventCopyWith<$Res> {
  factory _$TripEventCopyWith(_TripEvent value, $Res Function(_TripEvent) _then) = __$TripEventCopyWithImpl;
@override @useResult
$Res call({
 String id, String tripId, TripStage stage, DateTime occurredAt, String? actorId, String? note, double? latitude, double? longitude
});




}
/// @nodoc
class __$TripEventCopyWithImpl<$Res>
    implements _$TripEventCopyWith<$Res> {
  __$TripEventCopyWithImpl(this._self, this._then);

  final _TripEvent _self;
  final $Res Function(_TripEvent) _then;

/// Create a copy of TripEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tripId = null,Object? stage = null,Object? occurredAt = null,Object? actorId = freezed,Object? note = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_TripEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as TripStage,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
