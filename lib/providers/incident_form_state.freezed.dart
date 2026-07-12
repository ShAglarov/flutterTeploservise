// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'incident_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IncidentFormState {

 int? get id; int? get boilerHouseId; String get title; String get description; IncidentStatus get status; String get severity; bool get stopHotWater; bool get stopHeating; Set<int> get affectedHouseIds; DateTime get createdAt; DateTime? get resolvedAt;/// Время начала инцидента (может быть в будущем для запланированных)
 DateTime? get startedAt;/// Время завершения инцидента (опционально)
 DateTime? get finishedAt;/// Авто-завершение по окончании finishedAt
 bool get autoResolveOnFinish; int? get assignedTo; NotificationConfig? get notificationConfig; bool get isSaving; String? get errorMessage;/// Номера неработающих котлов (напр. {1, 3})
 Set<int> get inactiveBoilers;/// Тумблер "Теплоноситель не поступает полностью" — форсирует статус КРАСНЫЙ
 bool get supplyFullyStopped;
/// Create a copy of IncidentFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IncidentFormStateCopyWith<IncidentFormState> get copyWith => _$IncidentFormStateCopyWithImpl<IncidentFormState>(this as IncidentFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IncidentFormState&&(identical(other.id, id) || other.id == id)&&(identical(other.boilerHouseId, boilerHouseId) || other.boilerHouseId == boilerHouseId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.stopHotWater, stopHotWater) || other.stopHotWater == stopHotWater)&&(identical(other.stopHeating, stopHeating) || other.stopHeating == stopHeating)&&const DeepCollectionEquality().equals(other.affectedHouseIds, affectedHouseIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.autoResolveOnFinish, autoResolveOnFinish) || other.autoResolveOnFinish == autoResolveOnFinish)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.notificationConfig, notificationConfig) || other.notificationConfig == notificationConfig)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.inactiveBoilers, inactiveBoilers)&&(identical(other.supplyFullyStopped, supplyFullyStopped) || other.supplyFullyStopped == supplyFullyStopped));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,boilerHouseId,title,description,status,severity,stopHotWater,stopHeating,const DeepCollectionEquality().hash(affectedHouseIds),createdAt,resolvedAt,startedAt,finishedAt,autoResolveOnFinish,assignedTo,notificationConfig,isSaving,errorMessage,const DeepCollectionEquality().hash(inactiveBoilers),supplyFullyStopped]);

@override
String toString() {
  return 'IncidentFormState(id: $id, boilerHouseId: $boilerHouseId, title: $title, description: $description, status: $status, severity: $severity, stopHotWater: $stopHotWater, stopHeating: $stopHeating, affectedHouseIds: $affectedHouseIds, createdAt: $createdAt, resolvedAt: $resolvedAt, startedAt: $startedAt, finishedAt: $finishedAt, autoResolveOnFinish: $autoResolveOnFinish, assignedTo: $assignedTo, notificationConfig: $notificationConfig, isSaving: $isSaving, errorMessage: $errorMessage, inactiveBoilers: $inactiveBoilers, supplyFullyStopped: $supplyFullyStopped)';
}


}

