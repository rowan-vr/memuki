import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_node.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/content_writer.dart';
import 'package:memuki/domain/content/marked_text.dart';

MarkedText _read(String source) =>
    MarkedText.fromNodes(parseContent(source).nodes);

String _write(MarkedText t) => writeContent(t.toNodes());

/// [source] after its text changes to [after].
String _edit(String source, String after, {int? cursor}) {
  final t = _read(source);
  return _write(
    MarkedText(after, shiftRanges(t.ranges, t.text, after, cursor: cursor)),
  );
}

/// [source] with [key] toggled over `start..end` of its text.
String _toggle(
  String source,
  String key,
  int start,
  int end, {
  List<String> args = const [],
}) {
  final t = _read(source);
  final mark = ContentNode.mark(key, args: args) as MarkNode;
  return _write(MarkedText(t.text, toggleMark(t.ranges, mark, start, end)));
}

void main() {
  group('converting', () {
    test('content reads back as it was', () {
      for (final source in [
        '今日は{ruby てんき | 天気}が{em | いい}です。',
        '{lang zh-Hans | {ruby "nǐ hǎo" | 你好}}',
        'H{sub | 2}O and x{sup | 2}',
        'a{# note}b{pitch 0}c{x |}d',
        '{em | {em | a}}',
        '{em | a{ruby x | b}c}',
        '{em | {# only a comment}}',
        '',
        r'\{ \} \\',
      ]) {
        expect(
          _write(_read(source)),
          writeContent(parseContent(source).nodes),
          reason: source,
        );
      }
    });

    test('generated content reads back as it was', () {
      final random = Random(3);
      const keys = ['em', 'ruby', 'x'];
      List<ContentNode> generate(int depth) => [
        for (var i = random.nextInt(4); i > 0; i--)
          switch (random.nextInt(depth == 0 ? 2 : 5)) {
            0 => ContentNode.text(['a', 'bc', ' ', '漢'][random.nextInt(4)]),
            1 => ContentNode.comment('c$i'),
            _ => ContentNode.mark(
              keys[random.nextInt(keys.length)],
              args: [if (random.nextBool()) 'r'],
              content: random.nextInt(5) == 0 ? null : generate(depth - 1),
            ),
          },
      ];
      for (var i = 0; i < 2000; i++) {
        final nodes = parseContent(writeContent(generate(3))).nodes;
        expect(
          MarkedText.fromNodes(nodes).toNodes(),
          nodes,
          reason: writeContent(nodes),
        );
      }
    });

    test('atoms are single placeholder characters', () {
      final t = _read('a{# note}b{pitch 0}');
      expect(t.text, 'a${atomChar}b$atomChar');
      expect(t.ranges.map((r) => (r.atom, r.key)), [
        (true, null),
        (true, 'pitch'),
      ]);
      expect(t.ranges.first.toString(), '#[1, 2)');
    });

    test('a literal placeholder character becomes a replacement character', () {
      expect(_read('a${atomChar}b').text, 'a�b');
    });
  });

  group('editing', () {
    test('typing inside a mark joins it', () {
      expect(_edit('{em | ab}c', 'aXbc'), '{em | aXb}c');
    });

    test('typing at the end of a mark joins it, except a ruby', () {
      expect(_edit('{em | ab}c', 'abXc', cursor: 3), '{em | abX}c');
      expect(_edit('{ruby てんき | 天気}', '天気が', cursor: 3), '{ruby てんき | 天気}が');
    });

    test('typing at the start of a mark does not join it', () {
      expect(_edit('{em | ab}c', 'Xabc', cursor: 1), 'X{em | ab}c');
    });

    test('the cursor places a change among repeated characters', () {
      expect(_edit('{em | a}a', 'aaa', cursor: 2), '{em | aa}a');
      expect(_edit('{em | a}a', 'aaa', cursor: 3), '{em | a}aa');
    });

    test('text replacing a mark\'s text stays in it, as an IME converts', () {
      expect(_edit('{em | てんき}', '天気', cursor: 2), '{em | 天気}');
      expect(_edit('a{em | bc}', 'aX', cursor: 2), 'a{em | X}');
    });

    test('marks after the change move', () {
      expect(_edit('ab{em | c}', 'aXYbc'), 'aXYb{em | c}');
      expect(
        _edit(
          'ab{# x}{em | c}',
          'b$atomChar'
              'c',
        ),
        'b{# x}{em | c}',
      );
    });

    test('deleting all of a mark\'s text removes it, and an atom with its '
        'character', () {
      final t = _read('a{em | b}{# c}d');
      expect(shiftRanges(t.ranges, t.text, 'ad'), isEmpty);
      expect(shiftRanges(t.ranges, t.text, t.text), same(t.ranges));
    });

    test('deleting across a mark\'s edge shortens it', () {
      expect(_edit('a{em | bc}d', 'acd'), 'a{em | c}d');
      expect(_edit('a{em | bc}d', 'abd'), 'a{em | b}d');
    });
  });

  group('toggling', () {
    test('adds a mark, split where it crosses another', () {
      expect(_toggle('今日はいい', 'em', 3, 5), '今日は{em | いい}');
      expect(
        _toggle('{ruby x | ab}cd', 'em', 1, 3),
        '{ruby x | a{em | b}}{em | c}d',
      );
    });

    test('joins marks equal to it that it touches or overlaps', () {
      expect(_toggle('{em | ab}cd', 'em', 1, 3), '{em | abc}d');
      expect(_toggle('{em | ab}cd', 'em', 2, 3), '{em | abc}d');
      expect(
        _toggle('{lang ja | ab}cd', 'lang', 2, 4, args: ['zh']),
        '{lang ja | ab}{lang zh | cd}',
      );
    });

    test('a split part waits behind the marks that start before it', () {
      expect(
        _toggle('{ruby x | ab}c{sub | d}', 'em', 1, 4),
        '{ruby x | a{em | b}}{em | c{sub | d}}',
      );
    });

    test('taking a mark off keeps the atoms in it', () {
      expect(_toggle('{em | a{# c}b}', 'em', 0, 3), 'a{# c}b');
    });

    test('takes a mark off the selected part only', () {
      expect(_toggle('{em | abcd}', 'em', 1, 3), '{em | a}bc{em | d}');
      expect(_toggle('{em | ab}{em | cd}', 'em', 1, 3), '{em | a}bc{em | d}');
    });

    test('at the cursor, takes off the innermost mark of the kind', () {
      expect(_toggle('{em | a{em | b}c}', 'em', 2, 2), '{em | abc}');
      expect(_toggle('{em | ab}', 'em', 2, 2), 'ab');
      expect(_toggle('ab', 'em', 1, 1), 'ab');
    });

    test('knows where a kind is', () {
      final t = _read('{em | ab}{em | c}d');
      expect(hasMark(t.ranges, 'em', 0, 3), isTrue);
      expect(hasMark(t.ranges, 'em', 0, 4), isFalse);
      expect(hasMark(t.ranges, 'em', 3, 3), isTrue);
      expect(hasMark(t.ranges, 'em', 4, 4), isFalse);
      expect(hasMark(t.ranges, 'ruby', 0, 1), isFalse);
    });
  });

  test('ranges compare by value', () {
    const a = MarkRange(0, 1, ContentNode.text('x'));
    expect(a, const MarkRange(0, 1, ContentNode.text('x')));
    expect(a.hashCode, const MarkRange(0, 1, ContentNode.text('x')).hashCode);
    expect(a.withNode(const ContentNode.comment('y')).node, isA<CommentNode>());
    expect(a.contains(0, 1), isTrue);
  });
}
