// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Trip {

 String get id; String get vehicleNumber; String? get driverId; String? get transporterId; String? get assignmentId;/// Tracker IMEI when this trip is being followed by a transporter GPS device.
 String? get gpsDeviceId; String? get partyName; String? get loadingPoint; String? get unloadingPoint; TripStage get stage; DateTime? get scheduledAt; DateTime? get startedAt; DateTime? get completedAt; double? get tonnage; String? get currentLocationLabel;
/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripCopyWith<Trip> get copyWith => _$TripCopyWithImpl<Trip>(this as Trip, _$identity);

  /// Serializes this Trip to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Trip;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trip&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.vehicleNumber, _this.vehicleNumber) || other.vehicleNumber == _this.vehicleNumber)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.transporterId, _this.transporterId) || other.transporterId == _this.transporterId)&&(identical(other.assignmentId, _this.assignmentId) || other.assignmentId == _this.assignmentId)&&(identical(other.gpsDeviceId, _this.gpsDeviceId) || other.gpsDeviceId == _this.gpsDeviceId)&&(identical(other.partyName, _this.partyName) || other.partyName == _this.partyName)&&(identical(other.loadingPoint, _this.loadingPoint) || other.loadingPoint == _this.loadingPoint)&&(identical(other.unloadingPoint, _this.unloadingPoint) || other.unloadingPoint == _this.unloadingPoint)&&(identical(other.stage, _this.stage) || other.stage == _this.stage)&&(identical(other.scheduledAt, _this.scheduledAt) || other.scheduledAt == _this.scheduledAt)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.tonnage, _this.tonnage) || other.tonnage == _this.tonnage)&&(identical(other.currentLocationLabel, _this.currentLocationLabel) || other.currentLocationLabel == _this.currentLocationLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Trip;
  return Object.hash(runtimeType,_this.id,_this.vehicleNumber,_this.driverId,_this.transporterId,_this.assignmentId,_this.gpsDeviceId,_this.partyName,_this.loadingPoint,_this.unloadingPoint,_this.stage,_this.scheduledAt,_this.startedAt,_this.completedAt,_this.tonnage,_this.currentLocationLabel);
}

@override
String toString() {
  final _this = this as Trip;
  return 'Trip(id: ${_this.id}, vehicleNumber: ${_this.vehicleNumber}, driverId: ${_this.driverId}, transporterId: ${_this.transporterId}, assignmentId: ${_this.assignmentId}, gpsDeviceId: ${_this.gpsDeviceId}, partyName: ${_this.partyName}, loadingPoint: ${_this.loadingPoint}, unloadingPoint: ${_this.unloadingPoint}, stage: ${_this.stage}, scheduledAt: ${_this.scheduledAt}, startedAt: ${_this.startedAt}, completedAt: ${_this.completedAt}, tonnage: ${_this.tonnage}, currentLocationLabel: ${_this.currentLocationLabel})';
}


}

