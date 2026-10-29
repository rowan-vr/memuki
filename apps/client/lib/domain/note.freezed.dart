// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Tag {

 TagId get id; CollectionId get collectionId; TagId? get parentId; String get name;
/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagCopyWith<Tag> get copyWith => _$TagCopyWithImpl<Tag>(this as Tag, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Tag;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tag&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.parentId, _this.parentId) || other.parentId == _this.parentId)&&(identical(other.name, _this.name) || other.name == _this.name));
}


@override
int get hashCode {
  final _this = this as Tag;
  return Object.hash(runtimeType,_this.id,_this.collectionId,_this.parentId,_this.name);
}

@override
String toString() {
  final _this = this as Tag;
  return 'Tag(id: ${_this.id}, collectionId: ${_this.collectionId}, parentId: ${_this.parentId}, name: ${_this.name})';
}


}

/// @nodoc
abstract mixin class $TagCopyWith<$Res>  {
  factory $TagCopyWith(Tag value, $Res Function(Tag) _then) = _$TagCopyWithImpl;
@useResult
$Res call({
 TagId id, CollectionId collectionId, TagId? parentId, String name
});




}
/// @nodoc
class _$TagCopyWithImpl<$Res>
    implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._self, this._then);

  final Tag _self;
  final $Res Function(Tag) _then;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? collectionId = null,Object? parentId = freezed,Object? name = null,}) {
  return _then(Tag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as TagId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as TagId?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Tag].
extension TagPatterns on Tag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tag value)  $default,){
final _that = this;
switch (_that) {
case _Tag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tag value)?  $default,){
final _that = this;
switch (_that) {
case _Tag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TagId id,  CollectionId collectionId,  TagId? parentId,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that.id,_that.collectionId,_that.parentId,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TagId id,  CollectionId collectionId,  TagId? parentId,  String name)  $default,) {final _that = this;
switch (_that) {
case _Tag():
return $default(_that.id,_that.collectionId,_that.parentId,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TagId id,  CollectionId collectionId,  TagId? parentId,  String name)?  $default,) {final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that.id,_that.collectionId,_that.parentId,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _Tag extends Tag {
   _Tag({required this.id, required this.collectionId, this.parentId, required this.name}): super._();
  

@override final  TagId id;
@override final  CollectionId collectionId;
@override final  TagId? parentId;
@override final  String name;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagCopyWith<_Tag> get copyWith => __$TagCopyWithImpl<_Tag>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tag&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,collectionId,parentId,name);
}

@override
String toString() {
    return 'Tag(id: $id, collectionId: $collectionId, parentId: $parentId, name: $name)';
}


}

/// @nodoc
abstract mixin class _$TagCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$TagCopyWith(_Tag value, $Res Function(_Tag) _then) = __$TagCopyWithImpl;
@override @useResult
$Res call({
 TagId id, CollectionId collectionId, TagId? parentId, String name
});




}
/// @nodoc
class __$TagCopyWithImpl<$Res>
    implements _$TagCopyWith<$Res> {
  __$TagCopyWithImpl(this._self, this._then);

  final _Tag _self;
  final $Res Function(_Tag) _then;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? collectionId = null,Object? parentId = freezed,Object? name = null,}) {
  return _then(_Tag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as TagId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as TagId?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$NoteTag {

 NoteId get noteId; TagId get tagId;
/// Create a copy of NoteTag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteTagCopyWith<NoteTag> get copyWith => _$NoteTagCopyWithImpl<NoteTag>(this as NoteTag, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as NoteTag;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NoteTag&&(identical(other.noteId, _this.noteId) || other.noteId == _this.noteId)&&(identical(other.tagId, _this.tagId) || other.tagId == _this.tagId));
}


@override
int get hashCode {
  final _this = this as NoteTag;
  return Object.hash(runtimeType,_this.noteId,_this.tagId);
}

@override
String toString() {
  final _this = this as NoteTag;
  return 'NoteTag(noteId: ${_this.noteId}, tagId: ${_this.tagId})';
}


}

/// @nodoc
abstract mixin class $NoteTagCopyWith<$Res>  {
  factory $NoteTagCopyWith(NoteTag value, $Res Function(NoteTag) _then) = _$NoteTagCopyWithImpl;
@useResult
$Res call({
 NoteId noteId, TagId tagId
});




}
/// @nodoc
class _$NoteTagCopyWithImpl<$Res>
    implements $NoteTagCopyWith<$Res> {
  _$NoteTagCopyWithImpl(this._self, this._then);

  final NoteTag _self;
  final $Res Function(NoteTag) _then;

/// Create a copy of NoteTag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? noteId = null,Object? tagId = null,}) {
  return _then(NoteTag(
noteId: null == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as NoteId,tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as TagId,
  ));
}

}


