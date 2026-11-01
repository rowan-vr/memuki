// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FieldDefinition {

 FieldDefinitionId get id; String get name; FieldType get type;/// The language of its values, as a BCP 47 tag such as ja; a `lang`
/// mark overrides it for a span. Null when it is not set.
 String? get language;/// Whether a note must fill it.
 bool get isRequired;/// The kinds of mark its values may hold, or null for all. Marks inside
/// one it allows, such as a list's items, go with it.
 Set<String>? get allowedMarks;
/// Create a copy of FieldDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldDefinitionCopyWith<FieldDefinition> get copyWith => _$FieldDefinitionCopyWithImpl<FieldDefinition>(this as FieldDefinition, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FieldDefinition;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldDefinition&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.language, _this.language) || other.language == _this.language)&&(identical(other.isRequired, _this.isRequired) || other.isRequired == _this.isRequired)&&const DeepCollectionEquality().equals(other.allowedMarks, _this.allowedMarks));
}


@override
int get hashCode {
  final _this = this as FieldDefinition;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.language,_this.isRequired,const DeepCollectionEquality().hash(_this.allowedMarks));
}

@override
String toString() {
  final _this = this as FieldDefinition;
  return 'FieldDefinition(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, language: ${_this.language}, isRequired: ${_this.isRequired}, allowedMarks: ${_this.allowedMarks})';
}


}

/// @nodoc
abstract mixin class $FieldDefinitionCopyWith<$Res>  {
  factory $FieldDefinitionCopyWith(FieldDefinition value, $Res Function(FieldDefinition) _then) = _$FieldDefinitionCopyWithImpl;
@useResult
$Res call({
 FieldDefinitionId id, String name, FieldType type, String? language, bool isRequired, Set<String>? allowedMarks
});




}
/// @nodoc
class _$FieldDefinitionCopyWithImpl<$Res>
    implements $FieldDefinitionCopyWith<$Res> {
  _$FieldDefinitionCopyWithImpl(this._self, this._then);

  final FieldDefinition _self;
  final $Res Function(FieldDefinition) _then;

/// Create a copy of FieldDefinition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? language = freezed,Object? isRequired = null,Object? allowedMarks = freezed,}) {
  return _then(FieldDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as FieldDefinitionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FieldType,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,allowedMarks: freezed == allowedMarks ? _self.allowedMarks : allowedMarks // ignore: cast_nullable_to_non_nullable
as Set<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldDefinition].
extension FieldDefinitionPatterns on FieldDefinition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldDefinition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldDefinition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldDefinition value)  $default,){
final _that = this;
switch (_that) {
case _FieldDefinition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldDefinition value)?  $default,){
final _that = this;
switch (_that) {
case _FieldDefinition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FieldDefinitionId id,  String name,  FieldType type,  String? language,  bool isRequired,  Set<String>? allowedMarks)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldDefinition() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.language,_that.isRequired,_that.allowedMarks);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FieldDefinitionId id,  String name,  FieldType type,  String? language,  bool isRequired,  Set<String>? allowedMarks)  $default,) {final _that = this;
switch (_that) {
case _FieldDefinition():
return $default(_that.id,_that.name,_that.type,_that.language,_that.isRequired,_that.allowedMarks);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FieldDefinitionId id,  String name,  FieldType type,  String? language,  bool isRequired,  Set<String>? allowedMarks)?  $default,) {final _that = this;
switch (_that) {
case _FieldDefinition() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.language,_that.isRequired,_that.allowedMarks);case _:
  return null;

}
}

}

/// @nodoc


