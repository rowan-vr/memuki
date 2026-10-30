import 'content_node.dart';
import 'content_parser.dart';

/// Writes [nodes] as content source, in the canonical form: arguments are
/// quoted only when they need it, and only `\`, `{`, and `}` are escaped in
/// text, plus whitespace at the ends of a mark's content, which would
/// otherwise be dropped.
///
/// [parseContent] reads the result back to [nodes], with adjacent text
/// nodes joined and empty ones left out. Throws an [ArgumentError] when a
/// mark key or argument name is not valid (see [isContentKey]).
String writeContent(List<ContentNode> nodes) {
  final out = StringBuffer();
  _writeNodes(out, nodes, inMark: false);
  return out.toString();
}

void _writeNodes(
  StringBuffer out,
  List<ContentNode> nodes, {
  required bool inMark,
}) {
  // Joined, as the parser would read them, so the ends of a mark's content
  // are the ends of its first and last text.
  final joined = <ContentNode>[];
  for (final node in nodes) {
    if (node case TextNode(:final text)) {
      if (text.isEmpty) continue;
      if (joined.lastOrNull case TextNode(text: final previous)) {
        joined[joined.length - 1] = ContentNode.text(previous + text);
        continue;
      }
    }
    joined.add(node);
  }
  for (final (i, node) in joined.indexed) {
    switch (node) {
      case TextNode(:final text):
        _writeText(
          out,
          text,
          protectStart: inMark && i == 0,
          protectEnd: inMark && i == joined.length - 1,
        );
      case MarkNode():
        _writeMark(out, node);
    }
  }
}

void _writeText(
  StringBuffer out,
  String text, {
  required bool protectStart,
  required bool protectEnd,
}) {
  final last = text.length - 1;
  for (var i = 0; i < text.length; i++) {
    final c = text.codeUnitAt(i);
    final edge =
        isContentSpace(c) &&
        ((protectStart && i == 0) || (protectEnd && i == last));
    if (edge || c == 0x5C || c == 0x7B || c == 0x7D) out.write(r'\');
    out.writeCharCode(c);
  }
}

void _writeMark(StringBuffer out, MarkNode mark) {
  if (!isContentKey(mark.key)) {
    throw ArgumentError.value(mark.key, 'key', 'is not a valid mark key');
  }
  out
    ..write('{')
    ..write(mark.key);
  for (final arg in mark.args) {
    out
      ..write(' ')
      ..write(_argument(arg));
  }
  for (final MapEntry(:key, :value) in mark.named.entries) {
    if (!isContentKey(key)) {
      throw ArgumentError.value(key, 'named', 'is not a valid argument name');
    }
    out
      ..write(' ')
      ..write(key)
      ..write('=')
      ..write(_argument(value));
  }
  if (mark.content case final content?) {
    out.write(content.isEmpty ? ' |' : ' | ');
    _writeNodes(out, content, inMark: true);
  }
  out.write('}');
}

/// [value] as an argument: as it is when it can stand unquoted, otherwise
/// quoted with `"` and `\` escaped.
String _argument(String value) {
  if (_bare.hasMatch(value)) return value;
  final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  return '"$escaped"';
}

final _bare = RegExp(r'^[^\s"{}|=\\]+$');