/// @nodoc
abstract mixin class $IncidentFormStateCopyWith<$Res>  {
  factory $IncidentFormStateCopyWith(IncidentFormState value, $Res Function(IncidentFormState) _then) = _$IncidentFormStateCopyWithImpl;
@useResult
$Res call({
 int? id, int? boilerHouseId, String title, String description, IncidentStatus status, String severity, bool stopHotWater, bool stopHeating, Set<int> affectedHouseIds, DateTime createdAt, DateTime? resolvedAt, DateTime? startedAt, DateTime? finishedAt, bool autoResolveOnFinish, int? assignedTo, NotificationConfig? notificationConfig, bool isSaving, String? errorMessage, Set<int> inactiveBoilers, bool supplyFullyStopped
});




}
/// @nodoc
class _$IncidentFormStateCopyWithImpl<$Res>
    implements $IncidentFormStateCopyWith<$Res> {
  _$IncidentFormStateCopyWithImpl(this._self, this._then);

  final IncidentFormState _self;
  final $Res Function(IncidentFormState) _then;

/// Create a copy of IncidentFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? boilerHouseId = freezed,Object? title = null,Object? description = null,Object? status = null,Object? severity = null,Object? stopHotWater = null,Object? stopHeating = null,Object? affectedHouseIds = null,Object? createdAt = null,Object? resolvedAt = freezed,Object? startedAt = freezed,Object? finishedAt = freezed,Object? autoResolveOnFinish = null,Object? assignedTo = freezed,Object? notificationConfig = freezed,Object? isSaving = null,Object? errorMessage = freezed,Object? inactiveBoilers = null,Object? supplyFullyStopped = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,boilerHouseId: freezed == boilerHouseId ? _self.boilerHouseId : boilerHouseId // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IncidentStatus,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,stopHotWater: null == stopHotWater ? _self.stopHotWater : stopHotWater // ignore: cast_nullable_to_non_nullable
as bool,stopHeating: null == stopHeating ? _self.stopHeating : stopHeating // ignore: cast_nullable_to_non_nullable
as bool,affectedHouseIds: null == affectedHouseIds ? _self.affectedHouseIds : affectedHouseIds // ignore: cast_nullable_to_non_nullable
as Set<int>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,autoResolveOnFinish: null == autoResolveOnFinish ? _self.autoResolveOnFinish : autoResolveOnFinish // ignore: cast_nullable_to_non_nullable
as bool,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as int?,notificationConfig: freezed == notificationConfig ? _self.notificationConfig : notificationConfig // ignore: cast_nullable_to_non_nullable
as NotificationConfig?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,inactiveBoilers: null == inactiveBoilers ? _self.inactiveBoilers : inactiveBoilers // ignore: cast_nullable_to_non_nullable
as Set<int>,supplyFullyStopped: null == supplyFullyStopped ? _self.supplyFullyStopped : supplyFullyStopped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [IncidentFormState].
extension IncidentFormStatePatterns on IncidentFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IncidentFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IncidentFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IncidentFormState value)  $default,){
final _that = this;
switch (_that) {
case _IncidentFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IncidentFormState value)?  $default,){
final _that = this;
switch (_that) {
case _IncidentFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  int? boilerHouseId,  String title,  String description,  IncidentStatus status,  String severity,  bool stopHotWater,  bool stopHeating,  Set<int> affectedHouseIds,  DateTime createdAt,  DateTime? resolvedAt,  DateTime? startedAt,  DateTime? finishedAt,  bool autoResolveOnFinish,  int? assignedTo,  NotificationConfig? notificationConfig,  bool isSaving,  String? errorMessage,  Set<int> inactiveBoilers,  bool supplyFullyStopped)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IncidentFormState() when $default != null:
return $default(_that.id,_that.boilerHouseId,_that.title,_that.description,_that.status,_that.severity,_that.stopHotWater,_that.stopHeating,_that.affectedHouseIds,_that.createdAt,_that.resolvedAt,_that.startedAt,_that.finishedAt,_that.autoResolveOnFinish,_that.assignedTo,_that.notificationConfig,_that.isSaving,_that.errorMessage,_that.inactiveBoilers,_that.supplyFullyStopped);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  int? boilerHouseId,  String title,  String description,  IncidentStatus status,  String severity,  bool stopHotWater,  bool stopHeating,  Set<int> affectedHouseIds,  DateTime createdAt,  DateTime? resolvedAt,  DateTime? startedAt,  DateTime? finishedAt,  bool autoResolveOnFinish,  int? assignedTo,  NotificationConfig? notificationConfig,  bool isSaving,  String? errorMessage,  Set<int> inactiveBoilers,  bool supplyFullyStopped)  $default,) {final _that = this;
switch (_that) {
case _IncidentFormState():
return $default(_that.id,_that.boilerHouseId,_that.title,_that.description,_that.status,_that.severity,_that.stopHotWater,_that.stopHeating,_that.affectedHouseIds,_that.createdAt,_that.resolvedAt,_that.startedAt,_that.finishedAt,_that.autoResolveOnFinish,_that.assignedTo,_that.notificationConfig,_that.isSaving,_that.errorMessage,_that.inactiveBoilers,_that.supplyFullyStopped);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  int? boilerHouseId,  String title,  String description,  IncidentStatus status,  String severity,  bool stopHotWater,  bool stopHeating,  Set<int> affectedHouseIds,  DateTime createdAt,  DateTime? resolvedAt,  DateTime? startedAt,  DateTime? finishedAt,  bool autoResolveOnFinish,  int? assignedTo,  NotificationConfig? notificationConfig,  bool isSaving,  String? errorMessage,  Set<int> inactiveBoilers,  bool supplyFullyStopped)?  $default,) {final _that = this;
switch (_that) {
case _IncidentFormState() when $default != null:
return $default(_that.id,_that.boilerHouseId,_that.title,_that.description,_that.status,_that.severity,_that.stopHotWater,_that.stopHeating,_that.affectedHouseIds,_that.createdAt,_that.resolvedAt,_that.startedAt,_that.finishedAt,_that.autoResolveOnFinish,_that.assignedTo,_that.notificationConfig,_that.isSaving,_that.errorMessage,_that.inactiveBoilers,_that.supplyFullyStopped);case _:
  return null;

}
}

}

