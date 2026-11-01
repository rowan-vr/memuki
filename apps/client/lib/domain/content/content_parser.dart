import 'package:meta/meta.dart';

import 'content_node.dart';

/// What is wrong at a place in content source.
enum ContentProblemKind {
  /// A `{` starts a mark that is never closed with `}`.
  unclosedMark,

  /// A `}` outside any mark.
  unexpectedClose,

  /// A `{` is not followed by a valid mark: a key, then arguments.
  invalidMark,

  /// A quoted argument has no closing `"`.
  unterminatedQuote,

  /// The source ends with a single `\`.
  trailingBackslash,

  /// A named argument is given more than once; the last value is used.
  duplicateArgument,

  /// Marks are nested more than [maxContentDepth] deep.
  tooDeep,
}

/// A problem in content source at [offset], a UTF-16 index.
@immutable
class ContentProblem {
  const ContentProblem(this.kind, this.offset);

  final ContentProblemKind kind;
  final int offset;

  @override
  bool operator ==(Object other) =>
      other is ContentProblem && other.kind == kind && other.offset == offset;

  @override
  int get hashCode => Object.hash(kind, offset);

  @override
  String toString() => 'ContentProblem(${kind.name} at $offset)';
}

/// Content read from source, with the problems found in it.
@immutable
class ParsedContent {
  const ParsedContent(this.nodes, this.problems);

  final List<ContentNode> nodes;

  /// Empty when the source is well formed.
  final List<ContentProblem> problems;
}

/// How deeply marks may be nested. A deeper mark is kept as literal text.
const maxContentDepth = 64;

/// Reads content from [source].
///
/// Reading never fails, and takes time linear in the length of [source] for
/// all but contrived input. Malformed parts are kept as literal text, so no
/// text is lost, and reported in [ParsedContent.problems]: a mark that is
/// never closed keeps its opening `{key … |` as text and its content as read,
/// and a mark nested more than [maxContentDepth] deep is kept whole as text.
/// Whitespace right after a mark's `|` and right before its `}` is not part
/// of its content; `\` before a character, including a space, makes it
/// literal.
///
/// `{#` starts a comment, which runs to the matching `}`: braces inside it
/// must pair up or be escaped, and whitespace at its ends is dropped.
ParsedContent parseContent(String source) => _Parser(source).parse();

/// Whether [key] can name a mark kind or a named argument: a letter, then
/// letters, digits, `_`, `-`, `.`, or `:`.
bool isContentKey(String key) => _key.hasMatch(key);

final _key = RegExp(r'^[A-Za-z][A-Za-z0-9_.:\-]*$');

bool _isKeyStart(int c) => (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);

bool _isKeyPart(int c) =>
    _isKeyStart(c) ||
    (c >= 0x30 && c <= 0x39) ||
    c == 0x5F || // _
    c == 0x2D || // -
    c == 0x2E || // .
    c == 0x3A; // :

/// Whitespace between a mark's parts and at the ends of its content.
bool isContentSpace(int c) => c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D;

/// Characters that end an unquoted argument.
bool _endsBare(int c) =>
    isContentSpace(c) ||
    c == _quote ||
    c == _open ||
    c == _close ||
    c == _bar ||
    c == _equals ||
    c == _backslash;

const _open = 0x7B; // {
const _close = 0x7D; // }
const _bar = 0x7C; // |
const _backslash = 0x5C; // \
const _quote = 0x22; // "
const _equals = 0x3D; // =
const _hash = 0x23; // #

/// Text being collected, with how much of its end is protected from trimming
/// by an escape.
class _Text {
  final buffer = StringBuffer();

  /// The length up to and including the last escaped character.
  int protectedLength = 0;

  void add(String s) => buffer.write(s);

  void addEscaped(String s) {
    buffer.write(s);
    protectedLength = buffer.length;
  }

  /// The text, with trailing whitespace that is not protected dropped when
  /// [trimEnd].
  String value({bool trimEnd = false}) {
    final value = buffer.toString();
    if (!trimEnd) return value;
    var end = value.length;
    while (end > protectedLength && isContentSpace(value.codeUnitAt(end - 1))) {
      end--;
    }
    return value.substring(0, end);
  }
}

/// A mark's opening `{key … |` or whole `{key …}`, or why there is none.
typedef _Head = ({
  String key,
  List<String> args,
  Map<String, String> named,

  /// Whether a `|` follows, so content and a closing `}` come next.
  bool hasContent,

  /// Where the content starts, after the `|` and any whitespace; or after
  /// the `}` when there is no content.
  int end,
  List<ContentProblem> problems,
  ContentProblemKind? failure,
  int failureOffset,
});

