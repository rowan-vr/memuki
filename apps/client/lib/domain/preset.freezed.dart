// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Preset {

 PresetId get id; CollectionId get collectionId; String get name; PresetVersion get version;
/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetCopyWith<Preset> get copyWith => _$PresetCopyWithImpl<Preset>(this as Preset, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Preset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Preset&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.version, _this.version) || other.version == _this.version));
}


@override
int get hashCode {
  final _this = this as Preset;
  return Object.hash(runtimeType,_this.id,_this.collectionId,_this.name,_this.version);
}

@override
String toString() {
  final _this = this as Preset;
  return 'Preset(id: ${_this.id}, collectionId: ${_this.collectionId}, name: ${_this.name}, version: ${_this.version})';
}


}

/// @nodoc
abstract mixin class $PresetCopyWith<$Res>  {
  factory $PresetCopyWith(Preset value, $Res Function(Preset) _then) = _$PresetCopyWithImpl;
@useResult
$Res call({
 PresetId id, CollectionId collectionId, String name, PresetVersion version
});


$PresetVersionCopyWith<$Res> get version;

}
/// @nodoc
class _$PresetCopyWithImpl<$Res>
    implements $PresetCopyWith<$Res> {
  _$PresetCopyWithImpl(this._self, this._then);

  final Preset _self;
  final $Res Function(Preset) _then;

/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? collectionId = null,Object? name = null,Object? version = null,}) {
  return _then(Preset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PresetId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as PresetVersion,
  ));
}
/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresetVersionCopyWith<$Res> get version {
  
  return $PresetVersionCopyWith<$Res>(_self.version, (value) {
    return _then(_self.copyWith(version: value));
  });
}
}


/// Adds pattern-matching-related methods to [Preset].
extension PresetPatterns on Preset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Preset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Preset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Preset value)  $default,){
final _that = this;
switch (_that) {
case _Preset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Preset value)?  $default,){
final _that = this;
switch (_that) {
case _Preset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PresetId id,  CollectionId collectionId,  String name,  PresetVersion version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Preset() when $default != null:
return $default(_that.id,_that.collectionId,_that.name,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PresetId id,  CollectionId collectionId,  String name,  PresetVersion version)  $default,) {final _that = this;
switch (_that) {
case _Preset():
return $default(_that.id,_that.collectionId,_that.name,_that.version);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PresetId id,  CollectionId collectionId,  String name,  PresetVersion version)?  $default,) {final _that = this;
switch (_that) {
case _Preset() when $default != null:
return $default(_that.id,_that.collectionId,_that.name,_that.version);case _:
  return null;

}
}

}

/// @nodoc


class _Preset extends Preset {
   _Preset({required this.id, required this.collectionId, required this.name, required this.version}): super._();
  

@override final  PresetId id;
@override final  CollectionId collectionId;
@override final  String name;
@override final  PresetVersion version;

/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetCopyWith<_Preset> get copyWith => __$PresetCopyWithImpl<_Preset>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Preset&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,collectionId,name,version);
}

@override
String toString() {
    return 'Preset(id: $id, collectionId: $collectionId, name: $name, version: $version)';
}


}

/// @nodoc
abstract mixin class _$PresetCopyWith<$Res> implements $PresetCopyWith<$Res> {
  factory _$PresetCopyWith(_Preset value, $Res Function(_Preset) _then) = __$PresetCopyWithImpl;
@override @useResult
$Res call({
 PresetId id, CollectionId collectionId, String name, PresetVersion version
});


@override $PresetVersionCopyWith<$Res> get version;

}
/// @nodoc
class __$PresetCopyWithImpl<$Res>
    implements _$PresetCopyWith<$Res> {
  __$PresetCopyWithImpl(this._self, this._then);

  final _Preset _self;
  final $Res Function(_Preset) _then;

/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? collectionId = null,Object? name = null,Object? version = null,}) {
  return _then(_Preset(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PresetId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as PresetVersion,
  ));
}

/// Create a copy of Preset
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresetVersionCopyWith<$Res> get version {
  
  return $PresetVersionCopyWith<$Res>(_self.version, (value) {
    return _then(_self.copyWith(version: value));
  });
}
}

