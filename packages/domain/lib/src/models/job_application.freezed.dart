// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobApplication {

 String get id; String get jobId; String get driverId; ApplicationStatus get status; DateTime get appliedAt; String? get coverNote;/// Snapshot of the driver's declared experience at application time.
 Map<VehicleCategory, int> get experienceSnapshot; String? get assignmentId;
/// Create a copy of JobApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobApplicationCopyWith<JobApplication> get copyWith => _$JobApplicationCopyWithImpl<JobApplication>(this as JobApplication, _$identity);

  /// Serializes this JobApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as JobApplication;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobApplication&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.jobId, _this.jobId) || other.jobId == _this.jobId)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.appliedAt, _this.appliedAt) || other.appliedAt == _this.appliedAt)&&(identical(other.coverNote, _this.coverNote) || other.coverNote == _this.coverNote)&&const DeepCollectionEquality().equals(other.experienceSnapshot, _this.experienceSnapshot)&&(identical(other.assignmentId, _this.assignmentId) || other.assignmentId == _this.assignmentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as JobApplication;
  return Object.hash(runtimeType,_this.id,_this.jobId,_this.driverId,_this.status,_this.appliedAt,_this.coverNote,const DeepCollectionEquality().hash(_this.experienceSnapshot),_this.assignmentId);
}

@override
String toString() {
  final _this = this as JobApplication;
  return 'JobApplication(id: ${_this.id}, jobId: ${_this.jobId}, driverId: ${_this.driverId}, status: ${_this.status}, appliedAt: ${_this.appliedAt}, coverNote: ${_this.coverNote}, experienceSnapshot: ${_this.experienceSnapshot}, assignmentId: ${_this.assignmentId})';
}


}

