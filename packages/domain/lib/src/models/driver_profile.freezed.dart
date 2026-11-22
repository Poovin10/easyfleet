// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverProfile {

 String get id; String get displayName;/// Globally unique driver licence number — the driver's primary identity.
 String get dlNumber; LicenseClass get licenseClass;/// Years of experience keyed by vehicle category (bulker, oil tanker, …).
 Map<VehicleCategory, int> get experienceByVehicle; VerificationStatus get dlVerification; String? get dlDocumentUrl; String? get email; String? get phone; String? get avatarUrl; String? get transporterId; String? get currentAssignmentId; List<String> get permissions;
/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverProfileCopyWith<DriverProfile> get copyWith => _$DriverProfileCopyWithImpl<DriverProfile>(this as DriverProfile, _$identity);

  /// Serializes this DriverProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriverProfile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverProfile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.dlNumber, _this.dlNumber) || other.dlNumber == _this.dlNumber)&&(identical(other.licenseClass, _this.licenseClass) || other.licenseClass == _this.licenseClass)&&const DeepCollectionEquality().equals(other.experienceByVehicle, _this.experienceByVehicle)&&(identical(other.dlVerification, _this.dlVerification) || other.dlVerification == _this.dlVerification)&&(identical(other.dlDocumentUrl, _this.dlDocumentUrl) || other.dlDocumentUrl == _this.dlDocumentUrl)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.transporterId, _this.transporterId) || other.transporterId == _this.transporterId)&&(identical(other.currentAssignmentId, _this.currentAssignmentId) || other.currentAssignmentId == _this.currentAssignmentId)&&const DeepCollectionEquality().equals(other.permissions, _this.permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriverProfile;
  return Object.hash(runtimeType,_this.id,_this.displayName,_this.dlNumber,_this.licenseClass,const DeepCollectionEquality().hash(_this.experienceByVehicle),_this.dlVerification,_this.dlDocumentUrl,_this.email,_this.phone,_this.avatarUrl,_this.transporterId,_this.currentAssignmentId,const DeepCollectionEquality().hash(_this.permissions));
}

@override
String toString() {
  final _this = this as DriverProfile;
  return 'DriverProfile(id: ${_this.id}, displayName: ${_this.displayName}, dlNumber: ${_this.dlNumber}, licenseClass: ${_this.licenseClass}, experienceByVehicle: ${_this.experienceByVehicle}, dlVerification: ${_this.dlVerification}, dlDocumentUrl: ${_this.dlDocumentUrl}, email: ${_this.email}, phone: ${_this.phone}, avatarUrl: ${_this.avatarUrl}, transporterId: ${_this.transporterId}, currentAssignmentId: ${_this.currentAssignmentId}, permissions: ${_this.permissions})';
}


}