/// @nodoc


class _IncidentFormState implements IncidentFormState {
  const _IncidentFormState({required this.id, required this.boilerHouseId, this.title = '', this.description = '', this.status = IncidentStatus.open, this.severity = '1', this.stopHotWater = false, this.stopHeating = false, final  Set<int> affectedHouseIds = const {}, required this.createdAt, this.resolvedAt, this.startedAt, this.finishedAt, this.autoResolveOnFinish = false, this.assignedTo, this.notificationConfig, this.isSaving = false, this.errorMessage, final  Set<int> inactiveBoilers = const {}, this.supplyFullyStopped = false}): _affectedHouseIds = affectedHouseIds,_inactiveBoilers = inactiveBoilers;
  

@override final  int? id;
@override final  int? boilerHouseId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  IncidentStatus status;
@override@JsonKey() final  String severity;
@override@JsonKey() final  bool stopHotWater;
@override@JsonKey() final  bool stopHeating;
 final  Set<int> _affectedHouseIds;
@override@JsonKey() Set<int> get affectedHouseIds {
  if (_affectedHouseIds is EqualUnmodifiableSetView) return _affectedHouseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_affectedHouseIds);
}

@override final  DateTime createdAt;
@override final  DateTime? resolvedAt;
/// Время начала инцидента (может быть в будущем для запланированных)
@override final  DateTime? startedAt;
/// Время завершения инцидента (опционально)
@override final  DateTime? finishedAt;
/// Авто-завершение по окончании finishedAt
@override@JsonKey() final  bool autoResolveOnFinish;
@override final  int? assignedTo;
@override final  NotificationConfig? notificationConfig;
@override@JsonKey() final  bool isSaving;
@override final  String? errorMessage;
/// Номера неработающих котлов (напр. {1, 3})
 final  Set<int> _inactiveBoilers;
/// Номера неработающих котлов (напр. {1, 3})
@override@JsonKey() Set<int> get inactiveBoilers {
  if (_inactiveBoilers is EqualUnmodifiableSetView) return _inactiveBoilers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_inactiveBoilers);
}

/// Тумблер "Теплоноситель не поступает полностью" — форсирует статус КРАСНЫЙ
@override@JsonKey() final  bool supplyFullyStopped;

/// Create a copy of IncidentFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IncidentFormStateCopyWith<_IncidentFormState> get copyWith => __$IncidentFormStateCopyWithImpl<_IncidentFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IncidentFormState&&(identical(other.id, id) || other.id == id)&&(identical(other.boilerHouseId, boilerHouseId) || other.boilerHouseId == boilerHouseId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.stopHotWater, stopHotWater) || other.stopHotWater == stopHotWater)&&(identical(other.stopHeating, stopHeating) || other.stopHeating == stopHeating)&&const DeepCollectionEquality().equals(other._affectedHouseIds, _affectedHouseIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt)&&(identical(other.autoResolveOnFinish, autoResolveOnFinish) || other.autoResolveOnFinish == autoResolveOnFinish)&&(identical(other.assignedTo, assignedTo) || other.assignedTo == assignedTo)&&(identical(other.notificationConfig, notificationConfig) || other.notificationConfig == notificationConfig)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._inactiveBoilers, _inactiveBoilers)&&(identical(other.supplyFullyStopped, supplyFullyStopped) || other.supplyFullyStopped == supplyFullyStopped));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,boilerHouseId,title,description,status,severity,stopHotWater,stopHeating,const DeepCollectionEquality().hash(_affectedHouseIds),createdAt,resolvedAt,startedAt,finishedAt,autoResolveOnFinish,assignedTo,notificationConfig,isSaving,errorMessage,const DeepCollectionEquality().hash(_inactiveBoilers),supplyFullyStopped]);

