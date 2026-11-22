// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inspection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Inspection {

 String get id; InspectionKind get kind; String get vehicleNumber; InspectionStatus get status; DateTime? get submittedAt; String? get templateId; Map<String, String> get answers; List<String> get photoPaths; String? get capturedLocation;
/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InspectionCopyWith<Inspection> get copyWith => _$InspectionCopyWithImpl<Inspection>(this as Inspection, _$identity);

  /// Serializes this Inspection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Inspection;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Inspection&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.vehicleNumber, _this.vehicleNumber) || other.vehicleNumber == _this.vehicleNumber)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.submittedAt, _this.submittedAt) || other.submittedAt == _this.submittedAt)&&(identical(other.templateId, _this.templateId) || other.templateId == _this.templateId)&&const DeepCollectionEquality().equals(other.answers, _this.answers)&&const DeepCollectionEquality().equals(other.photoPaths, _this.photoPaths)&&(identical(other.capturedLocation, _this.capturedLocation) || other.capturedLocation == _this.capturedLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Inspection;
  return Object.hash(runtimeType,_this.id,_this.kind,_this.vehicleNumber,_this.status,_this.submittedAt,_this.templateId,const DeepCollectionEquality().hash(_this.answers),const DeepCollectionEquality().hash(_this.photoPaths),_this.capturedLocation);
}

@override
String toString() {
  final _this = this as Inspection;
  return 'Inspection(id: ${_this.id}, kind: ${_this.kind}, vehicleNumber: ${_this.vehicleNumber}, status: ${_this.status}, submittedAt: ${_this.submittedAt}, templateId: ${_this.templateId}, answers: ${_this.answers}, photoPaths: ${_this.photoPaths}, capturedLocation: ${_this.capturedLocation})';
}


}

/// @nodoc
abstract mixin class $InspectionCopyWith<$Res>  {
  factory $InspectionCopyWith(Inspection value, $Res Function(Inspection) _then) = _$InspectionCopyWithImpl;
@useResult
$Res call({
 String id, InspectionKind kind, String vehicleNumber, InspectionStatus status, DateTime? submittedAt, String? templateId, Map<String, String> answers, List<String> photoPaths, String? capturedLocation
});




}
/// @nodoc
class _$InspectionCopyWithImpl<$Res>
    implements $InspectionCopyWith<$Res> {
  _$InspectionCopyWithImpl(this._self, this._then);

  final Inspection _self;
  final $Res Function(Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? kind = null,Object? vehicleNumber = null,Object? status = null,Object? submittedAt = freezed,Object? templateId = freezed,Object? answers = null,Object? photoPaths = null,Object? capturedLocation = freezed,}) {
  return _then(Inspection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InspectionKind,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,answers: null == answers ? _self.answers : answers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,photoPaths: null == photoPaths ? _self.photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,capturedLocation: freezed == capturedLocation ? _self.capturedLocation : capturedLocation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Inspection].
extension InspectionPatterns on Inspection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Inspection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Inspection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Inspection value)  $default,){
final _that = this;
switch (_that) {
case _Inspection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Inspection value)?  $default,){
final _that = this;
switch (_that) {
case _Inspection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  InspectionKind kind,  String vehicleNumber,  InspectionStatus status,  DateTime? submittedAt,  String? templateId,  Map<String, String> answers,  List<String> photoPaths,  String? capturedLocation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.kind,_that.vehicleNumber,_that.status,_that.submittedAt,_that.templateId,_that.answers,_that.photoPaths,_that.capturedLocation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  InspectionKind kind,  String vehicleNumber,  InspectionStatus status,  DateTime? submittedAt,  String? templateId,  Map<String, String> answers,  List<String> photoPaths,  String? capturedLocation)  $default,) {final _that = this;
switch (_that) {
case _Inspection():
return $default(_that.id,_that.kind,_that.vehicleNumber,_that.status,_that.submittedAt,_that.templateId,_that.answers,_that.photoPaths,_that.capturedLocation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  InspectionKind kind,  String vehicleNumber,  InspectionStatus status,  DateTime? submittedAt,  String? templateId,  Map<String, String> answers,  List<String> photoPaths,  String? capturedLocation)?  $default,) {final _that = this;
switch (_that) {
case _Inspection() when $default != null:
return $default(_that.id,_that.kind,_that.vehicleNumber,_that.status,_that.submittedAt,_that.templateId,_that.answers,_that.photoPaths,_that.capturedLocation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Inspection implements Inspection {
  const _Inspection({required this.id, required this.kind, required this.vehicleNumber, required this.status, this.submittedAt, this.templateId,  Map<String, String> answers = const <String, String>{},  List<String> photoPaths = const <String>[], this.capturedLocation}): _answers = answers,_photoPaths = photoPaths;
  factory _Inspection.fromJson(Map<String, dynamic> json) => _$InspectionFromJson(json);

@override final  String id;
@override final  InspectionKind kind;
@override final  String vehicleNumber;
@override final  InspectionStatus status;
@override final  DateTime? submittedAt;
@override final  String? templateId;
 final  Map<String, String> _answers;
@override@JsonKey() Map<String, String> get answers {
  if (_answers is EqualUnmodifiableMapView) return _answers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_answers);
}

 final  List<String> _photoPaths;
@override@JsonKey() List<String> get photoPaths {
  if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoPaths);
}

@override final  String? capturedLocation;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InspectionCopyWith<_Inspection> get copyWith => __$InspectionCopyWithImpl<_Inspection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InspectionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Inspection&&(identical(other.id, id) || other.id == id)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&const DeepCollectionEquality().equals(other.answers, _answers)&&const DeepCollectionEquality().equals(other.photoPaths, _photoPaths)&&(identical(other.capturedLocation, capturedLocation) || other.capturedLocation == capturedLocation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,kind,vehicleNumber,status,submittedAt,templateId,const DeepCollectionEquality().hash(_answers),const DeepCollectionEquality().hash(_photoPaths),capturedLocation);
}

@override
String toString() {
    return 'Inspection(id: $id, kind: $kind, vehicleNumber: $vehicleNumber, status: $status, submittedAt: $submittedAt, templateId: $templateId, answers: $answers, photoPaths: $photoPaths, capturedLocation: $capturedLocation)';
}


}

/// @nodoc
abstract mixin class _$InspectionCopyWith<$Res> implements $InspectionCopyWith<$Res> {
  factory _$InspectionCopyWith(_Inspection value, $Res Function(_Inspection) _then) = __$InspectionCopyWithImpl;
@override @useResult
$Res call({
 String id, InspectionKind kind, String vehicleNumber, InspectionStatus status, DateTime? submittedAt, String? templateId, Map<String, String> answers, List<String> photoPaths, String? capturedLocation
});




}
/// @nodoc
class __$InspectionCopyWithImpl<$Res>
    implements _$InspectionCopyWith<$Res> {
  __$InspectionCopyWithImpl(this._self, this._then);

  final _Inspection _self;
  final $Res Function(_Inspection) _then;

/// Create a copy of Inspection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? kind = null,Object? vehicleNumber = null,Object? status = null,Object? submittedAt = freezed,Object? templateId = freezed,Object? answers = null,Object? photoPaths = null,Object? capturedLocation = freezed,}) {
  return _then(_Inspection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as InspectionKind,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InspectionStatus,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,templateId: freezed == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String?,answers: null == answers ? _self._answers : answers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,photoPaths: null == photoPaths ? _self._photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,capturedLocation: freezed == capturedLocation ? _self.capturedLocation : capturedLocation // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
