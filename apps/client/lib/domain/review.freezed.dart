// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReviewEvent {

 ReviewEventId get id; StudyCardId get cardId; ReviewEventKind get kind; DateTime get at; Grade? get grade; Duration? get responseTime; DateTime? get dueBefore; DateTime? get dueAfter; ReviewEventId? get undoneEventId; String get schedulerId; int get schedulerVersion; int get configVersion;
/// Create a copy of ReviewEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewEventCopyWith<ReviewEvent> get copyWith => _$ReviewEventCopyWithImpl<ReviewEvent>(this as ReviewEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ReviewEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.cardId, _this.cardId) || other.cardId == _this.cardId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.at, _this.at) || other.at == _this.at)&&(identical(other.grade, _this.grade) || other.grade == _this.grade)&&(identical(other.responseTime, _this.responseTime) || other.responseTime == _this.responseTime)&&(identical(other.dueBefore, _this.dueBefore) || other.dueBefore == _this.dueBefore)&&(identical(other.dueAfter, _this.dueAfter) || other.dueAfter == _this.dueAfter)&&(identical(other.undoneEventId, _this.undoneEventId) || other.undoneEventId == _this.undoneEventId)&&(identical(other.schedulerId, _this.schedulerId) || other.schedulerId == _this.schedulerId)&&(identical(other.schedulerVersion, _this.schedulerVersion) || other.schedulerVersion == _this.schedulerVersion)&&(identical(other.configVersion, _this.configVersion) || other.configVersion == _this.configVersion));
}


@override
int get hashCode {
  final _this = this as ReviewEvent;
  return Object.hash(runtimeType,_this.id,_this.cardId,_this.kind,_this.at,_this.grade,_this.responseTime,_this.dueBefore,_this.dueAfter,_this.undoneEventId,_this.schedulerId,_this.schedulerVersion,_this.configVersion);
}

@override
String toString() {
  final _this = this as ReviewEvent;
  return 'ReviewEvent(id: ${_this.id}, cardId: ${_this.cardId}, kind: ${_this.kind}, at: ${_this.at}, grade: ${_this.grade}, responseTime: ${_this.responseTime}, dueBefore: ${_this.dueBefore}, dueAfter: ${_this.dueAfter}, undoneEventId: ${_this.undoneEventId}, schedulerId: ${_this.schedulerId}, schedulerVersion: ${_this.schedulerVersion}, configVersion: ${_this.configVersion})';
}


}

