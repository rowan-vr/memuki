import 'package:meta/meta.dart';

import 'content_node.dart';

/// Stands in the text for a node that is not edited as text: a comment, or a
/// mark without content. Flutter uses the same character for inline widgets.
const atomChar = '￼';

/// A mark over `start..end` of a [MarkedText], or an atom: one [atomChar] at
/// `start` that holds a whole node.
@immutable
class MarkRange {
  const MarkRange(this.start, this.end, this.node, {this.atom = false});

  final int start;
  final int end;

  /// The mark with its content left out, or for an atom the whole node.
  final ContentNode node;
  final bool atom;

  /// The mark's key; null for an atom that is a comment.
  String? get key => switch (node) {
    MarkNode(:final key) => key,
    _ => null,
  };

  MarkRange moved(int start, int end) =>
      MarkRange(start, end, node, atom: atom);

  MarkRange withNode(ContentNode node) =>
      MarkRange(start, end, node, atom: atom);

  bool contains(int start, int end) => this.start <= start && end <= this.end;

  @override
  bool operator ==(Object other) =>
      other is MarkRange &&
      other.start == start &&
      other.end == end &&
      other.node == node &&
      other.atom == atom;

  @override
  int get hashCode => Object.hash(start, end, node, atom);

  @override
  String toString() => '${key ?? '#'}[$start, $end)';
}

/// Content as plain text with its marks as ranges over it, the form a text
/// field edits.
///
/// Ranges nest: two are either apart or one contains the other, and outer
/// ranges come first. Marks without content and comments are atoms, so
/// nothing is lost on the way to text and back. A literal [atomChar] in the
/// content becomes U+FFFD.
@immutable
class MarkedText {
  const MarkedText(this.text, this.ranges);

  factory MarkedText.fromNodes(List<ContentNode> nodes) {
    final out = StringBuffer();
    final ranges = <MarkRange>[];
    void add(List<ContentNode> nodes) {
      for (final node in nodes) {
        switch (node) {
          case TextNode(:final text):
            out.write(text.replaceAll(atomChar, '�'));
          case MarkNode(:final content?) when content.isNotEmpty:
            final start = out.length;
            final index = ranges.length;
            ranges.add(MarkRange(start, start, node.copyWith(content: null)));
            add(content);
            ranges[index] = ranges[index].moved(start, out.length);
          default:
            ranges.add(MarkRange(out.length, out.length + 1, node, atom: true));
            out.write(atomChar);
        }
      }
    }

    add(nodes);
    return MarkedText(out.toString(), List.unmodifiable(ranges));
  }

  final String text;
  final List<MarkRange> ranges;

  /// The content as nodes.
  List<ContentNode> toNodes() {
    final sorted = nested(ranges);
    var i = 0;
    List<ContentNode> build(int from, int to) {
      final out = <ContentNode>[];
      var pos = from;
      while (i < sorted.length && sorted[i].start < to) {
        final r = sorted[i++];
        if (r.start > pos) {
          out.add(ContentNode.text(text.substring(pos, r.start)));
        }
        out.add(
          r.atom
              ? r.node
              : (r.node as MarkNode).copyWith(content: build(r.start, r.end)),
        );
        pos = r.end;
      }
      if (pos < to) out.add(ContentNode.text(text.substring(pos, to)));
      return out;
    }

    return build(0, text.length);
  }
}

/// [ranges] ordered outer first, with ranges that cross split so that they
/// nest. Of two ranges over the same text, the earlier one stays outer.
List<MarkRange> nested(List<MarkRange> ranges) {
  final pending = ranges.indexed.toList()
    ..sort((a, b) {
      final (ia, ra) = a;
      final (ib, rb) = b;
      if (ra.start != rb.start) return ra.start.compareTo(rb.start);
      if (ra.end != rb.end) return rb.end.compareTo(ra.end);
      return ia.compareTo(ib);
    });
  final queue = [for (final (_, r) in pending) r];
  final out = <MarkRange>[];
  final open = <MarkRange>[];
  while (queue.isNotEmpty) {
    final r = queue.removeAt(0);
    open.removeWhere((o) => o.end <= r.start);
    final crossing = open.where((o) => o.end < r.end).firstOrNull;
    if (crossing == null) {
      out.add(r);
      open.add(r);
      continue;
    }
    // Split at the end of the range it crosses; the rest waits its turn.
    final head = r.moved(r.start, crossing.end);
    out.add(head);
    open.add(head);
    final rest = r.moved(crossing.end, r.end);
    final at = queue.indexWhere(
      (q) =>
          q.start > rest.start || (q.start == rest.start && q.end < rest.end),
    );
    queue.insert(at < 0 ? queue.length : at, rest);
  }
  return out;
}

