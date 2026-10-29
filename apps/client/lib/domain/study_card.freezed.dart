// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StudyCard {

 NoteId get noteId; StudyCardTemplateId get templateId; DeckId get deckId;
/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudyCardCopyWith<StudyCard> get copyWith => _$StudyCardCopyWithImpl<StudyCard>(this as StudyCard, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StudyCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudyCard&&(identical(other.noteId, _this.noteId) || other.noteId == _this.noteId)&&(identical(other.templateId, _this.templateId) || other.templateId == _this.templateId)&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId));
}


@override
int get hashCode {
  final _this = this as StudyCard;
  return Object.hash(runtimeType,_this.noteId,_this.templateId,_this.deckId);
}

@override
String toString() {
  final _this = this as StudyCard;
  return 'StudyCard(noteId: ${_this.noteId}, templateId: ${_this.templateId}, deckId: ${_this.deckId})';
}


}

/// @nodoc
abstract mixin class $StudyCardCopyWith<$Res>  {
  factory $StudyCardCopyWith(StudyCard value, $Res Function(StudyCard) _then) = _$StudyCardCopyWithImpl;
@useResult
$Res call({
 NoteId noteId, StudyCardTemplateId templateId, DeckId deckId
});




}
/// @nodoc
class _$StudyCardCopyWithImpl<$Res>
    implements $StudyCardCopyWith<$Res> {
  _$StudyCardCopyWithImpl(this._self, this._then);

  final StudyCard _self;
  final $Res Function(StudyCard) _then;

/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? noteId = null,Object? templateId = null,Object? deckId = null,}) {
  return _then(StudyCard(
noteId: null == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as NoteId,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as StudyCardTemplateId,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as DeckId,
  ));
}

}


/// Adds pattern-matching-related methods to [StudyCard].
extension StudyCardPatterns on StudyCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudyCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudyCard value)  $default,){
final _that = this;
switch (_that) {
case _StudyCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudyCard value)?  $default,){
final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NoteId noteId,  StudyCardTemplateId templateId,  DeckId deckId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
return $default(_that.noteId,_that.templateId,_that.deckId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NoteId noteId,  StudyCardTemplateId templateId,  DeckId deckId)  $default,) {final _that = this;
switch (_that) {
case _StudyCard():
return $default(_that.noteId,_that.templateId,_that.deckId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NoteId noteId,  StudyCardTemplateId templateId,  DeckId deckId)?  $default,) {final _that = this;
switch (_that) {
case _StudyCard() when $default != null:
return $default(_that.noteId,_that.templateId,_that.deckId);case _:
  return null;

}
}

}

/// @nodoc


class _StudyCard extends StudyCard {
   _StudyCard({required this.noteId, required this.templateId, required this.deckId}): super._();
  

@override final  NoteId noteId;
@override final  StudyCardTemplateId templateId;
@override final  DeckId deckId;

/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudyCardCopyWith<_StudyCard> get copyWith => __$StudyCardCopyWithImpl<_StudyCard>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudyCard&&(identical(other.noteId, noteId) || other.noteId == noteId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.deckId, deckId) || other.deckId == deckId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,noteId,templateId,deckId);
}

@override
String toString() {
    return 'StudyCard(noteId: $noteId, templateId: $templateId, deckId: $deckId)';
}


}

/// @nodoc
abstract mixin class _$StudyCardCopyWith<$Res> implements $StudyCardCopyWith<$Res> {
  factory _$StudyCardCopyWith(_StudyCard value, $Res Function(_StudyCard) _then) = __$StudyCardCopyWithImpl;
@override @useResult
$Res call({
 NoteId noteId, StudyCardTemplateId templateId, DeckId deckId
});




}
/// @nodoc
class __$StudyCardCopyWithImpl<$Res>
    implements _$StudyCardCopyWith<$Res> {
  __$StudyCardCopyWithImpl(this._self, this._then);

  final _StudyCard _self;
  final $Res Function(_StudyCard) _then;

/// Create a copy of StudyCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? noteId = null,Object? templateId = null,Object? deckId = null,}) {
  return _then(_StudyCard(
noteId: null == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as NoteId,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as StudyCardTemplateId,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as DeckId,
  ));
}


}

// dart format on