/// Adds pattern-matching-related methods to [NoteTag].
extension NoteTagPatterns on NoteTag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NoteTag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NoteTag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NoteTag value)  $default,){
final _that = this;
switch (_that) {
case _NoteTag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NoteTag value)?  $default,){
final _that = this;
switch (_that) {
case _NoteTag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NoteId noteId,  TagId tagId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NoteTag() when $default != null:
return $default(_that.noteId,_that.tagId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NoteId noteId,  TagId tagId)  $default,) {final _that = this;
switch (_that) {
case _NoteTag():
return $default(_that.noteId,_that.tagId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NoteId noteId,  TagId tagId)?  $default,) {final _that = this;
switch (_that) {
case _NoteTag() when $default != null:
return $default(_that.noteId,_that.tagId);case _:
  return null;

}
}

}

/// @nodoc


class _NoteTag implements NoteTag {
   _NoteTag({required this.noteId, required this.tagId});
  

@override final  NoteId noteId;
@override final  TagId tagId;

/// Create a copy of NoteTag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteTagCopyWith<_NoteTag> get copyWith => __$NoteTagCopyWithImpl<_NoteTag>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NoteTag&&(identical(other.noteId, noteId) || other.noteId == noteId)&&(identical(other.tagId, tagId) || other.tagId == tagId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,noteId,tagId);
}

@override
String toString() {
    return 'NoteTag(noteId: $noteId, tagId: $tagId)';
}


}

/// @nodoc
abstract mixin class _$NoteTagCopyWith<$Res> implements $NoteTagCopyWith<$Res> {
  factory _$NoteTagCopyWith(_NoteTag value, $Res Function(_NoteTag) _then) = __$NoteTagCopyWithImpl;
@override @useResult
$Res call({
 NoteId noteId, TagId tagId
});




}
/// @nodoc
class __$NoteTagCopyWithImpl<$Res>
    implements _$NoteTagCopyWith<$Res> {
  __$NoteTagCopyWithImpl(this._self, this._then);

  final _NoteTag _self;
  final $Res Function(_NoteTag) _then;

/// Create a copy of NoteTag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? noteId = null,Object? tagId = null,}) {
  return _then(_NoteTag(
noteId: null == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as NoteId,tagId: null == tagId ? _self.tagId : tagId // ignore: cast_nullable_to_non_nullable
as TagId,
  ));
}


}

/// @nodoc
mixin _$SourceAttribution {

 SourceKind get kind; String? get reference;
/// Create a copy of SourceAttribution
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SourceAttributionCopyWith<SourceAttribution> get copyWith => _$SourceAttributionCopyWithImpl<SourceAttribution>(this as SourceAttribution, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SourceAttribution;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SourceAttribution&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.reference, _this.reference) || other.reference == _this.reference));
}


@override
int get hashCode {
  final _this = this as SourceAttribution;
  return Object.hash(runtimeType,_this.kind,_this.reference);
}

@override
String toString() {
  final _this = this as SourceAttribution;
  return 'SourceAttribution(kind: ${_this.kind}, reference: ${_this.reference})';
}


}