/// @nodoc
abstract mixin class $JobApplicationCopyWith<$Res>  {
  factory $JobApplicationCopyWith(JobApplication value, $Res Function(JobApplication) _then) = _$JobApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String jobId, String driverId, ApplicationStatus status, DateTime appliedAt, String? coverNote, Map<VehicleCategory, int> experienceSnapshot, String? assignmentId
});




}
/// @nodoc
class _$JobApplicationCopyWithImpl<$Res>
    implements $JobApplicationCopyWith<$Res> {
  _$JobApplicationCopyWithImpl(this._self, this._then);

  final JobApplication _self;
  final $Res Function(JobApplication) _then;

/// Create a copy of JobApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? jobId = null,Object? driverId = null,Object? status = null,Object? appliedAt = null,Object? coverNote = freezed,Object? experienceSnapshot = null,Object? assignmentId = freezed,}) {
  return _then(JobApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,appliedAt: null == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as DateTime,coverNote: freezed == coverNote ? _self.coverNote : coverNote // ignore: cast_nullable_to_non_nullable
as String?,experienceSnapshot: null == experienceSnapshot ? _self.experienceSnapshot : experienceSnapshot // ignore: cast_nullable_to_non_nullable
as Map<VehicleCategory, int>,assignmentId: freezed == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [JobApplication].
extension JobApplicationPatterns on JobApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobApplication value)  $default,){
final _that = this;
switch (_that) {
case _JobApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobApplication value)?  $default,){
final _that = this;
switch (_that) {
case _JobApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String jobId,  String driverId,  ApplicationStatus status,  DateTime appliedAt,  String? coverNote,  Map<VehicleCategory, int> experienceSnapshot,  String? assignmentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobApplication() when $default != null:
return $default(_that.id,_that.jobId,_that.driverId,_that.status,_that.appliedAt,_that.coverNote,_that.experienceSnapshot,_that.assignmentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String jobId,  String driverId,  ApplicationStatus status,  DateTime appliedAt,  String? coverNote,  Map<VehicleCategory, int> experienceSnapshot,  String? assignmentId)  $default,) {final _that = this;
switch (_that) {
case _JobApplication():
return $default(_that.id,_that.jobId,_that.driverId,_that.status,_that.appliedAt,_that.coverNote,_that.experienceSnapshot,_that.assignmentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String jobId,  String driverId,  ApplicationStatus status,  DateTime appliedAt,  String? coverNote,  Map<VehicleCategory, int> experienceSnapshot,  String? assignmentId)?  $default,) {final _that = this;
switch (_that) {
case _JobApplication() when $default != null:
return $default(_that.id,_that.jobId,_that.driverId,_that.status,_that.appliedAt,_that.coverNote,_that.experienceSnapshot,_that.assignmentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobApplication implements JobApplication {
  const _JobApplication({required this.id, required this.jobId, required this.driverId, required this.status, required this.appliedAt, this.coverNote,  Map<VehicleCategory, int> experienceSnapshot = const <VehicleCategory, int>{}, this.assignmentId}): _experienceSnapshot = experienceSnapshot;
  factory _JobApplication.fromJson(Map<String, dynamic> json) => _$JobApplicationFromJson(json);

@override final  String id;
@override final  String jobId;
@override final  String driverId;
@override final  ApplicationStatus status;
@override final  DateTime appliedAt;
@override final  String? coverNote;
/// Snapshot of the driver's declared experience at application time.
 final  Map<VehicleCategory, int> _experienceSnapshot;
/// Snapshot of the driver's declared experience at application time.
@override@JsonKey() Map<VehicleCategory, int> get experienceSnapshot {
  if (_experienceSnapshot is EqualUnmodifiableMapView) return _experienceSnapshot;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_experienceSnapshot);
}

@override final  String? assignmentId;

/// Create a copy of JobApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobApplicationCopyWith<_JobApplication> get copyWith => __$JobApplicationCopyWithImpl<_JobApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.status, status) || other.status == status)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt)&&(identical(other.coverNote, coverNote) || other.coverNote == coverNote)&&const DeepCollectionEquality().equals(other.experienceSnapshot, _experienceSnapshot)&&(identical(other.assignmentId, assignmentId) || other.assignmentId == assignmentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,jobId,driverId,status,appliedAt,coverNote,const DeepCollectionEquality().hash(_experienceSnapshot),assignmentId);
}

@override
String toString() {
    return 'JobApplication(id: $id, jobId: $jobId, driverId: $driverId, status: $status, appliedAt: $appliedAt, coverNote: $coverNote, experienceSnapshot: $experienceSnapshot, assignmentId: $assignmentId)';
}


}

/// @nodoc
abstract mixin class _$JobApplicationCopyWith<$Res> implements $JobApplicationCopyWith<$Res> {
  factory _$JobApplicationCopyWith(_JobApplication value, $Res Function(_JobApplication) _then) = __$JobApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String jobId, String driverId, ApplicationStatus status, DateTime appliedAt, String? coverNote, Map<VehicleCategory, int> experienceSnapshot, String? assignmentId
});




}
/// @nodoc
class __$JobApplicationCopyWithImpl<$Res>
    implements _$JobApplicationCopyWith<$Res> {
  __$JobApplicationCopyWithImpl(this._self, this._then);

  final _JobApplication _self;
  final $Res Function(_JobApplication) _then;

/// Create a copy of JobApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? jobId = null,Object? driverId = null,Object? status = null,Object? appliedAt = null,Object? coverNote = freezed,Object? experienceSnapshot = null,Object? assignmentId = freezed,}) {
  return _then(_JobApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,appliedAt: null == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as DateTime,coverNote: freezed == coverNote ? _self.coverNote : coverNote // ignore: cast_nullable_to_non_nullable
as String?,experienceSnapshot: null == experienceSnapshot ? _self._experienceSnapshot : experienceSnapshot // ignore: cast_nullable_to_non_nullable
as Map<VehicleCategory, int>,assignmentId: freezed == assignmentId ? _self.assignmentId : assignmentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