/// @nodoc
abstract mixin class $ReviewEventCopyWith<$Res>  {
  factory $ReviewEventCopyWith(ReviewEvent value, $Res Function(ReviewEvent) _then) = _$ReviewEventCopyWithImpl;
@useResult
$Res call({
 ReviewEventId id, StudyCardId cardId, ReviewEventKind kind, DateTime at, Grade? grade, Duration? responseTime, DateTime? dueBefore, DateTime? dueAfter, ReviewEventId? undoneEventId, String schedulerId, int schedulerVersion, int configVersion
});




}
/// @nodoc
class _$ReviewEventCopyWithImpl<$Res>
    implements $ReviewEventCopyWith<$Res> {
  _$ReviewEventCopyWithImpl(this._self, this._then);

  final ReviewEvent _self;
  final $Res Function(ReviewEvent) _then;

/// Create a copy of ReviewEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cardId = null,Object? kind = null,Object? at = null,Object? grade = freezed,Object? responseTime = freezed,Object? dueBefore = freezed,Object? dueAfter = freezed,Object? undoneEventId = freezed,Object? schedulerId = null,Object? schedulerVersion = null,Object? configVersion = null,}) {
  return _then(ReviewEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ReviewEventId,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as StudyCardId,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReviewEventKind,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as Grade?,responseTime: freezed == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as Duration?,dueBefore: freezed == dueBefore ? _self.dueBefore : dueBefore // ignore: cast_nullable_to_non_nullable
as DateTime?,dueAfter: freezed == dueAfter ? _self.dueAfter : dueAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,undoneEventId: freezed == undoneEventId ? _self.undoneEventId : undoneEventId // ignore: cast_nullable_to_non_nullable
as ReviewEventId?,schedulerId: null == schedulerId ? _self.schedulerId : schedulerId // ignore: cast_nullable_to_non_nullable
as String,schedulerVersion: null == schedulerVersion ? _self.schedulerVersion : schedulerVersion // ignore: cast_nullable_to_non_nullable
as int,configVersion: null == configVersion ? _self.configVersion : configVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewEvent].
extension ReviewEventPatterns on ReviewEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewEvent value)  $default,){
final _that = this;
switch (_that) {
case _ReviewEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewEvent value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReviewEventId id,  StudyCardId cardId,  ReviewEventKind kind,  DateTime at,  Grade? grade,  Duration? responseTime,  DateTime? dueBefore,  DateTime? dueAfter,  ReviewEventId? undoneEventId,  String schedulerId,  int schedulerVersion,  int configVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewEvent() when $default != null:
return $default(_that.id,_that.cardId,_that.kind,_that.at,_that.grade,_that.responseTime,_that.dueBefore,_that.dueAfter,_that.undoneEventId,_that.schedulerId,_that.schedulerVersion,_that.configVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReviewEventId id,  StudyCardId cardId,  ReviewEventKind kind,  DateTime at,  Grade? grade,  Duration? responseTime,  DateTime? dueBefore,  DateTime? dueAfter,  ReviewEventId? undoneEventId,  String schedulerId,  int schedulerVersion,  int configVersion)  $default,) {final _that = this;
switch (_that) {
case _ReviewEvent():
return $default(_that.id,_that.cardId,_that.kind,_that.at,_that.grade,_that.responseTime,_that.dueBefore,_that.dueAfter,_that.undoneEventId,_that.schedulerId,_that.schedulerVersion,_that.configVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReviewEventId id,  StudyCardId cardId,  ReviewEventKind kind,  DateTime at,  Grade? grade,  Duration? responseTime,  DateTime? dueBefore,  DateTime? dueAfter,  ReviewEventId? undoneEventId,  String schedulerId,  int schedulerVersion,  int configVersion)?  $default,) {final _that = this;
switch (_that) {
case _ReviewEvent() when $default != null:
return $default(_that.id,_that.cardId,_that.kind,_that.at,_that.grade,_that.responseTime,_that.dueBefore,_that.dueAfter,_that.undoneEventId,_that.schedulerId,_that.schedulerVersion,_that.configVersion);case _:
  return null;

}
}

}

/// @nodoc


class _ReviewEvent extends ReviewEvent {
   _ReviewEvent({required this.id, required this.cardId, required this.kind, required this.at, this.grade, this.responseTime, this.dueBefore, this.dueAfter, this.undoneEventId, required this.schedulerId, required this.schedulerVersion, required this.configVersion}): super._();
  

@override final  ReviewEventId id;
@override final  StudyCardId cardId;
@override final  ReviewEventKind kind;
@override final  DateTime at;
@override final  Grade? grade;
@override final  Duration? responseTime;
@override final  DateTime? dueBefore;
@override final  DateTime? dueAfter;
@override final  ReviewEventId? undoneEventId;
@override final  String schedulerId;
@override final  int schedulerVersion;
@override final  int configVersion;

/// Create a copy of ReviewEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewEventCopyWith<_ReviewEvent> get copyWith => __$ReviewEventCopyWithImpl<_ReviewEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.at, at) || other.at == at)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.responseTime, responseTime) || other.responseTime == responseTime)&&(identical(other.dueBefore, dueBefore) || other.dueBefore == dueBefore)&&(identical(other.dueAfter, dueAfter) || other.dueAfter == dueAfter)&&(identical(other.undoneEventId, undoneEventId) || other.undoneEventId == undoneEventId)&&(identical(other.schedulerId, schedulerId) || other.schedulerId == schedulerId)&&(identical(other.schedulerVersion, schedulerVersion) || other.schedulerVersion == schedulerVersion)&&(identical(other.configVersion, configVersion) || other.configVersion == configVersion));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,cardId,kind,at,grade,responseTime,dueBefore,dueAfter,undoneEventId,schedulerId,schedulerVersion,configVersion);
}

@override
String toString() {
    return 'ReviewEvent(id: $id, cardId: $cardId, kind: $kind, at: $at, grade: $grade, responseTime: $responseTime, dueBefore: $dueBefore, dueAfter: $dueAfter, undoneEventId: $undoneEventId, schedulerId: $schedulerId, schedulerVersion: $schedulerVersion, configVersion: $configVersion)';
}


}

