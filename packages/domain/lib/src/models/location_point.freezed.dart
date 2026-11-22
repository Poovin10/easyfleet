// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationPoint {

 double get latitude; double get longitude; double? get accuracy; double? get altitude; double? get speed; double? get heading; DateTime get capturedAt; String? get photoPath;
/// Create a copy of LocationPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationPointCopyWith<LocationPoint> get copyWith => _$LocationPointCopyWithImpl<LocationPoint>(this as LocationPoint, _$identity);

  /// Serializes this LocationPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LocationPoint;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationPoint&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.accuracy, _this.accuracy) || other.accuracy == _this.accuracy)&&(identical(other.altitude, _this.altitude) || other.altitude == _this.altitude)&&(identical(other.speed, _this.speed) || other.speed == _this.speed)&&(identical(other.heading, _this.heading) || other.heading == _this.heading)&&(identical(other.capturedAt, _this.capturedAt) || other.capturedAt == _this.capturedAt)&&(identical(other.photoPath, _this.photoPath) || other.photoPath == _this.photoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LocationPoint;
  return Object.hash(runtimeType,_this.latitude,_this.longitude,_this.accuracy,_this.altitude,_this.speed,_this.heading,_this.capturedAt,_this.photoPath);
}

@override
String toString() {
  final _this = this as LocationPoint;
  return 'LocationPoint(latitude: ${_this.latitude}, longitude: ${_this.longitude}, accuracy: ${_this.accuracy}, altitude: ${_this.altitude}, speed: ${_this.speed}, heading: ${_this.heading}, capturedAt: ${_this.capturedAt}, photoPath: ${_this.photoPath})';
}


}

/// @nodoc
abstract mixin class $LocationPointCopyWith<$Res>  {
  factory $LocationPointCopyWith(LocationPoint value, $Res Function(LocationPoint) _then) = _$LocationPointCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double? accuracy, double? altitude, double? speed, double? heading, DateTime capturedAt, String? photoPath
});




}
/// @nodoc
class _$LocationPointCopyWithImpl<$Res>
    implements $LocationPointCopyWith<$Res> {
  _$LocationPointCopyWithImpl(this._self, this._then);

  final LocationPoint _self;
  final $Res Function(LocationPoint) _then;

/// Create a copy of LocationPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = freezed,Object? altitude = freezed,Object? speed = freezed,Object? heading = freezed,Object? capturedAt = null,Object? photoPath = freezed,}) {
  return _then(LocationPoint(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double?,altitude: freezed == altitude ? _self.altitude : altitude // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationPoint].
extension LocationPointPatterns on LocationPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationPoint value)  $default,){
final _that = this;
switch (_that) {
case _LocationPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationPoint value)?  $default,){
final _that = this;
switch (_that) {
case _LocationPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? accuracy,  double? altitude,  double? speed,  double? heading,  DateTime capturedAt,  String? photoPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationPoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.altitude,_that.speed,_that.heading,_that.capturedAt,_that.photoPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? accuracy,  double? altitude,  double? speed,  double? heading,  DateTime capturedAt,  String? photoPath)  $default,) {final _that = this;
switch (_that) {
case _LocationPoint():
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.altitude,_that.speed,_that.heading,_that.capturedAt,_that.photoPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double? accuracy,  double? altitude,  double? speed,  double? heading,  DateTime capturedAt,  String? photoPath)?  $default,) {final _that = this;
switch (_that) {
case _LocationPoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.altitude,_that.speed,_that.heading,_that.capturedAt,_that.photoPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationPoint implements LocationPoint {
  const _LocationPoint({required this.latitude, required this.longitude, this.accuracy, this.altitude, this.speed, this.heading, required this.capturedAt, this.photoPath});
  factory _LocationPoint.fromJson(Map<String, dynamic> json) => _$LocationPointFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  double? accuracy;
@override final  double? altitude;
@override final  double? speed;
@override final  double? heading;
@override final  DateTime capturedAt;
@override final  String? photoPath;

/// Create a copy of LocationPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationPointCopyWith<_LocationPoint> get copyWith => __$LocationPointCopyWithImpl<_LocationPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationPointToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationPoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.altitude, altitude) || other.altitude == altitude)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,latitude,longitude,accuracy,altitude,speed,heading,capturedAt,photoPath);
}

@override
String toString() {
    return 'LocationPoint(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, altitude: $altitude, speed: $speed, heading: $heading, capturedAt: $capturedAt, photoPath: $photoPath)';
}


}

/// @nodoc
abstract mixin class _$LocationPointCopyWith<$Res> implements $LocationPointCopyWith<$Res> {
  factory _$LocationPointCopyWith(_LocationPoint value, $Res Function(_LocationPoint) _then) = __$LocationPointCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double? accuracy, double? altitude, double? speed, double? heading, DateTime capturedAt, String? photoPath
});




}
/// @nodoc
class __$LocationPointCopyWithImpl<$Res>
    implements _$LocationPointCopyWith<$Res> {
  __$LocationPointCopyWithImpl(this._self, this._then);

  final _LocationPoint _self;
  final $Res Function(_LocationPoint) _then;

/// Create a copy of LocationPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = freezed,Object? altitude = freezed,Object? speed = freezed,Object? heading = freezed,Object? capturedAt = null,Object? photoPath = freezed,}) {
  return _then(_LocationPoint(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double?,altitude: freezed == altitude ? _self.altitude : altitude // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