/// @nodoc
abstract mixin class $DriverProfileCopyWith<$Res>  {
  factory $DriverProfileCopyWith(DriverProfile value, $Res Function(DriverProfile) _then) = _$DriverProfileCopyWithImpl;
@useResult
$Res call({
 String id, String displayName, String dlNumber, LicenseClass licenseClass, Map<VehicleCategory, int> experienceByVehicle, VerificationStatus dlVerification, String? dlDocumentUrl, String? email, String? phone, String? avatarUrl, String? transporterId, String? currentAssignmentId, List<String> permissions
});




}
/// @nodoc
class _$DriverProfileCopyWithImpl<$Res>
    implements $DriverProfileCopyWith<$Res> {
  _$DriverProfileCopyWithImpl(this._self, this._then);

  final DriverProfile _self;
  final $Res Function(DriverProfile) _then;

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? dlNumber = null,Object? licenseClass = null,Object? experienceByVehicle = null,Object? dlVerification = null,Object? dlDocumentUrl = freezed,Object? email = freezed,Object? phone = freezed,Object? avatarUrl = freezed,Object? transporterId = freezed,Object? currentAssignmentId = freezed,Object? permissions = null,}) {
  return _then(DriverProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,dlNumber: null == dlNumber ? _self.dlNumber : dlNumber // ignore: cast_nullable_to_non_nullable
as String,licenseClass: null == licenseClass ? _self.licenseClass : licenseClass // ignore: cast_nullable_to_non_nullable
as LicenseClass,experienceByVehicle: null == experienceByVehicle ? _self.experienceByVehicle : experienceByVehicle // ignore: cast_nullable_to_non_nullable
as Map<VehicleCategory, int>,dlVerification: null == dlVerification ? _self.dlVerification : dlVerification // ignore: cast_nullable_to_non_nullable
as VerificationStatus,dlDocumentUrl: freezed == dlDocumentUrl ? _self.dlDocumentUrl : dlDocumentUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,transporterId: freezed == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String?,currentAssignmentId: freezed == currentAssignmentId ? _self.currentAssignmentId : currentAssignmentId // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverProfile].
extension DriverProfilePatterns on DriverProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverProfile value)  $default,){
final _that = this;
switch (_that) {
case _DriverProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverProfile value)?  $default,){
final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String displayName,  String dlNumber,  LicenseClass licenseClass,  Map<VehicleCategory, int> experienceByVehicle,  VerificationStatus dlVerification,  String? dlDocumentUrl,  String? email,  String? phone,  String? avatarUrl,  String? transporterId,  String? currentAssignmentId,  List<String> permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.dlNumber,_that.licenseClass,_that.experienceByVehicle,_that.dlVerification,_that.dlDocumentUrl,_that.email,_that.phone,_that.avatarUrl,_that.transporterId,_that.currentAssignmentId,_that.permissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String displayName,  String dlNumber,  LicenseClass licenseClass,  Map<VehicleCategory, int> experienceByVehicle,  VerificationStatus dlVerification,  String? dlDocumentUrl,  String? email,  String? phone,  String? avatarUrl,  String? transporterId,  String? currentAssignmentId,  List<String> permissions)  $default,) {final _that = this;
switch (_that) {
case _DriverProfile():
return $default(_that.id,_that.displayName,_that.dlNumber,_that.licenseClass,_that.experienceByVehicle,_that.dlVerification,_that.dlDocumentUrl,_that.email,_that.phone,_that.avatarUrl,_that.transporterId,_that.currentAssignmentId,_that.permissions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String displayName,  String dlNumber,  LicenseClass licenseClass,  Map<VehicleCategory, int> experienceByVehicle,  VerificationStatus dlVerification,  String? dlDocumentUrl,  String? email,  String? phone,  String? avatarUrl,  String? transporterId,  String? currentAssignmentId,  List<String> permissions)?  $default,) {final _that = this;
switch (_that) {
case _DriverProfile() when $default != null:
return $default(_that.id,_that.displayName,_that.dlNumber,_that.licenseClass,_that.experienceByVehicle,_that.dlVerification,_that.dlDocumentUrl,_that.email,_that.phone,_that.avatarUrl,_that.transporterId,_that.currentAssignmentId,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverProfile implements DriverProfile {
  const _DriverProfile({required this.id, required this.displayName, required this.dlNumber, required this.licenseClass,  Map<VehicleCategory, int> experienceByVehicle = const <VehicleCategory, int>{}, required this.dlVerification, this.dlDocumentUrl, this.email, this.phone, this.avatarUrl, this.transporterId, this.currentAssignmentId,  List<String> permissions = const <String>[]}): _experienceByVehicle = experienceByVehicle,_permissions = permissions;
  factory _DriverProfile.fromJson(Map<String, dynamic> json) => _$DriverProfileFromJson(json);

@override final  String id;
@override final  String displayName;
/// Globally unique driver licence number — the driver's primary identity.
@override final  String dlNumber;
@override final  LicenseClass licenseClass;
/// Years of experience keyed by vehicle category (bulker, oil tanker, …).
 final  Map<VehicleCategory, int> _experienceByVehicle;
/// Years of experience keyed by vehicle category (bulker, oil tanker, …).
@override@JsonKey() Map<VehicleCategory, int> get experienceByVehicle {
  if (_experienceByVehicle is EqualUnmodifiableMapView) return _experienceByVehicle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_experienceByVehicle);
}

@override final  VerificationStatus dlVerification;
@override final  String? dlDocumentUrl;
@override final  String? email;
@override final  String? phone;
@override final  String? avatarUrl;
@override final  String? transporterId;
@override final  String? currentAssignmentId;
 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}


/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverProfileCopyWith<_DriverProfile> get copyWith => __$DriverProfileCopyWithImpl<_DriverProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.dlNumber, dlNumber) || other.dlNumber == dlNumber)&&(identical(other.licenseClass, licenseClass) || other.licenseClass == licenseClass)&&const DeepCollectionEquality().equals(other.experienceByVehicle, _experienceByVehicle)&&(identical(other.dlVerification, dlVerification) || other.dlVerification == dlVerification)&&(identical(other.dlDocumentUrl, dlDocumentUrl) || other.dlDocumentUrl == dlDocumentUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.transporterId, transporterId) || other.transporterId == transporterId)&&(identical(other.currentAssignmentId, currentAssignmentId) || other.currentAssignmentId == currentAssignmentId)&&const DeepCollectionEquality().equals(other.permissions, _permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,displayName,dlNumber,licenseClass,const DeepCollectionEquality().hash(_experienceByVehicle),dlVerification,dlDocumentUrl,email,phone,avatarUrl,transporterId,currentAssignmentId,const DeepCollectionEquality().hash(_permissions));
}

