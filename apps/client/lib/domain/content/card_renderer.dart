import 'package:meta/meta.dart';

import 'content_node.dart';
import 'mark_kinds.dart';

/// A card's two sides as content, ready to be shown.
///
/// Each side is the content of the template's side with its template marks
/// resolved: an `if` is replaced by its content or dropped, `requires` and
/// comments are dropped, and a `field` keeps its name and role and takes the
/// field's value as its content. A field whose value is empty is dropped.
/// Other marks stay, with their content resolved the same way.
///
/// Marks of kinds shown only on request, such as `source`, are left out of a
/// field's value unless the field is placed with `show` naming their kind.
///
/// Whitespace in the template lays out the source: a run of it that holds a
/// line break becomes one line break, and each side is trimmed. Field values
/// are kept as they are.
@immutable
class RenderedCard {
  const RenderedCard({required this.front, required this.back});

  final List<ContentNode> front;
  final List<ContentNode> back;

  @override
  bool operator ==(Object other) =>
      other is RenderedCard &&
      _listEquals(other.front, front) &&
      _listEquals(other.back, back);

  @override
  int get hashCode => Object.hash(Object.hashAll(front), Object.hashAll(back));

  @override
  String toString() => 'RenderedCard(front: $front, back: $back)';
}

/// The card [template] makes from a note's [fields], by name.
///
/// A side the template does not have is empty, and so is a field that is not
/// in [fields]. Reading a template never fails, so neither does this: a
/// template with issues renders as far as it can.
RenderedCard renderCard(
  List<ContentNode> template,
  Map<String, List<ContentNode>> fields, {
  MarkKinds? kinds,
}) {
  final known = kinds ?? MarkKinds.builtIn;
  List<ContentNode> side(String key) {
    for (final node in template) {
      if (node case MarkNode(key: final k, :final content) when k == key) {
        return _layout(_resolve(content ?? const [], fields, known));
      }
    }
    return const [];
  }

  return RenderedCard(front: side('front'), back: side('back'));
}

/// Whether [nodes] show nothing: only comments and whitespace.
bool isEmptyContent(List<ContentNode> nodes) => nodes.every(
  (node) => switch (node) {
    TextNode(:final text) => text.trim().isEmpty,
    MarkNode() => false,
    CommentNode() => true,
  },
);

List<ContentNode> _resolve(
  List<ContentNode> nodes,
  Map<String, List<ContentNode>> fields,
  MarkKinds kinds,
) {
  List<ContentNode> value(String? name) => fields[name] ?? const [];
  return [
    for (final node in nodes)
      ...switch (node) {
        TextNode() => [node],
        CommentNode() => const <ContentNode>[],
        MarkNode(key: 'requires') => const <ContentNode>[],
        MarkNode(key: 'if', :final args, :final content) =>
          isEmptyContent(value(args.firstOrNull))
              ? const <ContentNode>[]
              : _resolve(content ?? const [], fields, kinds),
        MarkNode(key: 'field', :final args, :final named) =>
          isEmptyContent(value(args.firstOrNull))
              ? const <ContentNode>[]
              : [
                  node.copyWith(
                    content: _withoutHidden(value(args.firstOrNull), {
                      ...?named['show']?.split(RegExp(r'\s+')),
                    }, kinds),
                  ),
                ],
        MarkNode(:final content?) => [
          node.copyWith(content: _resolve(content, fields, kinds)),
        ],
        MarkNode() => [node],
      },
  ];
}

/// [nodes] without marks of kinds shown only on request, at any depth,
/// except those whose key is in [shown].
List<ContentNode> _withoutHidden(
  List<ContentNode> nodes,
  Set<String> shown,
  MarkKinds kinds,
) => [
  for (final node in nodes)
    if (node is! MarkNode)
      node
    else if (!(kinds[node.key]?.onRequest ?? false) || shown.contains(node.key))
      switch (node.content) {
        null => node,
        final content => node.copyWith(
          content: _withoutHidden(content, shown, kinds),
        ),
      },
];

final _layoutBreak = RegExp(r'[ \t]*\n\s*');

/// [nodes] with neighbouring text joined, layout whitespace in the template's
/// text collapsed to line breaks, and the ends trimmed. Text inside a `field`
/// is its value, and is left alone.
List<ContentNode> _layout(List<ContentNode> nodes, {bool top = true}) {
  final out = <ContentNode>[];
  for (final node in nodes) {
    final ContentNode next = switch (node) {
      TextNode(:final text) => ContentNode.text(
        text.replaceAll(_layoutBreak, '\n'),
      ),
      MarkNode(key: 'field') => node,
      MarkNode(:final content?) => node.copyWith(
        content: _layout(content, top: false),
      ),
      _ => node,
    };
    if (next case TextNode(:final text)) {
      if (out.lastOrNull case TextNode(text: final before)) {
        out.last = ContentNode.text(
          '$before$text'.replaceAll(_layoutBreak, '\n'),
        );
        continue;
      }
    }
    out.add(next);
  }
  if (top) {
    if (out.firstOrNull case TextNode(:final text)) {
      out.first = ContentNode.text(text.trimLeft());
    }
    if (out.lastOrNull case TextNode(:final text)) {
      out.last = ContentNode.text(text.trimRight());
    }
  }
  return [
    for (final node in out)
      if (node is! TextNode || node.text.isNotEmpty) node,
  ];
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
