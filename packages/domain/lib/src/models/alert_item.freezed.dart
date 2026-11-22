// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlertItem {

 String get id; String get title; String? get body; AlertSeverity get severity; DateTime get createdAt; bool get isRead; String? get tripId; String? get vehicleNumber;
/// Create a copy of AlertItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlertItemCopyWith<AlertItem> get copyWith => _$AlertItemCopyWithImpl<AlertItem>(this as AlertItem, _$identity);

  /// Serializes this AlertItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AlertItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlertItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.severity, _this.severity) || other.severity == _this.severity)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.tripId, _this.tripId) || other.tripId == _this.tripId)&&(identical(other.vehicleNumber, _this.vehicleNumber) || other.vehicleNumber == _this.vehicleNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AlertItem;
  return Object.hash(runtimeType,_this.id,_this.title,_this.body,_this.severity,_this.createdAt,_this.isRead,_this.tripId,_this.vehicleNumber);
}

@override
String toString() {
  final _this = this as AlertItem;
  return 'AlertItem(id: ${_this.id}, title: ${_this.title}, body: ${_this.body}, severity: ${_this.severity}, createdAt: ${_this.createdAt}, isRead: ${_this.isRead}, tripId: ${_this.tripId}, vehicleNumber: ${_this.vehicleNumber})';
}


}

/// @nodoc
abstract mixin class $AlertItemCopyWith<$Res>  {
  factory $AlertItemCopyWith(AlertItem value, $Res Function(AlertItem) _then) = _$AlertItemCopyWithImpl;
@useResult
$Res call({
 String id, String title, String? body, AlertSeverity severity, DateTime createdAt, bool isRead, String? tripId, String? vehicleNumber
});




}
/// @nodoc
class _$AlertItemCopyWithImpl<$Res>
    implements $AlertItemCopyWith<$Res> {
  _$AlertItemCopyWithImpl(this._self, this._then);

  final AlertItem _self;
  final $Res Function(AlertItem) _then;

/// Create a copy of AlertItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = freezed,Object? severity = null,Object? createdAt = null,Object? isRead = null,Object? tripId = freezed,Object? vehicleNumber = freezed,}) {
  return _then(AlertItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AlertSeverity,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AlertItem].
extension AlertItemPatterns on AlertItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlertItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlertItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlertItem value)  $default,){
final _that = this;
switch (_that) {
case _AlertItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlertItem value)?  $default,){
final _that = this;
switch (_that) {
case _AlertItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String? body,  AlertSeverity severity,  DateTime createdAt,  bool isRead,  String? tripId,  String? vehicleNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlertItem() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.severity,_that.createdAt,_that.isRead,_that.tripId,_that.vehicleNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String? body,  AlertSeverity severity,  DateTime createdAt,  bool isRead,  String? tripId,  String? vehicleNumber)  $default,) {final _that = this;
switch (_that) {
case _AlertItem():
return $default(_that.id,_that.title,_that.body,_that.severity,_that.createdAt,_that.isRead,_that.tripId,_that.vehicleNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String? body,  AlertSeverity severity,  DateTime createdAt,  bool isRead,  String? tripId,  String? vehicleNumber)?  $default,) {final _that = this;
switch (_that) {
case _AlertItem() when $default != null:
return $default(_that.id,_that.title,_that.body,_that.severity,_that.createdAt,_that.isRead,_that.tripId,_that.vehicleNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlertItem implements AlertItem {
  const _AlertItem({required this.id, required this.title, this.body, required this.severity, required this.createdAt, this.isRead = false, this.tripId, this.vehicleNumber});
  factory _AlertItem.fromJson(Map<String, dynamic> json) => _$AlertItemFromJson(json);

@override final  String id;
@override final  String title;
@override final  String? body;
@override final  AlertSeverity severity;
@override final  DateTime createdAt;
@override@JsonKey() final  bool isRead;
@override final  String? tripId;
@override final  String? vehicleNumber;

/// Create a copy of AlertItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlertItemCopyWith<_AlertItem> get copyWith => __$AlertItemCopyWithImpl<_AlertItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlertItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlertItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.tripId, tripId) || other.tripId == tripId)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,body,severity,createdAt,isRead,tripId,vehicleNumber);
}

@override
String toString() {
    return 'AlertItem(id: $id, title: $title, body: $body, severity: $severity, createdAt: $createdAt, isRead: $isRead, tripId: $tripId, vehicleNumber: $vehicleNumber)';
}


}

/// @nodoc
abstract mixin class _$AlertItemCopyWith<$Res> implements $AlertItemCopyWith<$Res> {
  factory _$AlertItemCopyWith(_AlertItem value, $Res Function(_AlertItem) _then) = __$AlertItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String? body, AlertSeverity severity, DateTime createdAt, bool isRead, String? tripId, String? vehicleNumber
});




}
/// @nodoc
class __$AlertItemCopyWithImpl<$Res>
    implements _$AlertItemCopyWith<$Res> {
  __$AlertItemCopyWithImpl(this._self, this._then);

  final _AlertItem _self;
  final $Res Function(_AlertItem) _then;

/// Create a copy of AlertItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = freezed,Object? severity = null,Object? createdAt = null,Object? isRead = null,Object? tripId = freezed,Object? vehicleNumber = freezed,}) {
  return _then(_AlertItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AlertSeverity,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,tripId: freezed == tripId ? _self.tripId : tripId // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