/// @nodoc
abstract mixin class _$ReviewEventCopyWith<$Res> implements $ReviewEventCopyWith<$Res> {
  factory _$ReviewEventCopyWith(_ReviewEvent value, $Res Function(_ReviewEvent) _then) = __$ReviewEventCopyWithImpl;
@override @useResult
$Res call({
 ReviewEventId id, StudyCardId cardId, ReviewEventKind kind, DateTime at, Grade? grade, Duration? responseTime, DateTime? dueBefore, DateTime? dueAfter, ReviewEventId? undoneEventId, String schedulerId, int schedulerVersion, int configVersion
});




}
/// @nodoc
class __$ReviewEventCopyWithImpl<$Res>
    implements _$ReviewEventCopyWith<$Res> {
  __$ReviewEventCopyWithImpl(this._self, this._then);

  final _ReviewEvent _self;
  final $Res Function(_ReviewEvent) _then;

/// Create a copy of ReviewEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cardId = null,Object? kind = null,Object? at = null,Object? grade = freezed,Object? responseTime = freezed,Object? dueBefore = freezed,Object? dueAfter = freezed,Object? undoneEventId = freezed,Object? schedulerId = null,Object? schedulerVersion = null,Object? configVersion = null,}) {
  return _then(_ReviewEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ReviewEventId,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as StudyCardId,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReviewEventKind,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime,grade: freezed == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as Grade?,responseTime: freezed == responseTime ? _self.responseTime : responseTime // ignore: cast_nullable_to_non_nullable
as Duration?,dueBefore: freezed == dueBefore ? _self.dueBefore : dueBefore // ignore: cast_nullable_to_non_nullable
as DateTime?,dueAfter: freezed == dueAfter ? _self.dueAfter : dueAfter // ignore: cast_nullable_to_non_nullable
as DateTime?,undoneEventId: freezed == undoneEventId ? _self.undoneEventId : undoneEventId // ignore: cast_nullable_to_non_nullable
as ReviewEventId?,schedulerId: null == schedulerId ? _self.schedulerId : schedulerId // ignore: cast_nullable_to_non_nullable
as String,schedulerVersion: null == schedulerVersion ? _self.schedulerVersion : schedulerVersion // ignore: cast_nullable_to_non_nullable
as int,configVersion: null == configVersion ? _self.configVersion : configVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SchedulingState {

 StudyCardId get cardId; StudyCardState get state;/// Null for new and burned cards.
 DateTime? get due; Duration get interval;/// SM-2-style ease multiplier; null until the card graduates.
 double? get ease;/// Index into the learning or relearning steps.
 int get step; int get lapses; int get reviewCount;/// The last event this state was computed from, or null for a new card.
 ReviewEventId? get lastEventId;
/// Create a copy of SchedulingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchedulingStateCopyWith<SchedulingState> get copyWith => _$SchedulingStateCopyWithImpl<SchedulingState>(this as SchedulingState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SchedulingState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchedulingState&&(identical(other.cardId, _this.cardId) || other.cardId == _this.cardId)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.due, _this.due) || other.due == _this.due)&&(identical(other.interval, _this.interval) || other.interval == _this.interval)&&(identical(other.ease, _this.ease) || other.ease == _this.ease)&&(identical(other.step, _this.step) || other.step == _this.step)&&(identical(other.lapses, _this.lapses) || other.lapses == _this.lapses)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount)&&(identical(other.lastEventId, _this.lastEventId) || other.lastEventId == _this.lastEventId));
}


@override
int get hashCode {
  final _this = this as SchedulingState;
  return Object.hash(runtimeType,_this.cardId,_this.state,_this.due,_this.interval,_this.ease,_this.step,_this.lapses,_this.reviewCount,_this.lastEventId);
}

@override
String toString() {
  final _this = this as SchedulingState;
  return 'SchedulingState(cardId: ${_this.cardId}, state: ${_this.state}, due: ${_this.due}, interval: ${_this.interval}, ease: ${_this.ease}, step: ${_this.step}, lapses: ${_this.lapses}, reviewCount: ${_this.reviewCount}, lastEventId: ${_this.lastEventId})';
}


}

/// @nodoc
abstract mixin class $SchedulingStateCopyWith<$Res>  {
  factory $SchedulingStateCopyWith(SchedulingState value, $Res Function(SchedulingState) _then) = _$SchedulingStateCopyWithImpl;
@useResult
$Res call({
 StudyCardId cardId, StudyCardState state, DateTime? due, Duration interval, double? ease, int step, int lapses, int reviewCount, ReviewEventId? lastEventId
});




}
/// @nodoc
class _$SchedulingStateCopyWithImpl<$Res>
    implements $SchedulingStateCopyWith<$Res> {
  _$SchedulingStateCopyWithImpl(this._self, this._then);

  final SchedulingState _self;
  final $Res Function(SchedulingState) _then;

/// Create a copy of SchedulingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cardId = null,Object? state = null,Object? due = freezed,Object? interval = null,Object? ease = freezed,Object? step = null,Object? lapses = null,Object? reviewCount = null,Object? lastEventId = freezed,}) {
  return _then(SchedulingState(
cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as StudyCardId,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as StudyCardState,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as Duration,ease: freezed == ease ? _self.ease : ease // ignore: cast_nullable_to_non_nullable
as double?,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,lastEventId: freezed == lastEventId ? _self.lastEventId : lastEventId // ignore: cast_nullable_to_non_nullable
as ReviewEventId?,
  ));
}

}