class _FieldDefinition extends FieldDefinition {
   _FieldDefinition({required this.id, required this.name, this.type = FieldType.text, this.language, this.isRequired = false,  Set<String>? allowedMarks}): _allowedMarks = allowedMarks,super._();
  

@override final  FieldDefinitionId id;
@override final  String name;
@override@JsonKey() final  FieldType type;
/// The language of its values, as a BCP 47 tag such as ja; a `lang`
/// mark overrides it for a span. Null when it is not set.
@override final  String? language;
/// Whether a note must fill it.
@override@JsonKey() final  bool isRequired;
/// The kinds of mark its values may hold, or null for all. Marks inside
/// one it allows, such as a list's items, go with it.
 final  Set<String>? _allowedMarks;
/// The kinds of mark its values may hold, or null for all. Marks inside
/// one it allows, such as a list's items, go with it.
@override Set<String>? get allowedMarks {
  final value = _allowedMarks;
  if (value == null) return null;
  if (_allowedMarks is EqualUnmodifiableSetView) return _allowedMarks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(value);
}


/// Create a copy of FieldDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldDefinitionCopyWith<_FieldDefinition> get copyWith => __$FieldDefinitionCopyWithImpl<_FieldDefinition>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldDefinition&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.language, language) || other.language == language)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&const DeepCollectionEquality().equals(other.allowedMarks, _allowedMarks));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,language,isRequired,const DeepCollectionEquality().hash(_allowedMarks));
}

@override
String toString() {
    return 'FieldDefinition(id: $id, name: $name, type: $type, language: $language, isRequired: $isRequired, allowedMarks: $allowedMarks)';
}


}

/// @nodoc
abstract mixin class _$FieldDefinitionCopyWith<$Res> implements $FieldDefinitionCopyWith<$Res> {
  factory _$FieldDefinitionCopyWith(_FieldDefinition value, $Res Function(_FieldDefinition) _then) = __$FieldDefinitionCopyWithImpl;
@override @useResult
$Res call({
 FieldDefinitionId id, String name, FieldType type, String? language, bool isRequired, Set<String>? allowedMarks
});




}
/// @nodoc
class __$FieldDefinitionCopyWithImpl<$Res>
    implements _$FieldDefinitionCopyWith<$Res> {
  __$FieldDefinitionCopyWithImpl(this._self, this._then);

  final _FieldDefinition _self;
  final $Res Function(_FieldDefinition) _then;

/// Create a copy of FieldDefinition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? language = freezed,Object? isRequired = null,Object? allowedMarks = freezed,}) {
  return _then(_FieldDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as FieldDefinitionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FieldType,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,allowedMarks: freezed == allowedMarks ? _self._allowedMarks : allowedMarks // ignore: cast_nullable_to_non_nullable
as Set<String>?,
  ));
}


}

/// @nodoc
mixin _$StudyCardTemplate {

 StudyCardTemplateId get id; String get name;/// What the card shows, in the content format: a `front` and a `back`
/// that place the note's fields by name.
 String get source;
/// Create a copy of StudyCardTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudyCardTemplateCopyWith<StudyCardTemplate> get copyWith => _$StudyCardTemplateCopyWithImpl<StudyCardTemplate>(this as StudyCardTemplate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StudyCardTemplate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudyCardTemplate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.source, _this.source) || other.source == _this.source));
}


@override
int get hashCode {
  final _this = this as StudyCardTemplate;
  return Object.hash(runtimeType,_this.id,_this.name,_this.source);
}

