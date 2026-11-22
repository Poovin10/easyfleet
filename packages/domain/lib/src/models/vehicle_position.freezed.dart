// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_position.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehiclePosition {

 String get vehicleId; String get vehicleNumber; double get latitude; double get longitude; double? get heading; double? get speed; DateTime get updatedAt; String? get tripId;
/// Create a copy of VehiclePosition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehiclePositionCopyWith<VehiclePosition> get copyWith => _$VehiclePositionCopyWithImpl<VehiclePosition>(this as VehiclePosition, _$identity);

  /// Serializes this VehiclePosition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as VehiclePosition;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehiclePosition&&(identical(other.vehicleId, _this.vehicleId) || other.vehicleId == _this.vehicleId)&&(identical(other.vehicleNumber, _this.vehicleNumber) || other.vehicleNumber == _this.vehicleNumber)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.heading, _this.heading) || other.heading == _this.heading)&&(identical(other.speed, _this.speed) || other.speed == _this.speed)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.tripId, _this.tripId) || other.tripId == _this.tripId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as VehiclePosition;
  return Object.hash(runtimeType,_this.vehicleId,_this.vehicleNumber,_this.latitude,_this.longitude,_this.heading,_this.speed,_this.updatedAt,_this.tripId);
}

@override
String toString() {
  final _this = this as VehiclePosition;
  return 'VehiclePosition(vehicleId: ${_this.vehicleId}, vehicleNumber: ${_this.vehicleNumber}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, heading: ${_this.heading}, speed: ${_this.speed}, updatedAt: ${_this.updatedAt}, tripId: ${_this.tripId})';
}


}

/// @nodoc
abstract mixin class $VehiclePositionCopyWith<$Res>  {
  factory $VehiclePositionCopyWith(VehiclePosition value, $Res Function(VehiclePosition) _then) = _$VehiclePositionCopyWithImpl;
@useResult
$Res call({
 String vehicleId, String vehicleNumber, double latitude, double longitude, double? heading, double? speed, DateTime updatedAt, String? tripId
});




}
/// @nodoc
class _$VehiclePositionCopyWithImpl<$Res>
    implements $VehiclePositionCopyWith<$Res> {
  _$VehiclePositionCopyWithImpl(this._self, this._then);

  final VehiclePosition _self;
  final $Res Function(VehiclePosition) _then;

/// Create a copy of VehiclePosition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vehicleId = null,Object? vehicleNumber = null,Object? latitude = null,Object? longitude = null,Object? heading = freezed,Object? speed = freezed,Object? updatedAt = null,Object? tripId = freezed,}) {
  return _then(VehiclePosition(
vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VehiclePosition].
extension VehiclePositionPatterns on VehiclePosition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehiclePosition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehiclePosition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehiclePosition value)  $default,){
final _that = this;
switch (_that) {
case _VehiclePosition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehiclePosition value)?  $default,){
final _that = this;
switch (_that) {
case _VehiclePosition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String vehicleId,  String vehicleNumber,  double latitude,  double longitude,  double? heading,  double? speed,  DateTime updatedAt,  String? tripId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehiclePosition() when $default != null:
return $default(_that.vehicleId,_that.vehicleNumber,_that.latitude,_that.longitude,_that.heading,_that.speed,_that.updatedAt,_that.tripId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String vehicleId,  String vehicleNumber,  double latitude,  double longitude,  double? heading,  double? speed,  DateTime updatedAt,  String? tripId)  $default,) {final _that = this;
switch (_that) {
case _VehiclePosition():
return $default(_that.vehicleId,_that.vehicleNumber,_that.latitude,_that.longitude,_that.heading,_that.speed,_that.updatedAt,_that.tripId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String vehicleId,  String vehicleNumber,  double latitude,  double longitude,  double? heading,  double? speed,  DateTime updatedAt,  String? tripId)?  $default,) {final _that = this;
switch (_that) {
case _VehiclePosition() when $default != null:
return $default(_that.vehicleId,_that.vehicleNumber,_that.latitude,_that.longitude,_that.heading,_that.speed,_that.updatedAt,_that.tripId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehiclePosition implements VehiclePosition {
  const _VehiclePosition({required this.vehicleId, required this.vehicleNumber, required this.latitude, required this.longitude, this.heading, this.speed, required this.updatedAt, this.tripId});
  factory _VehiclePosition.fromJson(Map<String, dynamic> json) => _$VehiclePositionFromJson(json);

@override final  String vehicleId;
@override final  String vehicleNumber;
@override final  double latitude;
@override final  double longitude;
@override final  double? heading;
@override final  double? speed;
@override final  DateTime updatedAt;
@override final  String? tripId;

/// Create a copy of VehiclePosition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehiclePositionCopyWith<_VehiclePosition> get copyWith => __$VehiclePositionCopyWithImpl<_VehiclePosition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehiclePositionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehiclePosition&&(identical(other.vehicleId, vehicleId) || other.vehicleId == vehicleId)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.tripId, tripId) || other.tripId == tripId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,vehicleId,vehicleNumber,latitude,longitude,heading,speed,updatedAt,tripId);
}

@override
String toString() {
    return 'VehiclePosition(vehicleId: $vehicleId, vehicleNumber: $vehicleNumber, latitude: $latitude, longitude: $longitude, heading: $heading, speed: $speed, updatedAt: $updatedAt, tripId: $tripId)';
}


}

/// @nodoc
abstract mixin class _$VehiclePositionCopyWith<$Res> implements $VehiclePositionCopyWith<$Res> {
  factory _$VehiclePositionCopyWith(_VehiclePosition value, $Res Function(_VehiclePosition) _then) = __$VehiclePositionCopyWithImpl;
@override @useResult
$Res call({
 String vehicleId, String vehicleNumber, double latitude, double longitude, double? heading, double? speed, DateTime updatedAt, String? tripId
});




}
/// @nodoc
class __$VehiclePositionCopyWithImpl<$Res>
    implements _$VehiclePositionCopyWith<$Res> {
  __$VehiclePositionCopyWithImpl(this._self, this._then);

  final _VehiclePosition _self;
  final $Res Function(_VehiclePosition) _then;

/// Create a copy of VehiclePosition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vehicleId = null,Object? vehicleNumber = null,Object? latitude = null,Object? longitude = null,Object? heading = freezed,Object? speed = freezed,Object? updatedAt = null,Object? tripId = freezed,}) {
  return _then(_VehiclePosition(
vehicleId: null == vehicleId ? _self.vehicleId : vehicleId // ignore: cast_nullable_to_non_nullable
as String,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
