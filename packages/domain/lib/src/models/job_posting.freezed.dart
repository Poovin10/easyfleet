// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'job_posting.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$JobPosting {

 String get id; String get transporterId; String get title; Set<LicenseClass> get requiredLicenseClasses;/// Minimum years of experience per vehicle category.
 Map<VehicleCategory, int> get requiredExperience; VehicleCategory? get vehicleCategory; String? get pickupLocation; String? get dropLocation; double? get payPerTrip; String? get description; JobStatus get status; DateTime get createdAt; DateTime? get expiresAt; int get applicantCount;
/// Create a copy of JobPosting
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JobPostingCopyWith<JobPosting> get copyWith => _$JobPostingCopyWithImpl<JobPosting>(this as JobPosting, _$identity);

  /// Serializes this JobPosting to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as JobPosting;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JobPosting&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.transporterId, _this.transporterId) || other.transporterId == _this.transporterId)&&(identical(other.title, _this.title) || other.title == _this.title)&&const DeepCollectionEquality().equals(other.requiredLicenseClasses, _this.requiredLicenseClasses)&&const DeepCollectionEquality().equals(other.requiredExperience, _this.requiredExperience)&&(identical(other.vehicleCategory, _this.vehicleCategory) || other.vehicleCategory == _this.vehicleCategory)&&(identical(other.pickupLocation, _this.pickupLocation) || other.pickupLocation == _this.pickupLocation)&&(identical(other.dropLocation, _this.dropLocation) || other.dropLocation == _this.dropLocation)&&(identical(other.payPerTrip, _this.payPerTrip) || other.payPerTrip == _this.payPerTrip)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.applicantCount, _this.applicantCount) || other.applicantCount == _this.applicantCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as JobPosting;
  return Object.hash(runtimeType,_this.id,_this.transporterId,_this.title,const DeepCollectionEquality().hash(_this.requiredLicenseClasses),const DeepCollectionEquality().hash(_this.requiredExperience),_this.vehicleCategory,_this.pickupLocation,_this.dropLocation,_this.payPerTrip,_this.description,_this.status,_this.createdAt,_this.expiresAt,_this.applicantCount);
}

@override
String toString() {
  final _this = this as JobPosting;
  return 'JobPosting(id: ${_this.id}, transporterId: ${_this.transporterId}, title: ${_this.title}, requiredLicenseClasses: ${_this.requiredLicenseClasses}, requiredExperience: ${_this.requiredExperience}, vehicleCategory: ${_this.vehicleCategory}, pickupLocation: ${_this.pickupLocation}, dropLocation: ${_this.dropLocation}, payPerTrip: ${_this.payPerTrip}, description: ${_this.description}, status: ${_this.status}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt}, applicantCount: ${_this.applicantCount})';
}


}

