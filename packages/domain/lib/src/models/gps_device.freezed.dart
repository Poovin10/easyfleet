// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gps_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GpsDevice {

 String get id;/// Tracker IMEI, globally unique.
 String get imei; String get transporterId; GpsDeviceStatus get status; String? get vehicleNumber; String? get simNumber; DateTime? get lastSeenAt; double? get lastLatitude; double? get lastLongitude;
/// Create a copy of GpsDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GpsDeviceCopyWith<GpsDevice> get copyWith => _$GpsDeviceCopyWithImpl<GpsDevice>(this as GpsDevice, _$identity);

  /// Serializes this GpsDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GpsDevice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GpsDevice&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.imei, _this.imei) || other.imei == _this.imei)&&(identical(other.transporterId, _this.transporterId) || other.transporterId == _this.transporterId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.vehicleNumber, _this.vehicleNumber) || other.vehicleNumber == _this.vehicleNumber)&&(identical(other.simNumber, _this.simNumber) || other.simNumber == _this.simNumber)&&(identical(other.lastSeenAt, _this.lastSeenAt) || other.lastSeenAt == _this.lastSeenAt)&&(identical(other.lastLatitude, _this.lastLatitude) || other.lastLatitude == _this.lastLatitude)&&(identical(other.lastLongitude, _this.lastLongitude) || other.lastLongitude == _this.lastLongitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GpsDevice;
  return Object.hash(runtimeType,_this.id,_this.imei,_this.transporterId,_this.status,_this.vehicleNumber,_this.simNumber,_this.lastSeenAt,_this.lastLatitude,_this.lastLongitude);
}

@override
String toString() {
  final _this = this as GpsDevice;
  return 'GpsDevice(id: ${_this.id}, imei: ${_this.imei}, transporterId: ${_this.transporterId}, status: ${_this.status}, vehicleNumber: ${_this.vehicleNumber}, simNumber: ${_this.simNumber}, lastSeenAt: ${_this.lastSeenAt}, lastLatitude: ${_this.lastLatitude}, lastLongitude: ${_this.lastLongitude})';
}


}

