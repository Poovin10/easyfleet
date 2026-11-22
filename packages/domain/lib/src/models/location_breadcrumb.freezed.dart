// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_breadcrumb.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationBreadcrumb {

 String get idempotencyKey; String get tripId; double get latitude; double get longitude; double? get accuracy; DateTime get recordedAt; String get syncState;
/// Create a copy of LocationBreadcrumb
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationBreadcrumbCopyWith<LocationBreadcrumb> get copyWith => _$LocationBreadcrumbCopyWithImpl<LocationBreadcrumb>(this as LocationBreadcrumb, _$identity);

  /// Serializes this LocationBreadcrumb to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LocationBreadcrumb;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationBreadcrumb&&(identical(other.idempotencyKey, _this.idempotencyKey) || other.idempotencyKey == _this.idempotencyKey)&&(identical(other.tripId, _this.tripId) || other.tripId == _this.tripId)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.accuracy, _this.accuracy) || other.accuracy == _this.accuracy)&&(identical(other.recordedAt, _this.recordedAt) || other.recordedAt == _this.recordedAt)&&(identical(other.syncState, _this.syncState) || other.syncState == _this.syncState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LocationBreadcrumb;
  return Object.hash(runtimeType,_this.idempotencyKey,_this.tripId,_this.latitude,_this.longitude,_this.accuracy,_this.recordedAt,_this.syncState);
}

@override
String toString() {
  final _this = this as LocationBreadcrumb;
  return 'LocationBreadcrumb(idempotencyKey: ${_this.idempotencyKey}, tripId: ${_this.tripId}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, accuracy: ${_this.accuracy}, recordedAt: ${_this.recordedAt}, syncState: ${_this.syncState})';
}


}

/// @nodoc
abstract mixin class $LocationBreadcrumbCopyWith<$Res>  {
  factory $LocationBreadcrumbCopyWith(LocationBreadcrumb value, $Res Function(LocationBreadcrumb) _then) = _$LocationBreadcrumbCopyWithImpl;
@useResult
$Res call({
 String idempotencyKey, String tripId, double latitude, double longitude, double? accuracy, DateTime recordedAt, String syncState
});




}
/// @nodoc
class _$LocationBreadcrumbCopyWithImpl<$Res>
    implements $LocationBreadcrumbCopyWith<$Res> {
  _$LocationBreadcrumbCopyWithImpl(this._self, this._then);

  final LocationBreadcrumb _self;
  final $Res Function(LocationBreadcrumb) _then;

/// Create a copy of LocationBreadcrumb
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idempotencyKey = null,Object? tripId = null,Object? latitude = null,Object? longitude = null,Object? accuracy = freezed,Object? recordedAt = null,Object? syncState = null,}) {
  return _then(LocationBreadcrumb(
idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double?,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationBreadcrumb].
extension LocationBreadcrumbPatterns on LocationBreadcrumb {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationBreadcrumb value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationBreadcrumb() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationBreadcrumb value)  $default,){
final _that = this;
switch (_that) {
case _LocationBreadcrumb():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationBreadcrumb value)?  $default,){
final _that = this;
switch (_that) {
case _LocationBreadcrumb() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String idempotencyKey,  String tripId,  double latitude,  double longitude,  double? accuracy,  DateTime recordedAt,  String syncState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationBreadcrumb() when $default != null:
return $default(_that.idempotencyKey,_that.tripId,_that.latitude,_that.longitude,_that.accuracy,_that.recordedAt,_that.syncState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String idempotencyKey,  String tripId,  double latitude,  double longitude,  double? accuracy,  DateTime recordedAt,  String syncState)  $default,) {final _that = this;
switch (_that) {
case _LocationBreadcrumb():
return $default(_that.idempotencyKey,_that.tripId,_that.latitude,_that.longitude,_that.accuracy,_that.recordedAt,_that.syncState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String idempotencyKey,  String tripId,  double latitude,  double longitude,  double? accuracy,  DateTime recordedAt,  String syncState)?  $default,) {final _that = this;
switch (_that) {
case _LocationBreadcrumb() when $default != null:
return $default(_that.idempotencyKey,_that.tripId,_that.latitude,_that.longitude,_that.accuracy,_that.recordedAt,_that.syncState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationBreadcrumb implements LocationBreadcrumb {
  const _LocationBreadcrumb({required this.idempotencyKey, required this.tripId, required this.latitude, required this.longitude, this.accuracy, required this.recordedAt, this.syncState = 'PENDING'});
  factory _LocationBreadcrumb.fromJson(Map<String, dynamic> json) => _$LocationBreadcrumbFromJson(json);

@override final  String idempotencyKey;
@override final  String tripId;
@override final  double latitude;
@override final  double longitude;
@override final  double? accuracy;
@override final  DateTime recordedAt;
@override@JsonKey() final  String syncState;

/// Create a copy of LocationBreadcrumb
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationBreadcrumbCopyWith<_LocationBreadcrumb> get copyWith => __$LocationBreadcrumbCopyWithImpl<_LocationBreadcrumb>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationBreadcrumbToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationBreadcrumb&&(identical(other.idempotencyKey, idempotencyKey) || other.idempotencyKey == idempotencyKey)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.recordedAt, recordedAt) || other.recordedAt == recordedAt)&&(identical(other.syncState, syncState) || other.syncState == syncState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,idempotencyKey,tripId,latitude,longitude,accuracy,recordedAt,syncState);
}

@override
String toString() {
    return 'LocationBreadcrumb(idempotencyKey: $idempotencyKey, tripId: $tripId, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, recordedAt: $recordedAt, syncState: $syncState)';
}


}

/// @nodoc
abstract mixin class _$LocationBreadcrumbCopyWith<$Res> implements $LocationBreadcrumbCopyWith<$Res> {
  factory _$LocationBreadcrumbCopyWith(_LocationBreadcrumb value, $Res Function(_LocationBreadcrumb) _then) = __$LocationBreadcrumbCopyWithImpl;
@override @useResult
$Res call({
 String idempotencyKey, String tripId, double latitude, double longitude, double? accuracy, DateTime recordedAt, String syncState
});




}
/// @nodoc
class __$LocationBreadcrumbCopyWithImpl<$Res>
    implements _$LocationBreadcrumbCopyWith<$Res> {
  __$LocationBreadcrumbCopyWithImpl(this._self, this._then);

  final _LocationBreadcrumb _self;
  final $Res Function(_LocationBreadcrumb) _then;

/// Create a copy of LocationBreadcrumb
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idempotencyKey = null,Object? tripId = null,Object? latitude = null,Object? longitude = null,Object? accuracy = freezed,Object? recordedAt = null,Object? syncState = null,}) {
  return _then(_LocationBreadcrumb(
idempotencyKey: null == idempotencyKey ? _self.idempotencyKey : idempotencyKey // ignore: cast_nullable_to_non_nullable
as String,tripId: null == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double?,recordedAt: null == recordedAt ? _self.recordedAt : recordedAt // ignore: cast_nullable_to_non_nullable
as DateTime,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