/// @nodoc
abstract mixin class $JobPostingCopyWith<$Res>  {
  factory $JobPostingCopyWith(JobPosting value, $Res Function(JobPosting) _then) = _$JobPostingCopyWithImpl;
@useResult
$Res call({
 String id, String transporterId, String title, Set<LicenseClass> requiredLicenseClasses, Map<VehicleCategory, int> requiredExperience, VehicleCategory? vehicleCategory, String? pickupLocation, String? dropLocation, double? payPerTrip, String? description, JobStatus status, DateTime createdAt, DateTime? expiresAt, int applicantCount
});




}
/// @nodoc
class _$JobPostingCopyWithImpl<$Res>
    implements $JobPostingCopyWith<$Res> {
  _$JobPostingCopyWithImpl(this._self, this._then);

  final JobPosting _self;
  final $Res Function(JobPosting) _then;

/// Create a copy of JobPosting
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? transporterId = null,Object? title = null,Object? requiredLicenseClasses = null,Object? requiredExperience = null,Object? vehicleCategory = freezed,Object? pickupLocation = freezed,Object? dropLocation = freezed,Object? payPerTrip = freezed,Object? description = freezed,Object? status = null,Object? createdAt = null,Object? expiresAt = freezed,Object? applicantCount = null,}) {
  return _then(JobPosting(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transporterId: null == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,requiredLicenseClasses: null == requiredLicenseClasses ? _self.requiredLicenseClasses : requiredLicenseClasses // ignore: cast_nullable_to_non_nullable
as Set<LicenseClass>,requiredExperience: null == requiredExperience ? _self.requiredExperience : requiredExperience // ignore: cast_nullable_to_non_nullable
as Map<VehicleCategory, int>,vehicleCategory: freezed == vehicleCategory ? _self.vehicleCategory : vehicleCategory // ignore: cast_nullable_to_non_nullable
as VehicleCategory?,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String?,dropLocation: freezed == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String?,payPerTrip: freezed == payPerTrip ? _self.payPerTrip : payPerTrip // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,applicantCount: null == applicantCount ? _self.applicantCount : applicantCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [JobPosting].
extension JobPostingPatterns on JobPosting {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JobPosting value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JobPosting() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JobPosting value)  $default,){
final _that = this;
switch (_that) {
case _JobPosting():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JobPosting value)?  $default,){
final _that = this;
switch (_that) {
case _JobPosting() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String transporterId,  String title,  Set<LicenseClass> requiredLicenseClasses,  Map<VehicleCategory, int> requiredExperience,  VehicleCategory? vehicleCategory,  String? pickupLocation,  String? dropLocation,  double? payPerTrip,  String? description,  JobStatus status,  DateTime createdAt,  DateTime? expiresAt,  int applicantCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JobPosting() when $default != null:
return $default(_that.id,_that.transporterId,_that.title,_that.requiredLicenseClasses,_that.requiredExperience,_that.vehicleCategory,_that.pickupLocation,_that.dropLocation,_that.payPerTrip,_that.description,_that.status,_that.createdAt,_that.expiresAt,_that.applicantCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String transporterId,  String title,  Set<LicenseClass> requiredLicenseClasses,  Map<VehicleCategory, int> requiredExperience,  VehicleCategory? vehicleCategory,  String? pickupLocation,  String? dropLocation,  double? payPerTrip,  String? description,  JobStatus status,  DateTime createdAt,  DateTime? expiresAt,  int applicantCount)  $default,) {final _that = this;
switch (_that) {
case _JobPosting():
return $default(_that.id,_that.transporterId,_that.title,_that.requiredLicenseClasses,_that.requiredExperience,_that.vehicleCategory,_that.pickupLocation,_that.dropLocation,_that.payPerTrip,_that.description,_that.status,_that.createdAt,_that.expiresAt,_that.applicantCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String transporterId,  String title,  Set<LicenseClass> requiredLicenseClasses,  Map<VehicleCategory, int> requiredExperience,  VehicleCategory? vehicleCategory,  String? pickupLocation,  String? dropLocation,  double? payPerTrip,  String? description,  JobStatus status,  DateTime createdAt,  DateTime? expiresAt,  int applicantCount)?  $default,) {final _that = this;
switch (_that) {
case _JobPosting() when $default != null:
return $default(_that.id,_that.transporterId,_that.title,_that.requiredLicenseClasses,_that.requiredExperience,_that.vehicleCategory,_that.pickupLocation,_that.dropLocation,_that.payPerTrip,_that.description,_that.status,_that.createdAt,_that.expiresAt,_that.applicantCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _JobPosting implements JobPosting {
  const _JobPosting({required this.id, required this.transporterId, required this.title, required  Set<LicenseClass> requiredLicenseClasses,  Map<VehicleCategory, int> requiredExperience = const <VehicleCategory, int>{}, this.vehicleCategory, this.pickupLocation, this.dropLocation, this.payPerTrip, this.description, required this.status, required this.createdAt, this.expiresAt, this.applicantCount = 0}): _requiredLicenseClasses = requiredLicenseClasses,_requiredExperience = requiredExperience;
  factory _JobPosting.fromJson(Map<String, dynamic> json) => _$JobPostingFromJson(json);

@override final  String id;
@override final  String transporterId;
@override final  String title;
 final  Set<LicenseClass> _requiredLicenseClasses;
@override Set<LicenseClass> get requiredLicenseClasses {
  if (_requiredLicenseClasses is EqualUnmodifiableSetView) return _requiredLicenseClasses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_requiredLicenseClasses);
}

/// Minimum years of experience per vehicle category.
 final  Map<VehicleCategory, int> _requiredExperience;
/// Minimum years of experience per vehicle category.
@override@JsonKey() Map<VehicleCategory, int> get requiredExperience {
  if (_requiredExperience is EqualUnmodifiableMapView) return _requiredExperience;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_requiredExperience);
}

@override final  VehicleCategory? vehicleCategory;
@override final  String? pickupLocation;
@override final  String? dropLocation;
@override final  double? payPerTrip;
@override final  String? description;
@override final  JobStatus status;
@override final  DateTime createdAt;
@override final  DateTime? expiresAt;
@override@JsonKey() final  int applicantCount;

/// Create a copy of JobPosting
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JobPostingCopyWith<_JobPosting> get copyWith => __$JobPostingCopyWithImpl<_JobPosting>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JobPostingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _JobPosting&&(identical(other.id, id) || other.id == id)&&(identical(other.transporterId, transporterId) || other.transporterId == transporterId)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.requiredLicenseClasses, _requiredLicenseClasses)&&const DeepCollectionEquality().equals(other.requiredExperience, _requiredExperience)&&(identical(other.vehicleCategory, vehicleCategory) || other.vehicleCategory == vehicleCategory)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.dropLocation, dropLocation) || other.dropLocation == dropLocation)&&(identical(other.payPerTrip, payPerTrip) || other.payPerTrip == payPerTrip)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.applicantCount, applicantCount) || other.applicantCount == applicantCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,transporterId,title,const DeepCollectionEquality().hash(_requiredLicenseClasses),const DeepCollectionEquality().hash(_requiredExperience),vehicleCategory,pickupLocation,dropLocation,payPerTrip,description,status,createdAt,expiresAt,applicantCount);
}