/// @nodoc
abstract mixin class $TripCopyWith<$Res>  {
  factory $TripCopyWith(Trip value, $Res Function(Trip) _then) = _$TripCopyWithImpl;
@useResult
$Res call({
 String id, String vehicleNumber, String? driverId, String? transporterId, String? assignmentId, String? gpsDeviceId, String? partyName, String? loadingPoint, String? unloadingPoint, TripStage stage, DateTime? scheduledAt, DateTime? startedAt, DateTime? completedAt, double? tonnage, String? currentLocationLabel
});




}
/// @nodoc
class _$TripCopyWithImpl<$Res>
    implements $TripCopyWith<$Res> {
  _$TripCopyWithImpl(this._self, this._then);

  final Trip _self;
  final $Res Function(Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? vehicleNumber = null,Object? driverId = freezed,Object? transporterId = freezed,Object? assignmentId = freezed,Object? gpsDeviceId = freezed,Object? partyName = freezed,Object? loadingPoint = freezed,Object? unloadingPoint = freezed,Object? stage = null,Object? scheduledAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? tonnage = freezed,Object? currentLocationLabel = freezed,}) {
  return _then(Trip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,transporterId: freezed == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String?,assignmentId: freezed == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String?,gpsDeviceId: freezed == gpsDeviceId ? _self.gpsDeviceId : gpsDeviceId // ignore: cast_nullable_to_non_nullable
as String?,partyName: freezed == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String?,loadingPoint: freezed == loadingPoint ? _self.loadingPoint : loadingPoint // ignore: cast_nullable_to_non_nullable
as String?,unloadingPoint: freezed == unloadingPoint ? _self.unloadingPoint : unloadingPoint // ignore: cast_nullable_to_non_nullable
as String?,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as TripStage,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tonnage: freezed == tonnage ? _self.tonnage : tonnage // ignore: cast_nullable_to_non_nullable
as double?,currentLocationLabel: freezed == currentLocationLabel ? _self.currentLocationLabel : currentLocationLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Trip].
extension TripPatterns on Trip {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trip value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trip value)  $default,){
final _that = this;
switch (_that) {
case _Trip():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trip value)?  $default,){
final _that = this;
switch (_that) {
case _Trip() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String vehicleNumber,  String? driverId,  String? transporterId,  String? assignmentId,  String? gpsDeviceId,  String? partyName,  String? loadingPoint,  String? unloadingPoint,  TripStage stage,  DateTime? scheduledAt,  DateTime? startedAt,  DateTime? completedAt,  double? tonnage,  String? currentLocationLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.vehicleNumber,_that.driverId,_that.transporterId,_that.assignmentId,_that.gpsDeviceId,_that.partyName,_that.loadingPoint,_that.unloadingPoint,_that.stage,_that.scheduledAt,_that.startedAt,_that.completedAt,_that.tonnage,_that.currentLocationLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String vehicleNumber,  String? driverId,  String? transporterId,  String? assignmentId,  String? gpsDeviceId,  String? partyName,  String? loadingPoint,  String? unloadingPoint,  TripStage stage,  DateTime? scheduledAt,  DateTime? startedAt,  DateTime? completedAt,  double? tonnage,  String? currentLocationLabel)  $default,) {final _that = this;
switch (_that) {
case _Trip():
return $default(_that.id,_that.vehicleNumber,_that.driverId,_that.transporterId,_that.assignmentId,_that.gpsDeviceId,_that.partyName,_that.loadingPoint,_that.unloadingPoint,_that.stage,_that.scheduledAt,_that.startedAt,_that.completedAt,_that.tonnage,_that.currentLocationLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String vehicleNumber,  String? driverId,  String? transporterId,  String? assignmentId,  String? gpsDeviceId,  String? partyName,  String? loadingPoint,  String? unloadingPoint,  TripStage stage,  DateTime? scheduledAt,  DateTime? startedAt,  DateTime? completedAt,  double? tonnage,  String? currentLocationLabel)?  $default,) {final _that = this;
switch (_that) {
case _Trip() when $default != null:
return $default(_that.id,_that.vehicleNumber,_that.driverId,_that.transporterId,_that.assignmentId,_that.gpsDeviceId,_that.partyName,_that.loadingPoint,_that.unloadingPoint,_that.stage,_that.scheduledAt,_that.startedAt,_that.completedAt,_that.tonnage,_that.currentLocationLabel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trip implements Trip {
  const _Trip({required this.id, required this.vehicleNumber, this.driverId, this.transporterId, this.assignmentId, this.gpsDeviceId, this.partyName, this.loadingPoint, this.unloadingPoint, required this.stage, this.scheduledAt, this.startedAt, this.completedAt, this.tonnage, this.currentLocationLabel});
  factory _Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);

@override final  String id;
@override final  String vehicleNumber;
@override final  String? driverId;
@override final  String? transporterId;
@override final  String? assignmentId;
/// Tracker IMEI when this trip is being followed by a transporter GPS device.
@override final  String? gpsDeviceId;
@override final  String? partyName;
@override final  String? loadingPoint;
@override final  String? unloadingPoint;
@override final  TripStage stage;
@override final  DateTime? scheduledAt;
@override final  DateTime? startedAt;
@override final  DateTime? completedAt;
@override final  double? tonnage;
@override final  String? currentLocationLabel;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripCopyWith<_Trip> get copyWith => __$TripCopyWithImpl<_Trip>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trip&&(identical(other.id, id) || other.id == id)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.transporterId, transporterId) || other.transporterId == transporterId)&&(identical(other.assignmentId, assignmentId) || other.assignmentId == assignmentId)&&(identical(other.gpsDeviceId, gpsDeviceId) || other.gpsDeviceId == gpsDeviceId)&&(identical(other.partyName, partyName) || other.partyName == partyName)&&(identical(other.loadingPoint, loadingPoint) || other.loadingPoint == loadingPoint)&&(identical(other.unloadingPoint, unloadingPoint) || other.unloadingPoint == unloadingPoint)&&(identical(other.stage, stage) || other.stage == stage)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.tonnage, tonnage) || other.tonnage == tonnage)&&(identical(other.currentLocationLabel, currentLocationLabel) || other.currentLocationLabel == currentLocationLabel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,vehicleNumber,driverId,transporterId,assignmentId,gpsDeviceId,partyName,loadingPoint,unloadingPoint,stage,scheduledAt,startedAt,completedAt,tonnage,currentLocationLabel);
}

