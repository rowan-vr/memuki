// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'content_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContentNode {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ContentNode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'ContentNode()';
}


}

/// @nodoc
class $ContentNodeCopyWith<$Res>  {
$ContentNodeCopyWith(ContentNode _, $Res Function(ContentNode) __);
}


/// Adds pattern-matching-related methods to [ContentNode].
extension ContentNodePatterns on ContentNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TextNode value)?  text,TResult Function( MarkNode value)?  mark,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TextNode() when text != null:
return text(_that);case MarkNode() when mark != null:
return mark(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TextNode value)  text,required TResult Function( MarkNode value)  mark,}){
final _that = this;
switch (_that) {
case TextNode():
return text(_that);case MarkNode():
return mark(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TextNode value)?  text,TResult? Function( MarkNode value)?  mark,}){
final _that = this;
switch (_that) {
case TextNode() when text != null:
return text(_that);case MarkNode() when mark != null:
return mark(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String text)?  text,TResult Function( String key,  List<String> args,  Map<String, String> named,  List<ContentNode>? content)?  mark,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TextNode() when text != null:
return text(_that.text);case MarkNode() when mark != null:
return mark(_that.key,_that.args,_that.named,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String text)  text,required TResult Function( String key,  List<String> args,  Map<String, String> named,  List<ContentNode>? content)  mark,}) {final _that = this;
switch (_that) {
case TextNode():
return text(_that.text);case MarkNode():
return mark(_that.key,_that.args,_that.named,_that.content);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String text)?  text,TResult? Function( String key,  List<String> args,  Map<String, String> named,  List<ContentNode>? content)?  mark,}) {final _that = this;
switch (_that) {
case TextNode() when text != null:
return text(_that.text);case MarkNode() when mark != null:
return mark(_that.key,_that.args,_that.named,_that.content);case _:
  return null;

}
}

}

/// @nodoc


class TextNode implements ContentNode {
  const TextNode(this.text);
  

 final  String text;

/// Create a copy of ContentNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextNodeCopyWith<TextNode> get copyWith => _$TextNodeCopyWithImpl<TextNode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is TextNode&&(identical(other.text, text) || other.text == text));
}


@override
int get hashCode {
    return Object.hash(runtimeType,text);
}

@override
String toString() {
    return 'ContentNode.text(text: $text)';
}


}

/// @nodoc
abstract mixin class $TextNodeCopyWith<$Res> implements $ContentNodeCopyWith<$Res> {
  factory $TextNodeCopyWith(TextNode value, $Res Function(TextNode) _then) = _$TextNodeCopyWithImpl;
@useResult
$Res call({
 String text
});




}
/// @nodoc
class _$TextNodeCopyWithImpl<$Res>
    implements $TextNodeCopyWith<$Res> {
  _$TextNodeCopyWithImpl(this._self, this._then);

  final TextNode _self;
  final $Res Function(TextNode) _then;

/// Create a copy of ContentNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? text = null,}) {
  return _then(TextNode(
null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class MarkNode implements ContentNode {
  const MarkNode(this.key, { List<String> args = const [],  Map<String, String> named = const {},  List<ContentNode>? content}): _args = args,_named = named,_content = content;
  

 final  String key;
 final  List<String> _args;
@JsonKey() List<String> get args {
  if (_args is EqualUnmodifiableListView) return _args;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_args);
}

 final  Map<String, String> _named;
@JsonKey() Map<String, String> get named {
  if (_named is EqualUnmodifiableMapView) return _named;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_named);
}

 final  List<ContentNode>? _content;
 List<ContentNode>? get content {
  final value = _content;
  if (value == null) return null;
  if (_content is EqualUnmodifiableListView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ContentNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MarkNodeCopyWith<MarkNode> get copyWith => _$MarkNodeCopyWithImpl<MarkNode>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MarkNode&&(identical(other.key, key) || other.key == key)&&const DeepCollectionEquality().equals(other.args, _args)&&const DeepCollectionEquality().equals(other.named, _named)&&const DeepCollectionEquality().equals(other.content, _content));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,const DeepCollectionEquality().hash(_args),const DeepCollectionEquality().hash(_named),const DeepCollectionEquality().hash(_content));
}

@override
String toString() {
    return 'ContentNode.mark(key: $key, args: $args, named: $named, content: $content)';
}


}

/// @nodoc
abstract mixin class $MarkNodeCopyWith<$Res> implements $ContentNodeCopyWith<$Res> {
  factory $MarkNodeCopyWith(MarkNode value, $Res Function(MarkNode) _then) = _$MarkNodeCopyWithImpl;
@useResult
$Res call({
 String key, List<String> args, Map<String, String> named, List<ContentNode>? content
});




}
/// @nodoc
class _$MarkNodeCopyWithImpl<$Res>
    implements $MarkNodeCopyWith<$Res> {
  _$MarkNodeCopyWithImpl(this._self, this._then);

  final MarkNode _self;
  final $Res Function(MarkNode) _then;

/// Create a copy of ContentNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? key = null,Object? args = null,Object? named = null,Object? content = freezed,}) {
  return _then(MarkNode(
null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,args: null == args ? _self._args : args // ignore: cast_nullable_to_non_nullable
as List<String>,named: null == named ? _self._named : named // ignore: cast_nullable_to_non_nullable
as Map<String, String>,content: freezed == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as List<ContentNode>?,
  ));
}


}

// dart format on