/// @nodoc
mixin _$PresetVersion {

 PresetVersionId get id; String get schedulerId;/// The scheduler's own settings, decoded by the scheduler.
 Map<String, Object?> get schedulerConfig;/// Graduated cards whose next interval reaches this are burned. Null
/// disables burning.
 Duration? get burnThreshold;/// Lapses at which a card becomes a leech. Null disables leeches.
 int? get leechThreshold; int get newCardsPerDay; int get reviewsPerDay;
/// Create a copy of PresetVersion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetVersionCopyWith<PresetVersion> get copyWith => _$PresetVersionCopyWithImpl<PresetVersion>(this as PresetVersion, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PresetVersion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresetVersion&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.schedulerId, _this.schedulerId) || other.schedulerId == _this.schedulerId)&&const DeepCollectionEquality().equals(other.schedulerConfig, _this.schedulerConfig)&&(identical(other.burnThreshold, _this.burnThreshold) || other.burnThreshold == _this.burnThreshold)&&(identical(other.leechThreshold, _this.leechThreshold) || other.leechThreshold == _this.leechThreshold)&&(identical(other.newCardsPerDay, _this.newCardsPerDay) || other.newCardsPerDay == _this.newCardsPerDay)&&(identical(other.reviewsPerDay, _this.reviewsPerDay) || other.reviewsPerDay == _this.reviewsPerDay));
}


@override
int get hashCode {
  final _this = this as PresetVersion;
  return Object.hash(runtimeType,_this.id,_this.schedulerId,const DeepCollectionEquality().hash(_this.schedulerConfig),_this.burnThreshold,_this.leechThreshold,_this.newCardsPerDay,_this.reviewsPerDay);
}

@override
String toString() {
  final _this = this as PresetVersion;
  return 'PresetVersion(id: ${_this.id}, schedulerId: ${_this.schedulerId}, schedulerConfig: ${_this.schedulerConfig}, burnThreshold: ${_this.burnThreshold}, leechThreshold: ${_this.leechThreshold}, newCardsPerDay: ${_this.newCardsPerDay}, reviewsPerDay: ${_this.reviewsPerDay})';
}


}

/// @nodoc
abstract mixin class $PresetVersionCopyWith<$Res>  {
  factory $PresetVersionCopyWith(PresetVersion value, $Res Function(PresetVersion) _then) = _$PresetVersionCopyWithImpl;
@useResult
$Res call({
 PresetVersionId id, String schedulerId, Map<String, Object?> schedulerConfig, Duration? burnThreshold, int? leechThreshold, int newCardsPerDay, int reviewsPerDay
});




}
/// @nodoc
class _$PresetVersionCopyWithImpl<$Res>
    implements $PresetVersionCopyWith<$Res> {
  _$PresetVersionCopyWithImpl(this._self, this._then);

  final PresetVersion _self;
  final $Res Function(PresetVersion) _then;

/// Create a copy of PresetVersion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? schedulerId = null,Object? schedulerConfig = null,Object? burnThreshold = freezed,Object? leechThreshold = freezed,Object? newCardsPerDay = null,Object? reviewsPerDay = null,}) {
  return _then(PresetVersion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PresetVersionId,schedulerId: null == schedulerId ? _self.schedulerId : schedulerId // ignore: cast_nullable_to_non_nullable
as String,schedulerConfig: null == schedulerConfig ? _self.schedulerConfig : schedulerConfig // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,burnThreshold: freezed == burnThreshold ? _self.burnThreshold : burnThreshold // ignore: cast_nullable_to_non_nullable
as Duration?,leechThreshold: freezed == leechThreshold ? _self.leechThreshold : leechThreshold // ignore: cast_nullable_to_non_nullable
as int?,newCardsPerDay: null == newCardsPerDay ? _self.newCardsPerDay : newCardsPerDay // ignore: cast_nullable_to_non_nullable
as int,reviewsPerDay: null == reviewsPerDay ? _self.reviewsPerDay : reviewsPerDay // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PresetVersion].
extension PresetVersionPatterns on PresetVersion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresetVersion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresetVersion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresetVersion value)  $default,){
final _that = this;
switch (_that) {
case _PresetVersion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresetVersion value)?  $default,){
final _that = this;
switch (_that) {
case _PresetVersion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PresetVersionId id,  String schedulerId,  Map<String, Object?> schedulerConfig,  Duration? burnThreshold,  int? leechThreshold,  int newCardsPerDay,  int reviewsPerDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresetVersion() when $default != null:
return $default(_that.id,_that.schedulerId,_that.schedulerConfig,_that.burnThreshold,_that.leechThreshold,_that.newCardsPerDay,_that.reviewsPerDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PresetVersionId id,  String schedulerId,  Map<String, Object?> schedulerConfig,  Duration? burnThreshold,  int? leechThreshold,  int newCardsPerDay,  int reviewsPerDay)  $default,) {final _that = this;
switch (_that) {
case _PresetVersion():
return $default(_that.id,_that.schedulerId,_that.schedulerConfig,_that.burnThreshold,_that.leechThreshold,_that.newCardsPerDay,_that.reviewsPerDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PresetVersionId id,  String schedulerId,  Map<String, Object?> schedulerConfig,  Duration? burnThreshold,  int? leechThreshold,  int newCardsPerDay,  int reviewsPerDay)?  $default,) {final _that = this;
switch (_that) {
case _PresetVersion() when $default != null:
return $default(_that.id,_that.schedulerId,_that.schedulerConfig,_that.burnThreshold,_that.leechThreshold,_that.newCardsPerDay,_that.reviewsPerDay);case _:
  return null;

}
}

}

/// @nodoc


class _PresetVersion extends PresetVersion {
   _PresetVersion({required this.id, this.schedulerId = 'memuki.steps-sm2',  Map<String, Object?> schedulerConfig = const <String, Object?>{}, this.burnThreshold = const Duration(days: 365), this.leechThreshold = 8, this.newCardsPerDay = 50, this.reviewsPerDay = 500}): _schedulerConfig = schedulerConfig,super._();
  

@override final  PresetVersionId id;
@override@JsonKey() final  String schedulerId;
/// The scheduler's own settings, decoded by the scheduler.
 final  Map<String, Object?> _schedulerConfig;
/// The scheduler's own settings, decoded by the scheduler.
@override@JsonKey() Map<String, Object?> get schedulerConfig {
  if (_schedulerConfig is EqualUnmodifiableMapView) return _schedulerConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_schedulerConfig);
}

/// Graduated cards whose next interval reaches this are burned. Null
/// disables burning.
@override@JsonKey() final  Duration? burnThreshold;
/// Lapses at which a card becomes a leech. Null disables leeches.
@override@JsonKey() final  int? leechThreshold;
@override@JsonKey() final  int newCardsPerDay;
@override@JsonKey() final  int reviewsPerDay;

/// Create a copy of PresetVersion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetVersionCopyWith<_PresetVersion> get copyWith => __$PresetVersionCopyWithImpl<_PresetVersion>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresetVersion&&(identical(other.id, id) || other.id == id)&&(identical(other.schedulerId, schedulerId) || other.schedulerId == schedulerId)&&const DeepCollectionEquality().equals(other.schedulerConfig, _schedulerConfig)&&(identical(other.burnThreshold, burnThreshold) || other.burnThreshold == burnThreshold)&&(identical(other.leechThreshold, leechThreshold) || other.leechThreshold == leechThreshold)&&(identical(other.newCardsPerDay, newCardsPerDay) || other.newCardsPerDay == newCardsPerDay)&&(identical(other.reviewsPerDay, reviewsPerDay) || other.reviewsPerDay == reviewsPerDay));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,schedulerId,const DeepCollectionEquality().hash(_schedulerConfig),burnThreshold,leechThreshold,newCardsPerDay,reviewsPerDay);
}