@override
String toString() {
  return 'IncidentFormState(id: $id, boilerHouseId: $boilerHouseId, title: $title, description: $description, status: $status, severity: $severity, stopHotWater: $stopHotWater, stopHeating: $stopHeating, affectedHouseIds: $affectedHouseIds, createdAt: $createdAt, resolvedAt: $resolvedAt, startedAt: $startedAt, finishedAt: $finishedAt, autoResolveOnFinish: $autoResolveOnFinish, assignedTo: $assignedTo, notificationConfig: $notificationConfig, isSaving: $isSaving, errorMessage: $errorMessage, inactiveBoilers: $inactiveBoilers, supplyFullyStopped: $supplyFullyStopped)';
}


}

/// @nodoc
abstract mixin class _$IncidentFormStateCopyWith<$Res> implements $IncidentFormStateCopyWith<$Res> {
  factory _$IncidentFormStateCopyWith(_IncidentFormState value, $Res Function(_IncidentFormState) _then) = __$IncidentFormStateCopyWithImpl;
@override @useResult
$Res call({
 int? id, int? boilerHouseId, String title, String description, IncidentStatus status, String severity, bool stopHotWater, bool stopHeating, Set<int> affectedHouseIds, DateTime createdAt, DateTime? resolvedAt, DateTime? startedAt, DateTime? finishedAt, bool autoResolveOnFinish, int? assignedTo, NotificationConfig? notificationConfig, bool isSaving, String? errorMessage, Set<int> inactiveBoilers, bool supplyFullyStopped
});




}
/// @nodoc
class __$IncidentFormStateCopyWithImpl<$Res>
    implements _$IncidentFormStateCopyWith<$Res> {
  __$IncidentFormStateCopyWithImpl(this._self, this._then);

  final _IncidentFormState _self;
  final $Res Function(_IncidentFormState) _then;

/// Create a copy of IncidentFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? boilerHouseId = freezed,Object? title = null,Object? description = null,Object? status = null,Object? severity = null,Object? stopHotWater = null,Object? stopHeating = null,Object? affectedHouseIds = null,Object? createdAt = null,Object? resolvedAt = freezed,Object? startedAt = freezed,Object? finishedAt = freezed,Object? autoResolveOnFinish = null,Object? assignedTo = freezed,Object? notificationConfig = freezed,Object? isSaving = null,Object? errorMessage = freezed,Object? inactiveBoilers = null,Object? supplyFullyStopped = null,}) {
  return _then(_IncidentFormState(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,boilerHouseId: freezed == boilerHouseId ? _self.boilerHouseId : boilerHouseId // ignore: cast_nullable_to_non_nullable
as int?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as IncidentStatus,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,stopHotWater: null == stopHotWater ? _self.stopHotWater : stopHotWater // ignore: cast_nullable_to_non_nullable
as bool,stopHeating: null == stopHeating ? _self.stopHeating : stopHeating // ignore: cast_nullable_to_non_nullable
as bool,affectedHouseIds: null == affectedHouseIds ? _self._affectedHouseIds : affectedHouseIds // ignore: cast_nullable_to_non_nullable
as Set<int>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startedAt: freezed == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,autoResolveOnFinish: null == autoResolveOnFinish ? _self.autoResolveOnFinish : autoResolveOnFinish // ignore: cast_nullable_to_non_nullable
as bool,assignedTo: freezed == assignedTo ? _self.assignedTo : assignedTo // ignore: cast_nullable_to_non_nullable
as int?,notificationConfig: freezed == notificationConfig ? _self.notificationConfig : notificationConfig // ignore: cast_nullable_to_non_nullable
as NotificationConfig?,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,inactiveBoilers: null == inactiveBoilers ? _self._inactiveBoilers : inactiveBoilers // ignore: cast_nullable_to_non_nullable
as Set<int>,supplyFullyStopped: null == supplyFullyStopped ? _self.supplyFullyStopped : supplyFullyStopped // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
