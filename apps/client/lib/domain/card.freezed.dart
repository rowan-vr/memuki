// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Card {

 NoteId get noteId; CardTemplateId get templateId; DeckId get deckId;
/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardCopyWith<Card> get copyWith => _$CardCopyWithImpl<Card>(this as Card, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Card;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Card&&(identical(other.noteId, _this.noteId) || other.noteId == _this.noteId)&&(identical(other.templateId, _this.templateId) || other.templateId == _this.templateId)&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId));
}


@override
int get hashCode {
  final _this = this as Card;
  return Object.hash(runtimeType,_this.noteId,_this.templateId,_this.deckId);
}

@override
String toString() {
  final _this = this as Card;
  return 'Card(noteId: ${_this.noteId}, templateId: ${_this.templateId}, deckId: ${_this.deckId})';
}


}

/// @nodoc
abstract mixin class $CardCopyWith<$Res>  {
  factory $CardCopyWith(Card value, $Res Function(Card) _then) = _$CardCopyWithImpl;
@useResult
$Res call({
 NoteId noteId, CardTemplateId templateId, DeckId deckId
});




}
/// @nodoc
class _$CardCopyWithImpl<$Res>
    implements $CardCopyWith<$Res> {
  _$CardCopyWithImpl(this._self, this._then);

  final Card _self;
  final $Res Function(Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? noteId = null,Object? templateId = null,Object? deckId = null,}) {
  return _then(Card(
noteId: null == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as NoteId,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as CardTemplateId,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as DeckId,
  ));
}

}


/// Adds pattern-matching-related methods to [Card].
extension CardPatterns on Card {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Card value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Card() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Card value)  $default,){
final _that = this;
switch (_that) {
case _Card():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Card value)?  $default,){
final _that = this;
switch (_that) {
case _Card() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NoteId noteId,  CardTemplateId templateId,  DeckId deckId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Card() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NoteId noteId,  CardTemplateId templateId,  DeckId deckId)  $default,) {final _that = this;
switch (_that) {
case _Card():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NoteId noteId,  CardTemplateId templateId,  DeckId deckId)?  $default,) {final _that = this;
switch (_that) {
case _Card() when $default != null:
return $default(_that.noteId,_that.templateId,_that.deckId);case _:
  return null;

}
}

}

/// @nodoc


class _Card extends Card {
   _Card({required this.noteId, required this.templateId, required this.deckId}): super._();
  

@override final  NoteId noteId;
@override final  CardTemplateId templateId;
@override final  DeckId deckId;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardCopyWith<_Card> get copyWith => __$CardCopyWithImpl<_Card>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Card&&(identical(other.noteId, noteId) || other.noteId == noteId)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.deckId, deckId) || other.deckId == deckId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,noteId,templateId,deckId);
}

@override
String toString() {
    return 'Card(noteId: $noteId, templateId: $templateId, deckId: $deckId)';
}


}

/// @nodoc
abstract mixin class _$CardCopyWith<$Res> implements $CardCopyWith<$Res> {
  factory _$CardCopyWith(_Card value, $Res Function(_Card) _then) = __$CardCopyWithImpl;
@override @useResult
$Res call({
 NoteId noteId, CardTemplateId templateId, DeckId deckId
});




}
/// @nodoc
class __$CardCopyWithImpl<$Res>
    implements _$CardCopyWith<$Res> {
  __$CardCopyWithImpl(this._self, this._then);

  final _Card _self;
  final $Res Function(_Card) _then;

/// Create a copy of Card
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? noteId = null,Object? templateId = null,Object? deckId = null,}) {
  return _then(_Card(
noteId: null == noteId ? _self.noteId : noteId // ignore: cast_nullable_to_non_nullable
as NoteId,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as CardTemplateId,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as DeckId,
  ));
}


}

// dart format on