@override
String toString() {
  final _this = this as StudyCardTemplate;
  return 'StudyCardTemplate(id: ${_this.id}, name: ${_this.name}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $StudyCardTemplateCopyWith<$Res>  {
  factory $StudyCardTemplateCopyWith(StudyCardTemplate value, $Res Function(StudyCardTemplate) _then) = _$StudyCardTemplateCopyWithImpl;
@useResult
$Res call({
 StudyCardTemplateId id, String name, String source
});




}
/// @nodoc
class _$StudyCardTemplateCopyWithImpl<$Res>
    implements $StudyCardTemplateCopyWith<$Res> {
  _$StudyCardTemplateCopyWithImpl(this._self, this._then);

  final StudyCardTemplate _self;
  final $Res Function(StudyCardTemplate) _then;

/// Create a copy of StudyCardTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? source = null,}) {
  return _then(StudyCardTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as StudyCardTemplateId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [StudyCardTemplate].
extension StudyCardTemplatePatterns on StudyCardTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudyCardTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudyCardTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudyCardTemplate value)  $default,){
final _that = this;
switch (_that) {
case _StudyCardTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudyCardTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _StudyCardTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StudyCardTemplateId id,  String name,  String source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudyCardTemplate() when $default != null:
return $default(_that.id,_that.name,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StudyCardTemplateId id,  String name,  String source)  $default,) {final _that = this;
switch (_that) {
case _StudyCardTemplate():
return $default(_that.id,_that.name,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StudyCardTemplateId id,  String name,  String source)?  $default,) {final _that = this;
switch (_that) {
case _StudyCardTemplate() when $default != null:
return $default(_that.id,_that.name,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _StudyCardTemplate extends StudyCardTemplate {
   _StudyCardTemplate({required this.id, required this.name, this.source = StudyCardTemplate.blank}): super._();
  

@override final  StudyCardTemplateId id;
@override final  String name;
/// What the card shows, in the content format: a `front` and a `back`
/// that place the note's fields by name.
@override@JsonKey() final  String source;

/// Create a copy of StudyCardTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudyCardTemplateCopyWith<_StudyCardTemplate> get copyWith => __$StudyCardTemplateCopyWithImpl<_StudyCardTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudyCardTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,source);
}

@override
String toString() {
    return 'StudyCardTemplate(id: $id, name: $name, source: $source)';
}


}

/// @nodoc
abstract mixin class _$StudyCardTemplateCopyWith<$Res> implements $StudyCardTemplateCopyWith<$Res> {
  factory _$StudyCardTemplateCopyWith(_StudyCardTemplate value, $Res Function(_StudyCardTemplate) _then) = __$StudyCardTemplateCopyWithImpl;
@override @useResult
$Res call({
 StudyCardTemplateId id, String name, String source
});




}
/// @nodoc
class __$StudyCardTemplateCopyWithImpl<$Res>
    implements _$StudyCardTemplateCopyWith<$Res> {
  __$StudyCardTemplateCopyWithImpl(this._self, this._then);

  final _StudyCardTemplate _self;
  final $Res Function(_StudyCardTemplate) _then;

/// Create a copy of StudyCardTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? source = null,}) {
  return _then(_StudyCardTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as StudyCardTemplateId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$NoteType {

 NoteTypeId get id; CollectionId get collectionId; String get name; List<FieldDefinition> get fields; List<StudyCardTemplate> get templates;/// The field whose plain text is compared across notes, to warn of
/// duplicates. Null when none is.
 FieldDefinitionId? get duplicateCheck;
/// Create a copy of NoteType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteTypeCopyWith<NoteType> get copyWith => _$NoteTypeCopyWithImpl<NoteType>(this as NoteType, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NoteType;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteType&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.fields, _this.fields)&&const DeepCollectionEquality().equals(other.templates, _this.templates)&&(identical(other.duplicateCheck, _this.duplicateCheck) || other.duplicateCheck == _this.duplicateCheck));
}


@override
int get hashCode {
  final _this = this as NoteType;
  return Object.hash(runtimeType,_this.id,_this.collectionId,_this.name,const DeepCollectionEquality().hash(_this.fields),const DeepCollectionEquality().hash(_this.templates),_this.duplicateCheck);
}

@override
String toString() {
  final _this = this as NoteType;
  return 'NoteType(id: ${_this.id}, collectionId: ${_this.collectionId}, name: ${_this.name}, fields: ${_this.fields}, templates: ${_this.templates}, duplicateCheck: ${_this.duplicateCheck})';
}


}

/// @nodoc
abstract mixin class $NoteTypeCopyWith<$Res>  {
  factory $NoteTypeCopyWith(NoteType value, $Res Function(NoteType) _then) = _$NoteTypeCopyWithImpl;
@useResult
$Res call({
 NoteTypeId id, CollectionId collectionId, String name, List<FieldDefinition> fields, List<StudyCardTemplate> templates, FieldDefinitionId? duplicateCheck
});




}
/// @nodoc
class _$NoteTypeCopyWithImpl<$Res>
    implements $NoteTypeCopyWith<$Res> {
  _$NoteTypeCopyWithImpl(this._self, this._then);

  final NoteType _self;
  final $Res Function(NoteType) _then;

/// Create a copy of NoteType
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? collectionId = null,Object? name = null,Object? fields = null,Object? templates = null,Object? duplicateCheck = freezed,}) {
  return _then(NoteType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NoteTypeId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<FieldDefinition>,templates: null == templates ? _self.templates : templates // ignore: cast_nullable_to_non_nullable
as List<StudyCardTemplate>,duplicateCheck: freezed == duplicateCheck ? _self.duplicateCheck : duplicateCheck // ignore: cast_nullable_to_non_nullable
as FieldDefinitionId?,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteType].
extension NoteTypePatterns on NoteType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteType value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteType() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteType value)  $default,){
final _that = this;
switch (_that) {
case _NoteType():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteType value)?  $default,){
final _that = this;
switch (_that) {
case _NoteType() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NoteTypeId id,  CollectionId collectionId,  String name,  List<FieldDefinition> fields,  List<StudyCardTemplate> templates,  FieldDefinitionId? duplicateCheck)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteType() when $default != null:
return $default(_that.id,_that.collectionId,_that.name,_that.fields,_that.templates,_that.duplicateCheck);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NoteTypeId id,  CollectionId collectionId,  String name,  List<FieldDefinition> fields,  List<StudyCardTemplate> templates,  FieldDefinitionId? duplicateCheck)  $default,) {final _that = this;
switch (_that) {
case _NoteType():
return $default(_that.id,_that.collectionId,_that.name,_that.fields,_that.templates,_that.duplicateCheck);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NoteTypeId id,  CollectionId collectionId,  String name,  List<FieldDefinition> fields,  List<StudyCardTemplate> templates,  FieldDefinitionId? duplicateCheck)?  $default,) {final _that = this;
switch (_that) {
case _NoteType() when $default != null:
return $default(_that.id,_that.collectionId,_that.name,_that.fields,_that.templates,_that.duplicateCheck);case _:
  return null;

}
}

}

/// @nodoc


class _NoteType extends NoteType {
   _NoteType({required this.id, required this.collectionId, required this.name, required  List<FieldDefinition> fields, required  List<StudyCardTemplate> templates, this.duplicateCheck}): _fields = fields,_templates = templates,super._();
  

@override final  NoteTypeId id;
@override final  CollectionId collectionId;
@override final  String name;
 final  List<FieldDefinition> _fields;
@override List<FieldDefinition> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}