/// @nodoc
abstract mixin class $SourceAttributionCopyWith<$Res>  {
  factory $SourceAttributionCopyWith(SourceAttribution value, $Res Function(SourceAttribution) _then) = _$SourceAttributionCopyWithImpl;
@useResult
$Res call({
 SourceKind kind, String? reference
});




}
/// @nodoc
class _$SourceAttributionCopyWithImpl<$Res>
    implements $SourceAttributionCopyWith<$Res> {
  _$SourceAttributionCopyWithImpl(this._self, this._then);

  final SourceAttribution _self;
  final $Res Function(SourceAttribution) _then;

/// Create a copy of SourceAttribution
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? reference = freezed,}) {
  return _then(SourceAttribution(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SourceKind,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SourceAttribution].
extension SourceAttributionPatterns on SourceAttribution {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SourceAttribution value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SourceAttribution() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SourceAttribution value)  $default,){
final _that = this;
switch (_that) {
case _SourceAttribution():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SourceAttribution value)?  $default,){
final _that = this;
switch (_that) {
case _SourceAttribution() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SourceKind kind,  String? reference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SourceAttribution() when $default != null:
return $default(_that.kind,_that.reference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SourceKind kind,  String? reference)  $default,) {final _that = this;
switch (_that) {
case _SourceAttribution():
return $default(_that.kind,_that.reference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SourceKind kind,  String? reference)?  $default,) {final _that = this;
switch (_that) {
case _SourceAttribution() when $default != null:
return $default(_that.kind,_that.reference);case _:
  return null;

}
}

}

/// @nodoc


class _SourceAttribution implements SourceAttribution {
   _SourceAttribution({required this.kind, this.reference});
  

@override final  SourceKind kind;
@override final  String? reference;

/// Create a copy of SourceAttribution
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SourceAttributionCopyWith<_SourceAttribution> get copyWith => __$SourceAttributionCopyWithImpl<_SourceAttribution>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SourceAttribution&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.reference, reference) || other.reference == reference));
}


@override
int get hashCode {
    return Object.hash(runtimeType,kind,reference);
}

@override
String toString() {
    return 'SourceAttribution(kind: $kind, reference: $reference)';
}


}