@override
String toString() {
    return 'Trip(id: $id, vehicleNumber: $vehicleNumber, driverId: $driverId, transporterId: $transporterId, assignmentId: $assignmentId, gpsDeviceId: $gpsDeviceId, partyName: $partyName, loadingPoint: $loadingPoint, unloadingPoint: $unloadingPoint, stage: $stage, scheduledAt: $scheduledAt, startedAt: $startedAt, completedAt: $completedAt, tonnage: $tonnage, currentLocationLabel: $currentLocationLabel)';
}


}

/// @nodoc
abstract mixin class _$TripCopyWith<$Res> implements $TripCopyWith<$Res> {
  factory _$TripCopyWith(_Trip value, $Res Function(_Trip) _then) = __$TripCopyWithImpl;
@override @useResult
$Res call({
 String id, String vehicleNumber, String? driverId, String? transporterId, String? assignmentId, String? gpsDeviceId, String? partyName, String? loadingPoint, String? unloadingPoint, TripStage stage, DateTime? scheduledAt, DateTime? startedAt, DateTime? completedAt, double? tonnage, String? currentLocationLabel
});




}
/// @nodoc
class __$TripCopyWithImpl<$Res>
    implements _$TripCopyWith<$Res> {
  __$TripCopyWithImpl(this._self, this._then);

  final _Trip _self;
  final $Res Function(_Trip) _then;

/// Create a copy of Trip
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? vehicleNumber = null,Object? driverId = freezed,Object? transporterId = freezed,Object? assignmentId = freezed,Object? gpsDeviceId = freezed,Object? partyName = freezed,Object? loadingPoint = freezed,Object? unloadingPoint = freezed,Object? stage = null,Object? scheduledAt = freezed,Object? startedAt = freezed,Object? completedAt = freezed,Object? tonnage = freezed,Object? currentLocationLabel = freezed,}) {
  return _then(_Trip(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,transporterId: freezed == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String?,assignmentId: freezed == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String?,gpsDeviceId: freezed == gpsDeviceId ? _self.gpsDeviceId : gpsDeviceId // ignore: cast_nullable_to_non_nullable
as String?,partyName: freezed == partyName ? _self.partyName : partyName // ignore: cast_nullable_to_non_nullable
as String?,loadingPoint: freezed == loadingPoint ? _self.loadingPoint : loadingPoint // ignore: cast_nullable_to_non_nullable
as String?,unloadingPoint: freezed == unloadingPoint ? _self.unloadingPoint : unloadingPoint // ignore: cast_nullable_to_non_nullable
as String?,stage: null == stage ? _self.stage : stage // ignore: cast_nullable_to_non_nullable
as TripStage,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,tonnage: freezed == tonnage ? _self.tonnage : tonnage // ignore: cast_nullable_to_non_nullable
as double?,currentLocationLabel: freezed == currentLocationLabel ? _self.currentLocationLabel : currentLocationLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
