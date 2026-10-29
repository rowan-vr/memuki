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

 FieldDefinitionId get id; String get name; FieldType get type;
/// Create a copy of FieldDefinition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldDefinitionCopyWith<FieldDefinition> get copyWith => _$FieldDefinitionCopyWithImpl<FieldDefinition>(this as FieldDefinition, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FieldDefinition;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldDefinition&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type));
}


@override
int get hashCode {
  final _this = this as FieldDefinition;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type);
}

@override
String toString() {
  final _this = this as FieldDefinition;
  return 'FieldDefinition(id: ${_this.id}, name: ${_this.name}, type: ${_this.type})';
}


}

/// @nodoc
abstract mixin class $FieldDefinitionCopyWith<$Res>  {
  factory $FieldDefinitionCopyWith(FieldDefinition value, $Res Function(FieldDefinition) _then) = _$FieldDefinitionCopyWithImpl;
@useResult
$Res call({
 FieldDefinitionId id, String name, FieldType type
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,}) {
  return _then(FieldDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as FieldDefinitionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FieldType,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FieldDefinitionId id,  String name,  FieldType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldDefinition() when $default != null:
return $default(_that.id,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FieldDefinitionId id,  String name,  FieldType type)  $default,) {final _that = this;
switch (_that) {
case _FieldDefinition():
return $default(_that.id,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FieldDefinitionId id,  String name,  FieldType type)?  $default,) {final _that = this;
switch (_that) {
case _FieldDefinition() when $default != null:
return $default(_that.id,_that.name,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _FieldDefinition extends FieldDefinition {
   _FieldDefinition({required this.id, required this.name, this.type = FieldType.text}): super._();
  

@override final  FieldDefinitionId id;
@override final  String name;
@override@JsonKey() final  FieldType type;

/// Create a copy of FieldDefinition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldDefinitionCopyWith<_FieldDefinition> get copyWith => __$FieldDefinitionCopyWithImpl<_FieldDefinition>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldDefinition&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type);
}

@override
String toString() {
    return 'FieldDefinition(id: $id, name: $name, type: $type)';
}


}

/// @nodoc
abstract mixin class _$FieldDefinitionCopyWith<$Res> implements $FieldDefinitionCopyWith<$Res> {
  factory _$FieldDefinitionCopyWith(_FieldDefinition value, $Res Function(_FieldDefinition) _then) = __$FieldDefinitionCopyWithImpl;
@override @useResult
$Res call({
 FieldDefinitionId id, String name, FieldType type
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,}) {
  return _then(_FieldDefinition(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as FieldDefinitionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FieldType,
  ));
}


}

/// @nodoc
mixin _$StudyCardTemplate {

 StudyCardTemplateId get id; String get name;
/// Create a copy of StudyCardTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudyCardTemplateCopyWith<StudyCardTemplate> get copyWith => _$StudyCardTemplateCopyWithImpl<StudyCardTemplate>(this as StudyCardTemplate, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StudyCardTemplate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudyCardTemplate&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as StudyCardTemplate;
  return Object.hash(runtimeType,_this.id,_this.name);
}

@override
String toString() {
  final _this = this as StudyCardTemplate;
  return 'StudyCardTemplate(id: ${_this.id}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $StudyCardTemplateCopyWith<$Res>  {
  factory $StudyCardTemplateCopyWith(StudyCardTemplate value, $Res Function(StudyCardTemplate) _then) = _$StudyCardTemplateCopyWithImpl;
@useResult
$Res call({
 StudyCardTemplateId id, String name
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(StudyCardTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as StudyCardTemplateId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StudyCardTemplateId id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudyCardTemplate() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StudyCardTemplateId id,  String name)  $default,) {final _that = this;
switch (_that) {
case _StudyCardTemplate():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StudyCardTemplateId id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _StudyCardTemplate() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _StudyCardTemplate extends StudyCardTemplate {
   _StudyCardTemplate({required this.id, required this.name}): super._();
  

@override final  StudyCardTemplateId id;
@override final  String name;

/// Create a copy of StudyCardTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudyCardTemplateCopyWith<_StudyCardTemplate> get copyWith => __$StudyCardTemplateCopyWithImpl<_StudyCardTemplate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudyCardTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name);
}

@override
String toString() {
    return 'StudyCardTemplate(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$StudyCardTemplateCopyWith<$Res> implements $StudyCardTemplateCopyWith<$Res> {
  factory _$StudyCardTemplateCopyWith(_StudyCardTemplate value, $Res Function(_StudyCardTemplate) _then) = __$StudyCardTemplateCopyWithImpl;
@override @useResult
$Res call({
 StudyCardTemplateId id, String name
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_StudyCardTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as StudyCardTemplateId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$NoteType {

 NoteTypeId get id; CollectionId get collectionId; String get name; List<FieldDefinition> get fields; List<StudyCardTemplate> get templates;
/// Create a copy of NoteType
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteTypeCopyWith<NoteType> get copyWith => _$NoteTypeCopyWithImpl<NoteType>(this as NoteType, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NoteType;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteType&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.fields, _this.fields)&&const DeepCollectionEquality().equals(other.templates, _this.templates));
}


@override
int get hashCode {
  final _this = this as NoteType;
  return Object.hash(runtimeType,_this.id,_this.collectionId,_this.name,const DeepCollectionEquality().hash(_this.fields),const DeepCollectionEquality().hash(_this.templates));
}

@override
String toString() {
  final _this = this as NoteType;
  return 'NoteType(id: ${_this.id}, collectionId: ${_this.collectionId}, name: ${_this.name}, fields: ${_this.fields}, templates: ${_this.templates})';
}


}

/// @nodoc
abstract mixin class $NoteTypeCopyWith<$Res>  {
  factory $NoteTypeCopyWith(NoteType value, $Res Function(NoteType) _then) = _$NoteTypeCopyWithImpl;
@useResult
$Res call({
 NoteTypeId id, CollectionId collectionId, String name, List<FieldDefinition> fields, List<StudyCardTemplate> templates
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? collectionId = null,Object? name = null,Object? fields = null,Object? templates = null,}) {
  return _then(NoteType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NoteTypeId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<FieldDefinition>,templates: null == templates ? _self.templates : templates // ignore: cast_nullable_to_non_nullable
as List<StudyCardTemplate>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NoteTypeId id,  CollectionId collectionId,  String name,  List<FieldDefinition> fields,  List<StudyCardTemplate> templates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteType() when $default != null:
return $default(_that.id,_that.collectionId,_that.name,_that.fields,_that.templates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NoteTypeId id,  CollectionId collectionId,  String name,  List<FieldDefinition> fields,  List<StudyCardTemplate> templates)  $default,) {final _that = this;
switch (_that) {
case _NoteType():
return $default(_that.id,_that.collectionId,_that.name,_that.fields,_that.templates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NoteTypeId id,  CollectionId collectionId,  String name,  List<FieldDefinition> fields,  List<StudyCardTemplate> templates)?  $default,) {final _that = this;
switch (_that) {
case _NoteType() when $default != null:
return $default(_that.id,_that.collectionId,_that.name,_that.fields,_that.templates);case _:
  return null;

}
}

}

/// @nodoc


class _NoteType extends NoteType {
   _NoteType({required this.id, required this.collectionId, required this.name, required  List<FieldDefinition> fields, required  List<StudyCardTemplate> templates}): _fields = fields,_templates = templates,super._();
  

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


/// Create a copy of NoteType
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteTypeCopyWith<_NoteType> get copyWith => __$NoteTypeCopyWithImpl<_NoteType>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteType&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.fields, _fields)&&const DeepCollectionEquality().equals(other.templates, _templates));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,collectionId,name,const DeepCollectionEquality().hash(_fields),const DeepCollectionEquality().hash(_templates));
}

@override
String toString() {
    return 'NoteType(id: $id, collectionId: $collectionId, name: $name, fields: $fields, templates: $templates)';
}


}

/// @nodoc
abstract mixin class _$NoteTypeCopyWith<$Res> implements $NoteTypeCopyWith<$Res> {
  factory _$NoteTypeCopyWith(_NoteType value, $Res Function(_NoteType) _then) = __$NoteTypeCopyWithImpl;
@override @useResult
$Res call({
 NoteTypeId id, CollectionId collectionId, String name, List<FieldDefinition> fields, List<StudyCardTemplate> templates
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? collectionId = null,Object? name = null,Object? fields = null,Object? templates = null,}) {
  return _then(_NoteType(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NoteTypeId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<FieldDefinition>,templates: null == templates ? _self._templates : templates // ignore: cast_nullable_to_non_nullable
as List<StudyCardTemplate>,
  ));
}


}

// dart format on
