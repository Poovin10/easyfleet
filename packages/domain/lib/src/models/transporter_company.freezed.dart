// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transporter_company.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransporterCompany {

 String get id;/// Globally unique GSTIN — the transporter's primary identity.
 String get gst; String get legalName; String? get tradeName; VerificationStatus get gstVerification; String? get gstDocumentUrl; String? get email; String? get phone; String? get address; List<String> get permissions;
/// Create a copy of TransporterCompany
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransporterCompanyCopyWith<TransporterCompany> get copyWith => _$TransporterCompanyCopyWithImpl<TransporterCompany>(this as TransporterCompany, _$identity);

  /// Serializes this TransporterCompany to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransporterCompany;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransporterCompany&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.gst, _this.gst) || other.gst == _this.gst)&&(identical(other.legalName, _this.legalName) || other.legalName == _this.legalName)&&(identical(other.tradeName, _this.tradeName) || other.tradeName == _this.tradeName)&&(identical(other.gstVerification, _this.gstVerification) || other.gstVerification == _this.gstVerification)&&(identical(other.gstDocumentUrl, _this.gstDocumentUrl) || other.gstDocumentUrl == _this.gstDocumentUrl)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.address, _this.address) || other.address == _this.address)&&const DeepCollectionEquality().equals(other.permissions, _this.permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransporterCompany;
  return Object.hash(runtimeType,_this.id,_this.gst,_this.legalName,_this.tradeName,_this.gstVerification,_this.gstDocumentUrl,_this.email,_this.phone,_this.address,const DeepCollectionEquality().hash(_this.permissions));
}

@override
String toString() {
  final _this = this as TransporterCompany;
  return 'TransporterCompany(id: ${_this.id}, gst: ${_this.gst}, legalName: ${_this.legalName}, tradeName: ${_this.tradeName}, gstVerification: ${_this.gstVerification}, gstDocumentUrl: ${_this.gstDocumentUrl}, email: ${_this.email}, phone: ${_this.phone}, address: ${_this.address}, permissions: ${_this.permissions})';
}


}