 final  List<StudyCardTemplate> _templates;
@override List<StudyCardTemplate> get templates {
  if (_templates is EqualUnmodifiableListView) return _templates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_templates);
}

/// The field whose plain text is compared across notes, to warn of
/// duplicates. Null when none is.
@override final  FieldDefinitionId? duplicateCheck;

/// Create a copy of NoteType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteTypeCopyWith<_NoteType> get copyWith => __$NoteTypeCopyWithImpl<_NoteType>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteType&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.fields, _fields)&&const DeepCollectionEquality().equals(other.templates, _templates)&&(identical(other.duplicateCheck, duplicateCheck) || other.duplicateCheck == duplicateCheck));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,collectionId,name,const DeepCollectionEquality().hash(_fields),const DeepCollectionEquality().hash(_templates),duplicateCheck);
}

@override
String toString() {
    return 'NoteType(id: $id, collectionId: $collectionId, name: $name, fields: $fields, templates: $templates, duplicateCheck: $duplicateCheck)';
}


}

/// @nodoc
abstract mixin class _$NoteTypeCopyWith<$Res> implements $NoteTypeCopyWith<$Res> {
  factory _$NoteTypeCopyWith(_NoteType value, $Res Function(_NoteType) _then) = __$NoteTypeCopyWithImpl;
@override @useResult
$Res call({
 NoteTypeId id, CollectionId collectionId, String name, List<FieldDefinition> fields, List<StudyCardTemplate> templates, FieldDefinitionId? duplicateCheck
});




}
/// @nodoc
class __$NoteTypeCopyWithImpl<$Res>
    implements _$NoteTypeCopyWith<$Res> {
  __$NoteTypeCopyWithImpl(this._self, this._then);

  final _NoteType _self;
  final $Res Function(_NoteType) _then;

/// Create a copy of NoteType
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? collectionId = null,Object? name = null,Object? fields = null,Object? templates = null,Object? duplicateCheck = freezed,}) {
  return _then(_NoteType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NoteTypeId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<FieldDefinition>,templates: null == templates ? _self._templates : templates // ignore: cast_nullable_to_non_nullable
as List<StudyCardTemplate>,duplicateCheck: freezed == duplicateCheck ? _self.duplicateCheck : duplicateCheck // ignore: cast_nullable_to_non_nullable
as FieldDefinitionId?,
  ));
}


}

// dart format on
