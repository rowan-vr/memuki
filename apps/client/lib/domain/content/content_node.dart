import 'package:freezed_annotation/freezed_annotation.dart';

part 'content_node.freezed.dart';

/// A piece of content: text, or a mark around further content.
///
/// Field values and templates are lists of nodes. Lists from the parser have
/// no empty text nodes and no two text nodes in a row.
@freezed
sealed class ContentNode with _$ContentNode {
  /// Plain text.
  const factory ContentNode.text(String text) = TextNode;

  /// A mark, written `{key arg … name="value" | content}`.
  ///
  /// [key] names the kind of mark. [args] are its positional arguments and
  /// [named] its named arguments. [content] is null when the mark has no `|`,
  /// and empty when it has one with nothing after it.
  const factory ContentNode.mark(
    String key, {
    @Default([]) List<String> args,
    @Default({}) Map<String, String> named,
    List<ContentNode>? content,
  }) = MarkNode;
}