@override
String toString() {
    return 'PresetVersion(id: $id, schedulerId: $schedulerId, schedulerConfig: $schedulerConfig, burnThreshold: $burnThreshold, leechThreshold: $leechThreshold, newCardsPerDay: $newCardsPerDay, reviewsPerDay: $reviewsPerDay)';
}


}

/// @nodoc
abstract mixin class _$PresetVersionCopyWith<$Res> implements $PresetVersionCopyWith<$Res> {
  factory _$PresetVersionCopyWith(_PresetVersion value, $Res Function(_PresetVersion) _then) = __$PresetVersionCopyWithImpl;
@override @useResult
$Res call({
 PresetVersionId id, String schedulerId, Map<String, Object?> schedulerConfig, Duration? burnThreshold, int? leechThreshold, int newCardsPerDay, int reviewsPerDay
});




}
/// @nodoc
class __$PresetVersionCopyWithImpl<$Res>
    implements _$PresetVersionCopyWith<$Res> {
  __$PresetVersionCopyWithImpl(this._self, this._then);

  final _PresetVersion _self;
  final $Res Function(_PresetVersion) _then;

/// Create a copy of PresetVersion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? schedulerId = null,Object? schedulerConfig = null,Object? burnThreshold = freezed,Object? leechThreshold = freezed,Object? newCardsPerDay = null,Object? reviewsPerDay = null,}) {
  return _then(_PresetVersion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PresetVersionId,schedulerId: null == schedulerId ? _self.schedulerId : schedulerId // ignore: cast_nullable_to_non_nullable
as String,schedulerConfig: null == schedulerConfig ? _self._schedulerConfig : schedulerConfig // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,burnThreshold: freezed == burnThreshold ? _self.burnThreshold : burnThreshold // ignore: cast_nullable_to_non_nullable
as Duration?,leechThreshold: freezed == leechThreshold ? _self.leechThreshold : leechThreshold // ignore: cast_nullable_to_non_nullable
as int?,newCardsPerDay: null == newCardsPerDay ? _self.newCardsPerDay : newCardsPerDay // ignore: cast_nullable_to_non_nullable
as int,reviewsPerDay: null == reviewsPerDay ? _self.reviewsPerDay : reviewsPerDay // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