/// Adds pattern-matching-related methods to [SchedulingState].
extension SchedulingStatePatterns on SchedulingState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchedulingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchedulingState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchedulingState value)  $default,){
final _that = this;
switch (_that) {
case _SchedulingState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchedulingState value)?  $default,){
final _that = this;
switch (_that) {
case _SchedulingState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StudyCardId cardId,  StudyCardState state,  DateTime? due,  Duration interval,  double? ease,  int step,  int lapses,  int reviewCount,  ReviewEventId? lastEventId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchedulingState() when $default != null:
return $default(_that.cardId,_that.state,_that.due,_that.interval,_that.ease,_that.step,_that.lapses,_that.reviewCount,_that.lastEventId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StudyCardId cardId,  StudyCardState state,  DateTime? due,  Duration interval,  double? ease,  int step,  int lapses,  int reviewCount,  ReviewEventId? lastEventId)  $default,) {final _that = this;
switch (_that) {
case _SchedulingState():
return $default(_that.cardId,_that.state,_that.due,_that.interval,_that.ease,_that.step,_that.lapses,_that.reviewCount,_that.lastEventId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StudyCardId cardId,  StudyCardState state,  DateTime? due,  Duration interval,  double? ease,  int step,  int lapses,  int reviewCount,  ReviewEventId? lastEventId)?  $default,) {final _that = this;
switch (_that) {
case _SchedulingState() when $default != null:
return $default(_that.cardId,_that.state,_that.due,_that.interval,_that.ease,_that.step,_that.lapses,_that.reviewCount,_that.lastEventId);case _:
  return null;

}
}

}

/// @nodoc


class _SchedulingState extends SchedulingState {
   _SchedulingState({required this.cardId, required this.state, this.due, this.interval = Duration.zero, this.ease, this.step = 0, this.lapses = 0, this.reviewCount = 0, this.lastEventId}): super._();
  

@override final  StudyCardId cardId;
@override final  StudyCardState state;
/// Null for new and burned cards.
@override final  DateTime? due;
@override@JsonKey() final  Duration interval;
/// SM-2-style ease multiplier; null until the card graduates.
@override final  double? ease;
/// Index into the learning or relearning steps.
@override@JsonKey() final  int step;
@override@JsonKey() final  int lapses;
@override@JsonKey() final  int reviewCount;
/// The last event this state was computed from, or null for a new card.
@override final  ReviewEventId? lastEventId;

/// Create a copy of SchedulingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchedulingStateCopyWith<_SchedulingState> get copyWith => __$SchedulingStateCopyWithImpl<_SchedulingState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchedulingState&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.state, state) || other.state == state)&&(identical(other.due, due) || other.due == due)&&(identical(other.interval, interval) || other.interval == interval)&&(identical(other.ease, ease) || other.ease == ease)&&(identical(other.step, step) || other.step == step)&&(identical(other.lapses, lapses) || other.lapses == lapses)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.lastEventId, lastEventId) || other.lastEventId == lastEventId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cardId,state,due,interval,ease,step,lapses,reviewCount,lastEventId);
}

@override
String toString() {
    return 'SchedulingState(cardId: $cardId, state: $state, due: $due, interval: $interval, ease: $ease, step: $step, lapses: $lapses, reviewCount: $reviewCount, lastEventId: $lastEventId)';
}


}

/// @nodoc
abstract mixin class _$SchedulingStateCopyWith<$Res> implements $SchedulingStateCopyWith<$Res> {
  factory _$SchedulingStateCopyWith(_SchedulingState value, $Res Function(_SchedulingState) _then) = __$SchedulingStateCopyWithImpl;
@override @useResult
$Res call({
 StudyCardId cardId, StudyCardState state, DateTime? due, Duration interval, double? ease, int step, int lapses, int reviewCount, ReviewEventId? lastEventId
});




}
/// @nodoc
class __$SchedulingStateCopyWithImpl<$Res>
    implements _$SchedulingStateCopyWith<$Res> {
  __$SchedulingStateCopyWithImpl(this._self, this._then);

  final _SchedulingState _self;
  final $Res Function(_SchedulingState) _then;

/// Create a copy of SchedulingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cardId = null,Object? state = null,Object? due = freezed,Object? interval = null,Object? ease = freezed,Object? step = null,Object? lapses = null,Object? reviewCount = null,Object? lastEventId = freezed,}) {
  return _then(_SchedulingState(
cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as StudyCardId,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as StudyCardState,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as Duration,ease: freezed == ease ? _self.ease : ease // ignore: cast_nullable_to_non_nullable
as double?,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,lastEventId: freezed == lastEventId ? _self.lastEventId : lastEventId // ignore: cast_nullable_to_non_nullable
as ReviewEventId?,
  ));
}


}

// dart format on