/// @nodoc
abstract mixin class $GpsDeviceCopyWith<$Res>  {
  factory $GpsDeviceCopyWith(GpsDevice value, $Res Function(GpsDevice) _then) = _$GpsDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String imei, String transporterId, GpsDeviceStatus status, String? vehicleNumber, String? simNumber, DateTime? lastSeenAt, double? lastLatitude, double? lastLongitude
});




}
/// @nodoc
class _$GpsDeviceCopyWithImpl<$Res>
    implements $GpsDeviceCopyWith<$Res> {
  _$GpsDeviceCopyWithImpl(this._self, this._then);

  final GpsDevice _self;
  final $Res Function(GpsDevice) _then;

/// Create a copy of GpsDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? imei = null,Object? transporterId = null,Object? status = null,Object? vehicleNumber = freezed,Object? simNumber = freezed,Object? lastSeenAt = freezed,Object? lastLatitude = freezed,Object? lastLongitude = freezed,}) {
  return _then(GpsDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imei: null == imei ? _self.imei : imei // ignore: cast_nullable_to_non_nullable
as String,transporterId: null == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GpsDeviceStatus,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,simNumber: freezed == simNumber ? _self.simNumber : simNumber // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLatitude: freezed == lastLatitude ? _self.lastLatitude : lastLatitude // ignore: cast_nullable_to_non_nullable
as double?,lastLongitude: freezed == lastLongitude ? _self.lastLongitude : lastLongitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [GpsDevice].
extension GpsDevicePatterns on GpsDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GpsDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GpsDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GpsDevice value)  $default,){
final _that = this;
switch (_that) {
case _GpsDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GpsDevice value)?  $default,){
final _that = this;
switch (_that) {
case _GpsDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String imei,  String transporterId,  GpsDeviceStatus status,  String? vehicleNumber,  String? simNumber,  DateTime? lastSeenAt,  double? lastLatitude,  double? lastLongitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GpsDevice() when $default != null:
return $default(_that.id,_that.imei,_that.transporterId,_that.status,_that.vehicleNumber,_that.simNumber,_that.lastSeenAt,_that.lastLatitude,_that.lastLongitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String imei,  String transporterId,  GpsDeviceStatus status,  String? vehicleNumber,  String? simNumber,  DateTime? lastSeenAt,  double? lastLatitude,  double? lastLongitude)  $default,) {final _that = this;
switch (_that) {
case _GpsDevice():
return $default(_that.id,_that.imei,_that.transporterId,_that.status,_that.vehicleNumber,_that.simNumber,_that.lastSeenAt,_that.lastLatitude,_that.lastLongitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String imei,  String transporterId,  GpsDeviceStatus status,  String? vehicleNumber,  String? simNumber,  DateTime? lastSeenAt,  double? lastLatitude,  double? lastLongitude)?  $default,) {final _that = this;
switch (_that) {
case _GpsDevice() when $default != null:
return $default(_that.id,_that.imei,_that.transporterId,_that.status,_that.vehicleNumber,_that.simNumber,_that.lastSeenAt,_that.lastLatitude,_that.lastLongitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GpsDevice implements GpsDevice {
  const _GpsDevice({required this.id, required this.imei, required this.transporterId, required this.status, this.vehicleNumber, this.simNumber, this.lastSeenAt, this.lastLatitude, this.lastLongitude});
  factory _GpsDevice.fromJson(Map<String, dynamic> json) => _$GpsDeviceFromJson(json);

@override final  String id;
/// Tracker IMEI, globally unique.
@override final  String imei;
@override final  String transporterId;
@override final  GpsDeviceStatus status;
@override final  String? vehicleNumber;
@override final  String? simNumber;
@override final  DateTime? lastSeenAt;
@override final  double? lastLatitude;
@override final  double? lastLongitude;

/// Create a copy of GpsDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GpsDeviceCopyWith<_GpsDevice> get copyWith => __$GpsDeviceCopyWithImpl<_GpsDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GpsDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GpsDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.imei, imei) || other.imei == imei)&&(identical(other.transporterId, transporterId) || other.transporterId == transporterId)&&(identical(other.status, status) || other.status == status)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.simNumber, simNumber) || other.simNumber == simNumber)&&(identical(other.lastSeenAt, lastSeenAt) || other.lastSeenAt == lastSeenAt)&&(identical(other.lastLatitude, lastLatitude) || other.lastLatitude == lastLatitude)&&(identical(other.lastLongitude, lastLongitude) || other.lastLongitude == lastLongitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,imei,transporterId,status,vehicleNumber,simNumber,lastSeenAt,lastLatitude,lastLongitude);
}

@override
String toString() {
    return 'GpsDevice(id: $id, imei: $imei, transporterId: $transporterId, status: $status, vehicleNumber: $vehicleNumber, simNumber: $simNumber, lastSeenAt: $lastSeenAt, lastLatitude: $lastLatitude, lastLongitude: $lastLongitude)';
}


}

/// @nodoc
abstract mixin class _$GpsDeviceCopyWith<$Res> implements $GpsDeviceCopyWith<$Res> {
  factory _$GpsDeviceCopyWith(_GpsDevice value, $Res Function(_GpsDevice) _then) = __$GpsDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String imei, String transporterId, GpsDeviceStatus status, String? vehicleNumber, String? simNumber, DateTime? lastSeenAt, double? lastLatitude, double? lastLongitude
});




}
/// @nodoc
class __$GpsDeviceCopyWithImpl<$Res>
    implements _$GpsDeviceCopyWith<$Res> {
  __$GpsDeviceCopyWithImpl(this._self, this._then);

  final _GpsDevice _self;
  final $Res Function(_GpsDevice) _then;

/// Create a copy of GpsDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? imei = null,Object? transporterId = null,Object? status = null,Object? vehicleNumber = freezed,Object? simNumber = freezed,Object? lastSeenAt = freezed,Object? lastLatitude = freezed,Object? lastLongitude = freezed,}) {
  return _then(_GpsDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,imei: null == imei ? _self.imei : imei // ignore: cast_nullable_to_non_nullable
as String,transporterId: null == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GpsDeviceStatus,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,simNumber: freezed == simNumber ? _self.simNumber : simNumber // ignore: cast_nullable_to_non_nullable
as String?,lastSeenAt: freezed == lastSeenAt ? _self.lastSeenAt : lastSeenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastLatitude: freezed == lastLatitude ? _self.lastLatitude : lastLatitude // ignore: cast_nullable_to_non_nullable
as double?,lastLongitude: freezed == lastLongitude ? _self.lastLongitude : lastLongitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