/// @nodoc
abstract mixin class _$SourceAttributionCopyWith<$Res> implements $SourceAttributionCopyWith<$Res> {
  factory _$SourceAttributionCopyWith(_SourceAttribution value, $Res Function(_SourceAttribution) _then) = __$SourceAttributionCopyWithImpl;
@override @useResult
$Res call({
 SourceKind kind, String? reference
});




}
/// @nodoc
class __$SourceAttributionCopyWithImpl<$Res>
    implements _$SourceAttributionCopyWith<$Res> {
  __$SourceAttributionCopyWithImpl(this._self, this._then);

  final _SourceAttribution _self;
  final $Res Function(_SourceAttribution) _then;

/// Create a copy of SourceAttribution
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? reference = freezed,}) {
  return _then(_SourceAttribution(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as SourceKind,reference: freezed == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Note {

 NoteId get id; CollectionId get collectionId; NoteTypeId get noteTypeId; Map<FieldDefinitionId, String> get fields; SourceAttribution? get source;
/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NoteCopyWith<Note> get copyWith => _$NoteCopyWithImpl<Note>(this as Note, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Note;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Note&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.noteTypeId, _this.noteTypeId) || other.noteTypeId == _this.noteTypeId)&&const DeepCollectionEquality().equals(other.fields, _this.fields)&&(identical(other.source, _this.source) || other.source == _this.source));
}


@override
int get hashCode {
  final _this = this as Note;
  return Object.hash(runtimeType,_this.id,_this.collectionId,_this.noteTypeId,const DeepCollectionEquality().hash(_this.fields),_this.source);
}

@override
String toString() {
  final _this = this as Note;
  return 'Note(id: ${_this.id}, collectionId: ${_this.collectionId}, noteTypeId: ${_this.noteTypeId}, fields: ${_this.fields}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $NoteCopyWith<$Res>  {
  factory $NoteCopyWith(Note value, $Res Function(Note) _then) = _$NoteCopyWithImpl;
@useResult
$Res call({
 NoteId id, CollectionId collectionId, NoteTypeId noteTypeId, Map<FieldDefinitionId, String> fields, SourceAttribution? source
});


$SourceAttributionCopyWith<$Res>? get source;

}
/// @nodoc
class _$NoteCopyWithImpl<$Res>
    implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._self, this._then);

  final Note _self;
  final $Res Function(Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? collectionId = null,Object? noteTypeId = null,Object? fields = null,Object? source = freezed,}) {
  return _then(Note(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NoteId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,noteTypeId: null == noteTypeId ? _self.noteTypeId : noteTypeId // ignore: cast_nullable_to_non_nullable
as NoteTypeId,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as Map<FieldDefinitionId, String>,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SourceAttribution?,
  ));
}
/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SourceAttributionCopyWith<$Res>? get source {
    if (_self.source == null) {
    return null;
  }

  return $SourceAttributionCopyWith<$Res>(_self.source!, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}


/// Adds pattern-matching-related methods to [Note].
extension NotePatterns on Note {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Note value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Note value)  $default,){
final _that = this;
switch (_that) {
case _Note():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Note value)?  $default,){
final _that = this;
switch (_that) {
case _Note() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NoteId id,  CollectionId collectionId,  NoteTypeId noteTypeId,  Map<FieldDefinitionId, String> fields,  SourceAttribution? source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.collectionId,_that.noteTypeId,_that.fields,_that.source);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NoteId id,  CollectionId collectionId,  NoteTypeId noteTypeId,  Map<FieldDefinitionId, String> fields,  SourceAttribution? source)  $default,) {final _that = this;
switch (_that) {
case _Note():
return $default(_that.id,_that.collectionId,_that.noteTypeId,_that.fields,_that.source);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NoteId id,  CollectionId collectionId,  NoteTypeId noteTypeId,  Map<FieldDefinitionId, String> fields,  SourceAttribution? source)?  $default,) {final _that = this;
switch (_that) {
case _Note() when $default != null:
return $default(_that.id,_that.collectionId,_that.noteTypeId,_that.fields,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _Note implements Note {
   _Note({required this.id, required this.collectionId, required this.noteTypeId, required  Map<FieldDefinitionId, String> fields, this.source}): _fields = fields;
  

@override final  NoteId id;
@override final  CollectionId collectionId;
@override final  NoteTypeId noteTypeId;
 final  Map<FieldDefinitionId, String> _fields;
@override Map<FieldDefinitionId, String> get fields {
  if (_fields is EqualUnmodifiableMapView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fields);
}

@override final  SourceAttribution? source;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NoteCopyWith<_Note> get copyWith => __$NoteCopyWithImpl<_Note>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Note&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.noteTypeId, noteTypeId) || other.noteTypeId == noteTypeId)&&const DeepCollectionEquality().equals(other.fields, _fields)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,collectionId,noteTypeId,const DeepCollectionEquality().hash(_fields),source);
}

@override
String toString() {
    return 'Note(id: $id, collectionId: $collectionId, noteTypeId: $noteTypeId, fields: $fields, source: $source)';
}


}

/// @nodoc
abstract mixin class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) _then) = __$NoteCopyWithImpl;
@override @useResult
$Res call({
 NoteId id, CollectionId collectionId, NoteTypeId noteTypeId, Map<FieldDefinitionId, String> fields, SourceAttribution? source
});


@override $SourceAttributionCopyWith<$Res>? get source;

}
/// @nodoc
class __$NoteCopyWithImpl<$Res>
    implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(this._self, this._then);

  final _Note _self;
  final $Res Function(_Note) _then;

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? collectionId = null,Object? noteTypeId = null,Object? fields = null,Object? source = freezed,}) {
  return _then(_Note(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as NoteId,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as CollectionId,noteTypeId: null == noteTypeId ? _self.noteTypeId : noteTypeId // ignore: cast_nullable_to_non_nullable
as NoteTypeId,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as Map<FieldDefinitionId, String>,source: freezed == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as SourceAttribution?,
  ));
}

/// Create a copy of Note
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SourceAttributionCopyWith<$Res>? get source {
    if (_self.source == null) {
    return null;
  }

  return $SourceAttributionCopyWith<$Res>(_self.source!, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}

// dart format on