/// An open mark, or the top level.
class _Frame {
  _Frame(this.start, this.head);

  final int start;
  final _Head? head;
  final nodes = <ContentNode>[];
  final text = _Text();

  /// Ends the text collected so far, with trailing whitespace dropped when
  /// [trimEnd].
  void flush({bool trimEnd = false}) {
    final value = text.value(trimEnd: trimEnd);
    if (value.isNotEmpty) nodes.add(ContentNode.text(value));
    text.buffer.clear();
    text.protectedLength = 0;
  }

  void addNode(ContentNode node) {
    if (node case TextNode(:final text)) {
      this.text.add(text);
    } else {
      flush();
      nodes.add(node);
    }
  }
}

class _Parser {
  _Parser(this.source);

  final String source;
  final problems = <ContentProblem>[];

  int get _length => source.length;

  int _at(int i) => source.codeUnitAt(i);

  /// The character at [i], both halves of a surrogate pair together.
  String _charAt(int i) {
    final c = _at(i);
    if (c >= 0xD800 && c <= 0xDBFF && i + 1 < _length) {
      final next = _at(i + 1);
      if (next >= 0xDC00 && next <= 0xDFFF) return source.substring(i, i + 2);
    }
    return String.fromCharCode(c);
  }

  ParsedContent parse() {
    final stack = [_Frame(0, null)];
    // While above zero, marks nested too deeply are being passed over:
    // how many are open, and where the outermost started.
    var skipping = 0;
    var skipStart = 0;
    var pos = 0;
    while (pos < _length) {
      final c = _at(pos);
      final top = stack.last;
      if (c == _backslash) {
        if (pos + 1 < _length) {
          final escaped = _charAt(pos + 1);
          if (skipping == 0) top.text.addEscaped(escaped);
          pos += 1 + escaped.length;
        } else {
          problems.add(
            ContentProblem(ContentProblemKind.trailingBackslash, pos),
          );
          if (skipping == 0) top.text.add(r'\');
          pos++;
        }
      } else if (c == _open && pos + 1 < _length && _at(pos + 1) == _hash) {
        final comment = _comment(pos);
        if (comment == null) {
          if (skipping == 0) {
            problems.add(ContentProblem(ContentProblemKind.unclosedMark, pos));
            top.text.add('{');
          }
          pos++;
        } else {
          if (skipping == 0) top.addNode(ContentNode.comment(comment.text));
          pos = comment.end;
        }
      } else if (c == _open) {
        final head = _head(pos);
        if (head.failure != null) {
          if (skipping == 0) {
            problems.add(ContentProblem(head.failure!, head.failureOffset));
            top.text.add('{');
          }
          pos++;
        } else if (skipping > 0) {
          if (head.hasContent) skipping++;
          pos = head.end;
        } else if (stack.length > maxContentDepth) {
          problems.add(ContentProblem(ContentProblemKind.tooDeep, pos));
          if (head.hasContent) {
            skipping = 1;
            skipStart = pos;
          } else {
            top.text.add(source.substring(pos, head.end));
          }
          pos = head.end;
        } else if (head.hasContent) {
          stack.add(_Frame(pos, head));
          pos = head.end;
        } else {
          top.addNode(_markOf(head, null));
          problems.addAll(head.problems);
          pos = head.end;
        }
      } else if (c == _close) {
        if (skipping > 0) {
          skipping--;
          if (skipping == 0) top.text.add(source.substring(skipStart, pos + 1));
        } else if (stack.length > 1) {
          final frame = stack.removeLast()..flush(trimEnd: true);
          stack.last.addNode(_markOf(frame.head!, frame.nodes));
          problems.addAll(frame.head!.problems);
        } else {
          problems.add(ContentProblem(ContentProblemKind.unexpectedClose, pos));
          top.text.add('}');
        }
        pos++;
      } else {
        if (skipping == 0) top.text.add(String.fromCharCode(c));
        pos++;
      }
    }
    if (skipping > 0) {
      problems.add(ContentProblem(ContentProblemKind.unclosedMark, skipStart));
      stack.last.text.add(source.substring(skipStart));
    }
    // Marks still open keep their opening as text, followed by their content.
    while (stack.length > 1) {
      final frame = stack.removeLast()..flush();
      problems.add(
        ContentProblem(ContentProblemKind.unclosedMark, frame.start),
      );
      final parent = stack.last
        ..text.add(source.substring(frame.start, frame.head!.end));
      frame.nodes.forEach(parent.addNode);
    }
    final root = stack.single..flush();
    problems.sort((a, b) => a.offset.compareTo(b.offset));
    return ParsedContent(
      List.unmodifiable(root.nodes),
      List.unmodifiable(problems),
    );
  }

  MarkNode _markOf(_Head head, List<ContentNode>? content) => ContentNode.mark(
    head.key,
    args: head.args,
    named: head.named,
    content: content,
  ) as MarkNode;

  /// Reads the comment starting at [start], which is at a `{#`; null when it
  /// is never closed.
  ({String text, int end})? _comment(int start) {
    final text = _Text();
    var pos = start + 2;
    while (pos < _length && isContentSpace(_at(pos))) {
      pos++;
    }
    var depth = 0;
    while (pos < _length) {
      final c = _at(pos);
      if (c == _backslash && pos + 1 < _length) {
        final escaped = _charAt(pos + 1);
        text.addEscaped(escaped);
        pos += 1 + escaped.length;
        continue;
      }
      if (c == _close) {
        if (depth == 0) return (text: text.value(trimEnd: true), end: pos + 1);
        depth--;
      } else if (c == _open) {
        depth++;
      }
      final char = _charAt(pos);
      text.add(char);
      pos += char.length;
    }
    return null;
  }

  /// Reads the head of the mark starting at [start], which is at a `{`.
  _Head _head(int start) {
    _Head fail(ContentProblemKind kind, int offset) => (
      key: '',
      args: const [],
      named: const {},
      hasContent: false,
      end: 0,
      problems: const [],
      failure: kind,
      failureOffset: offset,
    );

    var pos = start + 1;
    if (pos >= _length || !_isKeyStart(_at(pos))) {
      return fail(ContentProblemKind.invalidMark, start);
    }
    final keyStart = pos;
    while (pos < _length && _isKeyPart(_at(pos))) {
      pos++;
    }
    final key = source.substring(keyStart, pos);
    final args = <String>[];
    final named = <String, String>{};
    final problems = <ContentProblem>[];

    int skipSpace() {
      final from = pos;
      while (pos < _length && isContentSpace(_at(pos))) {
        pos++;
      }
      return pos - from;
    }

    /// Reads a quoted or unquoted value; null when there is none or it is
    /// malformed. An empty unquoted value is accepted only when
    /// [allowEmpty].
    String? value({required bool allowEmpty}) {
      if (pos < _length && _at(pos) == _quote) {
        pos++;
        final out = StringBuffer();
        while (pos < _length) {
          final c = _at(pos);
          if (c == _quote) {
            pos++;
            return out.toString();
          }
          if (c == _backslash && pos + 1 < _length) {
            final escaped = _charAt(pos + 1);
            out.write(escaped);
            pos += 1 + escaped.length;
          } else {
            out.writeCharCode(c);
            pos++;
          }
        }
        return null;
      }
      final from = pos;
      while (pos < _length && !_endsBare(_at(pos))) {
        pos++;
      }
      if (pos == from && !allowEmpty) return null;
      // A value must be followed by a separator, `=`, `|`, or `}`.
      if (pos < _length &&
          (_at(pos) == _quote || _at(pos) == _backslash || _at(pos) == _open)) {
        return null;
      }
      return source.substring(from, pos);
    }

    _Head failValue(int at) => at < _length && _at(at) == _quote
        ? fail(ContentProblemKind.unterminatedQuote, at)
        : fail(ContentProblemKind.invalidMark, start);

    while (true) {
      final separated = skipSpace() > 0;
      if (pos >= _length) return fail(ContentProblemKind.unclosedMark, start);
      final c = _at(pos);
      if (c == _close || c == _bar) {
        pos++;
        if (c == _bar) skipSpace();
        return (
          key: key,
          args: args,
          named: named,
          hasContent: c == _bar,
          end: pos,
          problems: problems,
          failure: null,
          failureOffset: 0,
        );
      }
      // Arguments are separated from the key and each other by whitespace.
      if (!separated) return fail(ContentProblemKind.invalidMark, start);
      final argStart = pos;
      final arg = value(allowEmpty: false);
      if (arg == null) return failValue(argStart);
      if (pos < _length && _at(pos) == _equals && _at(argStart) != _quote) {
        // A name must be one the writer can write back.
        if (!isContentKey(arg)) {
          return fail(ContentProblemKind.invalidMark, start);
        }
        pos++;
        final valueStart = pos;
        final namedValue = value(allowEmpty: true);
        if (namedValue == null) return failValue(valueStart);
        if (named.remove(arg) != null) {
          problems.add(
            ContentProblem(ContentProblemKind.duplicateArgument, argStart),
          );
        }
        named[arg] = namedValue;
      } else {
        args.add(arg);
      }
    }
  }
}