/// @nodoc
abstract mixin class $TransporterCompanyCopyWith<$Res>  {
  factory $TransporterCompanyCopyWith(TransporterCompany value, $Res Function(TransporterCompany) _then) = _$TransporterCompanyCopyWithImpl;
@useResult
$Res call({
 String id, String gst, String legalName, String? tradeName, VerificationStatus gstVerification, String? gstDocumentUrl, String? email, String? phone, String? address, List<String> permissions
});




}
/// @nodoc
class _$TransporterCompanyCopyWithImpl<$Res>
    implements $TransporterCompanyCopyWith<$Res> {
  _$TransporterCompanyCopyWithImpl(this._self, this._then);

  final TransporterCompany _self;
  final $Res Function(TransporterCompany) _then;

/// Create a copy of TransporterCompany
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? gst = null,Object? legalName = null,Object? tradeName = freezed,Object? gstVerification = null,Object? gstDocumentUrl = freezed,Object? email = freezed,Object? phone = freezed,Object? address = freezed,Object? permissions = null,}) {
  return _then(TransporterCompany(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gst: null == gst ? _self.gst : gst // ignore: cast_nullable_to_non_nullable
as String,legalName: null == legalName ? _self.legalName : legalName // ignore: cast_nullable_to_non_nullable
as String,tradeName: freezed == tradeName ? _self.tradeName : tradeName // ignore: cast_nullable_to_non_nullable
as String?,gstVerification: null == gstVerification ? _self.gstVerification : gstVerification // ignore: cast_nullable_to_non_nullable
as VerificationStatus,gstDocumentUrl: freezed == gstDocumentUrl ? _self.gstDocumentUrl : gstDocumentUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransporterCompany].
extension TransporterCompanyPatterns on TransporterCompany {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransporterCompany value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransporterCompany() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransporterCompany value)  $default,){
final _that = this;
switch (_that) {
case _TransporterCompany():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransporterCompany value)?  $default,){
final _that = this;
switch (_that) {
case _TransporterCompany() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String gst,  String legalName,  String? tradeName,  VerificationStatus gstVerification,  String? gstDocumentUrl,  String? email,  String? phone,  String? address,  List<String> permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransporterCompany() when $default != null:
return $default(_that.id,_that.gst,_that.legalName,_that.tradeName,_that.gstVerification,_that.gstDocumentUrl,_that.email,_that.phone,_that.address,_that.permissions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String gst,  String legalName,  String? tradeName,  VerificationStatus gstVerification,  String? gstDocumentUrl,  String? email,  String? phone,  String? address,  List<String> permissions)  $default,) {final _that = this;
switch (_that) {
case _TransporterCompany():
return $default(_that.id,_that.gst,_that.legalName,_that.tradeName,_that.gstVerification,_that.gstDocumentUrl,_that.email,_that.phone,_that.address,_that.permissions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String gst,  String legalName,  String? tradeName,  VerificationStatus gstVerification,  String? gstDocumentUrl,  String? email,  String? phone,  String? address,  List<String> permissions)?  $default,) {final _that = this;
switch (_that) {
case _TransporterCompany() when $default != null:
return $default(_that.id,_that.gst,_that.legalName,_that.tradeName,_that.gstVerification,_that.gstDocumentUrl,_that.email,_that.phone,_that.address,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransporterCompany implements TransporterCompany {
  const _TransporterCompany({required this.id, required this.gst, required this.legalName, this.tradeName, required this.gstVerification, this.gstDocumentUrl, this.email, this.phone, this.address,  List<String> permissions = const <String>[]}): _permissions = permissions;
  factory _TransporterCompany.fromJson(Map<String, dynamic> json) => _$TransporterCompanyFromJson(json);

@override final  String id;
/// Globally unique GSTIN — the transporter's primary identity.
@override final  String gst;
@override final  String legalName;
@override final  String? tradeName;
@override final  VerificationStatus gstVerification;
@override final  String? gstDocumentUrl;
@override final  String? email;
@override final  String? phone;
@override final  String? address;
 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}


/// Create a copy of TransporterCompany
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransporterCompanyCopyWith<_TransporterCompany> get copyWith => __$TransporterCompanyCopyWithImpl<_TransporterCompany>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransporterCompanyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransporterCompany&&(identical(other.id, id) || other.id == id)&&(identical(other.gst, gst) || other.gst == gst)&&(identical(other.legalName, legalName) || other.legalName == legalName)&&(identical(other.tradeName, tradeName) || other.tradeName == tradeName)&&(identical(other.gstVerification, gstVerification) || other.gstVerification == gstVerification)&&(identical(other.gstDocumentUrl, gstDocumentUrl) || other.gstDocumentUrl == gstDocumentUrl)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&const DeepCollectionEquality().equals(other.permissions, _permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,gst,legalName,tradeName,gstVerification,gstDocumentUrl,email,phone,address,const DeepCollectionEquality().hash(_permissions));
}

@override
String toString() {
    return 'TransporterCompany(id: $id, gst: $gst, legalName: $legalName, tradeName: $tradeName, gstVerification: $gstVerification, gstDocumentUrl: $gstDocumentUrl, email: $email, phone: $phone, address: $address, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$TransporterCompanyCopyWith<$Res> implements $TransporterCompanyCopyWith<$Res> {
  factory _$TransporterCompanyCopyWith(_TransporterCompany value, $Res Function(_TransporterCompany) _then) = __$TransporterCompanyCopyWithImpl;
@override @useResult
$Res call({
 String id, String gst, String legalName, String? tradeName, VerificationStatus gstVerification, String? gstDocumentUrl, String? email, String? phone, String? address, List<String> permissions
});




}
/// @nodoc
class __$TransporterCompanyCopyWithImpl<$Res>
    implements _$TransporterCompanyCopyWith<$Res> {
  __$TransporterCompanyCopyWithImpl(this._self, this._then);

  final _TransporterCompany _self;
  final $Res Function(_TransporterCompany) _then;

/// Create a copy of TransporterCompany
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? gst = null,Object? legalName = null,Object? tradeName = freezed,Object? gstVerification = null,Object? gstDocumentUrl = freezed,Object? email = freezed,Object? phone = freezed,Object? address = freezed,Object? permissions = null,}) {
  return _then(_TransporterCompany(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,gst: null == gst ? _self.gst : gst // ignore: cast_nullable_to_non_nullable
as String,legalName: null == legalName ? _self.legalName : legalName // ignore: cast_nullable_to_non_nullable
as String,tradeName: freezed == tradeName ? _self.tradeName : tradeName // ignore: cast_nullable_to_non_nullable
as String?,gstVerification: null == gstVerification ? _self.gstVerification : gstVerification // ignore: cast_nullable_to_non_nullable
as VerificationStatus,gstDocumentUrl: freezed == gstDocumentUrl ? _self.gstDocumentUrl : gstDocumentUrl // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