@override
String toString() {
    return 'JobPosting(id: $id, transporterId: $transporterId, title: $title, requiredLicenseClasses: $requiredLicenseClasses, requiredExperience: $requiredExperience, vehicleCategory: $vehicleCategory, pickupLocation: $pickupLocation, dropLocation: $dropLocation, payPerTrip: $payPerTrip, description: $description, status: $status, createdAt: $createdAt, expiresAt: $expiresAt, applicantCount: $applicantCount)';
}


}

/// @nodoc
abstract mixin class _$JobPostingCopyWith<$Res> implements $JobPostingCopyWith<$Res> {
  factory _$JobPostingCopyWith(_JobPosting value, $Res Function(_JobPosting) _then) = __$JobPostingCopyWithImpl;
@override @useResult
$Res call({
 String id, String transporterId, String title, Set<LicenseClass> requiredLicenseClasses, Map<VehicleCategory, int> requiredExperience, VehicleCategory? vehicleCategory, String? pickupLocation, String? dropLocation, double? payPerTrip, String? description, JobStatus status, DateTime createdAt, DateTime? expiresAt, int applicantCount
});




}
/// @nodoc
class __$JobPostingCopyWithImpl<$Res>
    implements _$JobPostingCopyWith<$Res> {
  __$JobPostingCopyWithImpl(this._self, this._then);

  final _JobPosting _self;
  final $Res Function(_JobPosting) _then;

/// Create a copy of JobPosting
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? transporterId = null,Object? title = null,Object? requiredLicenseClasses = null,Object? requiredExperience = null,Object? vehicleCategory = freezed,Object? pickupLocation = freezed,Object? dropLocation = freezed,Object? payPerTrip = freezed,Object? description = freezed,Object? status = null,Object? createdAt = null,Object? expiresAt = freezed,Object? applicantCount = null,}) {
  return _then(_JobPosting(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,transporterId: null == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,requiredLicenseClasses: null == requiredLicenseClasses ? _self._requiredLicenseClasses : requiredLicenseClasses // ignore: cast_nullable_to_non_nullable
as Set<LicenseClass>,requiredExperience: null == requiredExperience ? _self._requiredExperience : requiredExperience // ignore: cast_nullable_to_non_nullable
as Map<VehicleCategory, int>,vehicleCategory: freezed == vehicleCategory ? _self.vehicleCategory : vehicleCategory // ignore: cast_nullable_to_non_nullable
as VehicleCategory?,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String?,dropLocation: freezed == dropLocation ? _self.dropLocation : dropLocation // ignore: cast_nullable_to_non_nullable
as String?,payPerTrip: freezed == payPerTrip ? _self.payPerTrip : payPerTrip // ignore: cast_nullable_to_non_nullable
as double?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JobStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,applicantCount: null == applicantCount ? _self.applicantCount : applicantCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
