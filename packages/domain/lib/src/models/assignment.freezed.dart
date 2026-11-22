// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Assignment {

 String get id; String get driverId; String get transporterId; String? get jobId; String? get applicationId; AssignmentStatus get status; DateTime get appointedAt; DateTime? get endedAt; String? get vehicleNumber;
/// Create a copy of Assignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssignmentCopyWith<Assignment> get copyWith => _$AssignmentCopyWithImpl<Assignment>(this as Assignment, _$identity);

  /// Serializes this Assignment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Assignment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Assignment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.transporterId, _this.transporterId) || other.transporterId == _this.transporterId)&&(identical(other.jobId, _this.jobId) || other.jobId == _this.jobId)&&(identical(other.applicationId, _this.applicationId) || other.applicationId == _this.applicationId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.appointedAt, _this.appointedAt) || other.appointedAt == _this.appointedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.vehicleNumber, _this.vehicleNumber) || other.vehicleNumber == _this.vehicleNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Assignment;
  return Object.hash(runtimeType,_this.id,_this.driverId,_this.transporterId,_this.jobId,_this.applicationId,_this.status,_this.appointedAt,_this.endedAt,_this.vehicleNumber);
}

@override
String toString() {
  final _this = this as Assignment;
  return 'Assignment(id: ${_this.id}, driverId: ${_this.driverId}, transporterId: ${_this.transporterId}, jobId: ${_this.jobId}, applicationId: ${_this.applicationId}, status: ${_this.status}, appointedAt: ${_this.appointedAt}, endedAt: ${_this.endedAt}, vehicleNumber: ${_this.vehicleNumber})';
}


}

/// @nodoc
abstract mixin class $AssignmentCopyWith<$Res>  {
  factory $AssignmentCopyWith(Assignment value, $Res Function(Assignment) _then) = _$AssignmentCopyWithImpl;
@useResult
$Res call({
 String id, String driverId, String transporterId, String? jobId, String? applicationId, AssignmentStatus status, DateTime appointedAt, DateTime? endedAt, String? vehicleNumber
});




}
/// @nodoc
class _$AssignmentCopyWithImpl<$Res>
    implements $AssignmentCopyWith<$Res> {
  _$AssignmentCopyWithImpl(this._self, this._then);

  final Assignment _self;
  final $Res Function(Assignment) _then;

/// Create a copy of Assignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? transporterId = null,Object? jobId = freezed,Object? applicationId = freezed,Object? status = null,Object? appointedAt = null,Object? endedAt = freezed,Object? vehicleNumber = freezed,}) {
  return _then(Assignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,transporterId: null == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,applicationId: freezed == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssignmentStatus,appointedAt: null == appointedAt ? _self.appointedAt : appointedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Assignment].
extension AssignmentPatterns on Assignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Assignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Assignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Assignment value)  $default,){
final _that = this;
switch (_that) {
case _Assignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Assignment value)?  $default,){
final _that = this;
switch (_that) {
case _Assignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String driverId,  String transporterId,  String? jobId,  String? applicationId,  AssignmentStatus status,  DateTime appointedAt,  DateTime? endedAt,  String? vehicleNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Assignment() when $default != null:
return $default(_that.id,_that.driverId,_that.transporterId,_that.jobId,_that.applicationId,_that.status,_that.appointedAt,_that.endedAt,_that.vehicleNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String driverId,  String transporterId,  String? jobId,  String? applicationId,  AssignmentStatus status,  DateTime appointedAt,  DateTime? endedAt,  String? vehicleNumber)  $default,) {final _that = this;
switch (_that) {
case _Assignment():
return $default(_that.id,_that.driverId,_that.transporterId,_that.jobId,_that.applicationId,_that.status,_that.appointedAt,_that.endedAt,_that.vehicleNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String driverId,  String transporterId,  String? jobId,  String? applicationId,  AssignmentStatus status,  DateTime appointedAt,  DateTime? endedAt,  String? vehicleNumber)?  $default,) {final _that = this;
switch (_that) {
case _Assignment() when $default != null:
return $default(_that.id,_that.driverId,_that.transporterId,_that.jobId,_that.applicationId,_that.status,_that.appointedAt,_that.endedAt,_that.vehicleNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Assignment implements Assignment {
  const _Assignment({required this.id, required this.driverId, required this.transporterId, this.jobId, this.applicationId, required this.status, required this.appointedAt, this.endedAt, this.vehicleNumber});
  factory _Assignment.fromJson(Map<String, dynamic> json) => _$AssignmentFromJson(json);

@override final  String id;
@override final  String driverId;
@override final  String transporterId;
@override final  String? jobId;
@override final  String? applicationId;
@override final  AssignmentStatus status;
@override final  DateTime appointedAt;
@override final  DateTime? endedAt;
@override final  String? vehicleNumber;

/// Create a copy of Assignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssignmentCopyWith<_Assignment> get copyWith => __$AssignmentCopyWithImpl<_Assignment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssignmentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Assignment&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.transporterId, transporterId) || other.transporterId == transporterId)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.applicationId, applicationId) || other.applicationId == applicationId)&&(identical(other.status, status) || other.status == status)&&(identical(other.appointedAt, appointedAt) || other.appointedAt == appointedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,driverId,transporterId,jobId,applicationId,status,appointedAt,endedAt,vehicleNumber);
}

@override
String toString() {
    return 'Assignment(id: $id, driverId: $driverId, transporterId: $transporterId, jobId: $jobId, applicationId: $applicationId, status: $status, appointedAt: $appointedAt, endedAt: $endedAt, vehicleNumber: $vehicleNumber)';
}


}

/// @nodoc
abstract mixin class _$AssignmentCopyWith<$Res> implements $AssignmentCopyWith<$Res> {
  factory _$AssignmentCopyWith(_Assignment value, $Res Function(_Assignment) _then) = __$AssignmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String driverId, String transporterId, String? jobId, String? applicationId, AssignmentStatus status, DateTime appointedAt, DateTime? endedAt, String? vehicleNumber
});




}
/// @nodoc
class __$AssignmentCopyWithImpl<$Res>
    implements _$AssignmentCopyWith<$Res> {
  __$AssignmentCopyWithImpl(this._self, this._then);

  final _Assignment _self;
  final $Res Function(_Assignment) _then;

/// Create a copy of Assignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? transporterId = null,Object? jobId = freezed,Object? applicationId = freezed,Object? status = null,Object? appointedAt = null,Object? endedAt = freezed,Object? vehicleNumber = freezed,}) {
  return _then(_Assignment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,transporterId: null == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String,jobId: freezed == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String?,applicationId: freezed == applicationId ? _self.applicationId : applicationId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AssignmentStatus,appointedAt: null == appointedAt ? _self.appointedAt : appointedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
