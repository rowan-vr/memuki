import 'package:meta/meta.dart';

import 'content_node.dart';
import 'content_writer.dart';
import 'mark_kinds.dart';

/// The roles a field can be placed in that cards style. A template may name
/// others; they are kept, and shown as body text.
const fieldRoles = ['prompt', 'reading', 'answer', 'example'];

/// One line of a side of a template, as the template editor arranges it.
sealed class TemplateBlock {
  const TemplateBlock();
}

/// A field on a line of its own: `{field Word role=prompt}`.
@immutable
class FieldBlock extends TemplateBlock {
  const FieldBlock(this.name, {this.role, this.display, this.show});

  final String name;

  /// Null when the field has no role.
  final String? role;

  /// How the value is shown instead of as text, such as `badges`.
  final String? display;

  /// The kinds shown only on request to show anyway, such as `source forms`.
  final String? show;

  FieldBlock withName(String name) =>
      FieldBlock(name, role: role, display: display, show: show);
  FieldBlock withRole(String? role) =>
      FieldBlock(name, role: role, display: display, show: show);

  @override
  bool operator ==(Object other) =>
      other is FieldBlock &&
      other.name == name &&
      other.role == role &&
      other.display == display &&
      other.show == show;

  @override
  int get hashCode => Object.hash(name, role, display, show);

  @override
  String toString() => 'FieldBlock($name, $role, $display, $show)';
}

/// Lines shown only when [name] is not empty: `{if Example | …}`. Its
/// lines are never conditions themselves; a nested `if` is a [SourceBlock].
@immutable
class IfBlock extends TemplateBlock {
  const IfBlock(this.name, this.blocks);

  final String name;
  final List<TemplateBlock> blocks;

  IfBlock withName(String name) => IfBlock(name, blocks);
  IfBlock withBlocks(List<TemplateBlock> blocks) => IfBlock(name, blocks);

  @override
  bool operator ==(Object other) =>
      other is IfBlock &&
      other.name == name &&
      _listEquals(other.blocks, blocks);

  @override
  int get hashCode => Object.hash(name, Object.hashAll(blocks));

  @override
  String toString() => 'IfBlock($name, $blocks)';
}

/// A line of text, with the marks a field may have, such as `em` or `ruby`.
@immutable
class TextBlock extends TemplateBlock {
  const TextBlock(this.content);

  final List<ContentNode> content;

  @override
  bool operator ==(Object other) =>
      other is TextBlock && _listEquals(other.content, content);

  @override
  int get hashCode => Object.hashAll(content);

  @override
  String toString() => 'TextBlock($content)';
}

/// A line that is none of the others, such as a field inside text or an `em`
/// around a field. It is kept as it is and edited as source.
@immutable
class SourceBlock extends TemplateBlock {
  const SourceBlock(this.content);

  final List<ContentNode> content;

  @override
  bool operator ==(Object other) =>
      other is SourceBlock && _listEquals(other.content, content);

  @override
  int get hashCode => Object.hashAll(content);

  @override
  String toString() => 'SourceBlock($content)';
}

/// A template as the template editor arranges it: the lines of its front and
/// back, the fields it requires, and the comments outside its sides.
@immutable
class TemplateLayout {
  const TemplateLayout({
    this.front = const [],
    this.back = const [],
    this.requires = const [],
    this.comments = const [],
  });

  /// [template] arranged in lines, or null when its top level is not a
  /// front, a back, and optionally `requires`, with only whitespace and
  /// comments outside them. Such a template is edited as source.
  ///
  /// A side is split at the line breaks in its text. A line with only a field
  /// is a [FieldBlock], and one with only an `if` is an [IfBlock] whose
  /// content is split the same way. A line with no template marks is a
  /// [TextBlock], and any other line a [SourceBlock].
  static TemplateLayout? read(List<ContentNode> template) {
    List<TemplateBlock>? front;
    List<TemplateBlock>? back;
    final requires = <String>[];
    final comments = <CommentNode>[];
    for (final node in template) {
      switch (node) {
        case TextNode(:final text) when text.trim().isEmpty:
          break;
        case CommentNode():
          comments.add(node);
        case MarkNode(key: 'front', :final content?) when front == null:
          front = _blocks(content, conditions: true);
        case MarkNode(key: 'back', :final content?) when back == null:
          back = _blocks(content, conditions: true);
        case MarkNode(key: 'requires', content: null, :final args):
          requires.addAll(args.where((a) => !requires.contains(a)));
        default:
          return null;
      }
    }
    if (front == null || back == null) return null;
    return TemplateLayout(
      front: front,
      back: back,
      requires: requires,
      comments: comments,
    );
  }

  final List<TemplateBlock> front;
  final List<TemplateBlock> back;

  /// The fields a note must fill for the template to make a card, in order.
  final List<String> requires;