/// Whether text typed right after a mark of [key] joins it. A ruby's reading
/// belongs to exactly its base text, so typing after a ruby does not.
bool extendsAtEnd(String? key) => key != 'ruby';

/// [ranges] after the text changed from [before] to [after].
///
/// The change is found by comparing the two. Where repeated characters make
/// that ambiguous, [cursor], the collapsed selection after the change, says
/// where the text was typed. Text typed inside a mark joins it, and so does
/// text typed at its end when [extendsAtEnd] allows; text typed at its start
/// does not. Text replacing the start of a mark, as an input method does
/// when it converts, joins it. A mark whose text is all deleted is removed,
/// and so is an atom whose character is.
List<MarkRange> shiftRanges(
  List<MarkRange> ranges,
  String before,
  String after, {
  int? cursor,
}) {
  if (before == after) return ranges;
  final shortest = before.length < after.length ? before.length : after.length;
  var p = 0;
  while (p < shortest && before.codeUnitAt(p) == after.codeUnitAt(p)) {
    p++;
  }
  var s = 0;
  while (s < shortest - p &&
      before.codeUnitAt(before.length - 1 - s) ==
          after.codeUnitAt(after.length - 1 - s)) {
    s++;
  }
  var del = before.length - p - s;
  final ins = after.length - p - s;
  if (cursor != null && del == 0 && cursor - ins >= 0 && cursor - ins < p) {
    final q = cursor - ins;
    if (before.substring(q) == after.substring(q + ins)) {
      p = q;
      del = 0;
    }
  }
  final shift = ins - del;
  final out = <MarkRange>[];
  for (final r in ranges) {
    if (r.atom) {
      if (r.start >= p && r.start < p + del) continue;
      out.add(r.start >= p + del ? r.moved(r.start + shift, r.end + shift) : r);
      continue;
    }
    final joins =
        (r.start < p && p < r.end) ||
        (r.start == p && del > 0 && p < r.end) ||
        (r.end == p && r.start < p && extendsAtEnd(r.key));
    final int start;
    if (r.start < p) {
      start = r.start;
    } else if (r.start == p && joins) {
      start = p;
    } else if (r.start >= p + del) {
      start = r.start + shift;
    } else {
      start = p + ins;
    }
    final int end;
    if (r.end < p || (r.end == p && del == 0 && !joins)) {
      end = r.end;
    } else if (r.end >= p + del && !(r.end == p && del == 0)) {
      end = r.end + shift;
    } else {
      end = joins ? p + ins : p;
    }
    if (end > start) out.add(r.moved(start, end));
  }
  return out;
}

/// Whether text from [start] to [end] is all inside marks of [key]: at the
/// cursor when [start] equals [end].
bool hasMark(List<MarkRange> ranges, String key, int start, int end) {
  if (start == end) {
    return ranges.any(
      (r) => !r.atom && r.key == key && r.start <= start && start <= r.end,
    );
  }
  var pos = start;
  for (final r in nested(ranges).where((r) => !r.atom && r.key == key)) {
    if (r.start <= pos && pos < r.end) pos = r.end;
  }
  return pos >= end;
}

/// [ranges] with [mark] toggled over `start..end`.
///
/// When that text is all marked with the same kind already, the mark is
/// taken off it, and the parts outside stay marked; with a collapsed
/// selection, the innermost mark of that kind at the cursor is taken off
/// whole. Otherwise [mark] is added, joining marks equal to it that it
/// touches or overlaps.
List<MarkRange> toggleMark(
  List<MarkRange> ranges,
  MarkNode mark,
  int start,
  int end,
) {
  final key = mark.key;
  if (start == end) {
    final at = nested(ranges)
        .where(
          (r) => !r.atom && r.key == key && r.start <= start && start <= r.end,
        )
        .lastOrNull;
    if (at == null) return ranges;
    return [
      for (final r in ranges)
        if (r != at) r,
    ];
  }
  if (hasMark(ranges, key, start, end)) {
    return nested([
      for (final r in ranges)
        if (r.atom || r.key != key || r.end <= start || end <= r.start)
          r
        else ...[
          if (r.start < start) r.moved(r.start, start),
          if (end < r.end) r.moved(end, r.end),
        ],
    ]);
  }
  var from = start;
  var to = end;
  final joined = <MarkRange>[];
  for (final r in ranges) {
    if (!r.atom && r.node == mark && r.start <= to && from <= r.end) {
      joined.add(r);
      if (r.start < from) from = r.start;
      if (r.end > to) to = r.end;
    }
  }
  return nested([
    for (final r in ranges)
      if (!joined.contains(r)) r,
    MarkRange(from, to, mark),
  ]);
}