@override
String toString() {
    return 'DriverProfile(id: $id, displayName: $displayName, dlNumber: $dlNumber, licenseClass: $licenseClass, experienceByVehicle: $experienceByVehicle, dlVerification: $dlVerification, dlDocumentUrl: $dlDocumentUrl, email: $email, phone: $phone, avatarUrl: $avatarUrl, transporterId: $transporterId, currentAssignmentId: $currentAssignmentId, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$DriverProfileCopyWith<$Res> implements $DriverProfileCopyWith<$Res> {
  factory _$DriverProfileCopyWith(_DriverProfile value, $Res Function(_DriverProfile) _then) = __$DriverProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String displayName, String dlNumber, LicenseClass licenseClass, Map<VehicleCategory, int> experienceByVehicle, VerificationStatus dlVerification, String? dlDocumentUrl, String? email, String? phone, String? avatarUrl, String? transporterId, String? currentAssignmentId, List<String> permissions
});




}
/// @nodoc
class __$DriverProfileCopyWithImpl<$Res>
    implements _$DriverProfileCopyWith<$Res> {
  __$DriverProfileCopyWithImpl(this._self, this._then);

  final _DriverProfile _self;
  final $Res Function(_DriverProfile) _then;

/// Create a copy of DriverProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? dlNumber = null,Object? licenseClass = null,Object? experienceByVehicle = null,Object? dlVerification = null,Object? dlDocumentUrl = freezed,Object? email = freezed,Object? phone = freezed,Object? avatarUrl = freezed,Object? transporterId = freezed,Object? currentAssignmentId = freezed,Object? permissions = null,}) {
  return _then(_DriverProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,dlNumber: null == dlNumber ? _self.dlNumber : dlNumber // ignore: cast_nullable_to_non_nullable
as String,licenseClass: null == licenseClass ? _self.licenseClass : licenseClass // ignore: cast_nullable_to_non_nullable
as LicenseClass,experienceByVehicle: null == experienceByVehicle ? _self._experienceByVehicle : experienceByVehicle // ignore: cast_nullable_to_non_nullable
as Map<VehicleCategory, int>,dlVerification: null == dlVerification ? _self.dlVerification : dlVerification // ignore: cast_nullable_to_non_nullable
as VerificationStatus,dlDocumentUrl: freezed == dlDocumentUrl ? _self.dlDocumentUrl : dlDocumentUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,transporterId: freezed == transporterId ? _self.transporterId : transporterId // ignore: cast_nullable_to_non_nullable
as String?,currentAssignmentId: freezed == currentAssignmentId ? _self.currentAssignmentId : currentAssignmentId // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