  /// Comments outside the sides. They are written before the front.
  final List<CommentNode> comments;

  TemplateLayout copyWith({
    List<TemplateBlock>? front,
    List<TemplateBlock>? back,
    List<String>? requires,
  }) => TemplateLayout(
    front: front ?? this.front,
    back: back ?? this.back,
    requires: requires ?? this.requires,
    comments: comments,
  );

  /// The template as source, one line to a block and indented by depth.
  /// Reading it gives back this layout.
  String write() {
    final out = StringBuffer();
    for (final comment in comments) {
      out.writeln(writeContent([comment]));
    }
    _writeSide(out, 'front', front);
    out.writeln();
    _writeSide(out, 'back', back);
    if (requires.isNotEmpty) {
      out
        ..writeln()
        ..write(writeContent([ContentNode.mark('requires', args: requires)]));
    }
    return out.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is TemplateLayout &&
      _listEquals(other.front, front) &&
      _listEquals(other.back, back) &&
      _listEquals(other.requires, requires) &&
      _listEquals(other.comments, comments);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(front),
    Object.hashAll(back),
    Object.hashAll(requires),
    Object.hashAll(comments),
  );

  @override
  String toString() =>
      'TemplateLayout(front: $front, back: $back, requires: $requires)';
}

/// [content] split into lines, each line a block.
List<TemplateBlock> _blocks(
  List<ContentNode> content, {
  required bool conditions,
}) {
  final lines = <List<ContentNode>>[[]];
  for (final node in content) {
    if (node case TextNode(:final text)) {
      final parts = text.split('\n');
      for (final (i, part) in parts.indexed) {
        if (i > 0) lines.add([]);
        if (part.isNotEmpty) lines.last.add(ContentNode.text(part));
      }
    } else {
      lines.last.add(node);
    }
  }
  return [
    for (final line in lines.map(_trimmed))
      if (line.isNotEmpty) _block(line, conditions: conditions),
  ];
}

TemplateBlock _block(List<ContentNode> line, {required bool conditions}) {
  if (line
      case [MarkNode(key: 'field', :final args, :final named, content: null)]
      when args.length == 1 && named.keys.every(_fieldOptions.contains)) {
    return FieldBlock(
      args.single,
      role: named['role'],
      display: named['display'],
      show: named['show'],
    );
  }
  if (line case [MarkNode(key: 'if', :final args, :final content?)]
      when conditions && args.length == 1) {
    return IfBlock(args.single, _blocks(content, conditions: false));
  }
  if (_inField(line)) return TextBlock(line);
  return SourceBlock(line);
}

const _fieldOptions = {'role', 'display', 'show'};

/// Whether [nodes] have only marks that belong in fields, at any depth.
bool _inField(List<ContentNode> nodes) => nodes.every(
  (node) => switch (node) {
    MarkNode(:final key, :final content) =>
      (MarkKinds.builtIn[key]?.scopes.contains(MarkScope.field) ?? false) &&
          _inField(content ?? const []),
    _ => true,
  },
);

/// [line] without whitespace at its ends.
List<ContentNode> _trimmed(List<ContentNode> line) {
  final out = [...line];
  if (out.firstOrNull case TextNode(:final text)) {
    out.first = ContentNode.text(text.trimLeft());
  }
  if (out.lastOrNull case TextNode(:final text)) {
    out.last = ContentNode.text(text.trimRight());
  }
  return [
    for (final node in out)
      if (node is! TextNode || node.text.isNotEmpty) node,
  ];
}

void _writeSide(StringBuffer out, String key, List<TemplateBlock> blocks) {
  out.write('{$key |\n');
  for (final block in blocks) {
    out.writeln('  ${_line(block, '  ')}');
  }
  out.write('}');
}

/// [block] as source, starting at [indent] and without a final line break.
String _line(TemplateBlock block, String indent) => switch (block) {
  FieldBlock(:final name, :final role, :final display, :final show) =>
    writeContent([
      ContentNode.mark(
        'field',
        args: [name],
        named: {'role': ?role, 'display': ?display, 'show': ?show},
      ),
    ]),
  IfBlock() => _condition(block, indent),
  TextBlock(:final content) ||
  SourceBlock(:final content) => writeContent(content),
};

/// An `if` on one line when it holds one block, or else over several.
String _condition(IfBlock block, String indent) {
  // The opening of the mark, without its closing brace.
  final mark = writeContent([
    ContentNode.mark('if', args: [block.name]),
  ]);
  final open = '${mark.substring(0, mark.length - 1)} |';
  if (block.blocks case [final only]) return '$open ${_line(only, indent)}}';
  final inner = '$indent  ';
  return [
    open,
    for (final b in block.blocks) '$inner${_line(b, inner)}',
    '$indent}',
  ].join('\n');
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
