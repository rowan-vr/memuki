import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_node.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/content_writer.dart';

/// Reads [source], expecting no problems.
List<ContentNode> _parse(String source) {
  final parsed = parseContent(source);
  expect(parsed.problems, isEmpty, reason: source);
  return parsed.nodes;
}

ContentProblem _p(ContentProblemKind kind, int offset) =>
    ContentProblem(kind, offset);

void main() {
  group('reading', () {
    test('plain text is one text node', () {
      expect(_parse('今日はいい天気'), [ContentNode.text('今日はいい天気')]);
      expect(_parse(''), isEmpty);
    });

    test('the examples from the format description', () {
      expect(_parse('今日は{ruby てんき | 天気}が{em | いい}です。'), [
        ContentNode.text('今日は'),
        const ContentNode.mark(
          'ruby',
          args: ['てんき'],
          content: [ContentNode.text('天気')],
        ),
        ContentNode.text('が'),
        const ContentNode.mark('em', content: [ContentNode.text('いい')]),
        ContentNode.text('です。'),
      ]);
      expect(_parse('{lang zh-Hans | {ruby "nǐ hǎo" | 你好}}'), [
        const ContentNode.mark(
          'lang',
          args: ['zh-Hans'],
          content: [
            ContentNode.mark(
              'ruby',
              args: ['nǐ hǎo'],
              content: [ContentNode.text('你好')],
            ),
          ],
        ),
      ]);
      expect(_parse('H{sub | 2}O'), [
        ContentNode.text('H'),
        const ContentNode.mark('sub', content: [ContentNode.text('2')]),
        ContentNode.text('O'),
      ]);
    });

    test('named arguments, quoted or not, empty or not', () {
      expect(_parse('{field Word role=prompt}'), [
        const ContentNode.mark(
          'field',
          args: ['Word'],
          named: {'role': 'prompt'},
        ),
      ]);
      expect(_parse('{x hint="a city" empty= other=""}'), [
        const ContentNode.mark(
          'x',
          named: {'hint': 'a city', 'empty': '', 'other': ''},
        ),
      ]);
    });

    test('quoted arguments keep escaped quotes and backslashes', () {
      expect(_parse(r'{x "say \"hi\"" "a\\b" "{|}"}'), [
        const ContentNode.mark('x', args: ['say "hi"', r'a\b', '{|}']),
      ]);
    });

    test('a mark with no bar has no content; an empty one has empty', () {
      expect(_parse('{x}'), [const ContentNode.mark('x')]);
      expect(_parse('{x |}'), [const ContentNode.mark('x', content: [])]);
      expect(_parse('{x|   }'), [const ContentNode.mark('x', content: [])]);
    });

    test('keys may hold digits, dashes, underscores, dots, and colons', () {
      expect(_parse('{jp:pitch-accent_2.0 | x}'), [
        const ContentNode.mark(
          'jp:pitch-accent_2.0',
          content: [ContentNode.text('x')],
        ),
      ]);
    });

    test('whitespace at the ends of content is dropped', () {
      const em = ContentNode.mark('em', content: [ContentNode.text('word')]);
      expect(_parse('{em|word}'), [em]);
      expect(_parse('{em | word }'), [em]);
      expect(_parse('{em |\n\t word \n}'), [em]);
      expect(_parse('{em | two  words }'), [
        const ContentNode.mark('em', content: [ContentNode.text('two  words')]),
      ]);
    });

    test('escaped whitespace at the ends of content is kept', () {
      expect(_parse(r'{em |\ word\ }'), [
        const ContentNode.mark('em', content: [ContentNode.text(' word ')]),
      ]);
      expect(_parse(r'{em | \  }'), [
        const ContentNode.mark('em', content: [ContentNode.text(' ')]),
      ]);
      expect(_parse(r'{em |\  \ }'), [
        const ContentNode.mark('em', content: [ContentNode.text('   ')]),
      ]);
    });

    test('whitespace outside marks and between nested marks is kept', () {
      expect(_parse('  a {em | b} c  '), [
        ContentNode.text('  a '),
        const ContentNode.mark('em', content: [ContentNode.text('b')]),
        ContentNode.text(' c  '),
      ]);
      expect(_parse('{front |\n  {field A}\n  {field B}\n}'), [
        const ContentNode.mark(
          'front',
          content: [
            ContentNode.mark('field', args: ['A']),
            ContentNode.text('\n  '),
            ContentNode.mark('field', args: ['B']),
          ],
        ),
      ]);
    });

    test('a backslash makes any character literal', () {
      expect(_parse(r'\{not a mark\} \| \\ \a'), [
        ContentNode.text(r'{not a mark} | \ a'),
      ]);
      expect(_parse(r'\😀'), [ContentNode.text('😀')]);
    });

    test('a bar outside a mark head is plain text', () {
      expect(_parse('a | b'), [ContentNode.text('a | b')]);
      expect(_parse('{em | a | b}'), [
        const ContentNode.mark('em', content: [ContentNode.text('a | b')]),
      ]);
    });
  });

  group('malformed source', () {
    test('an unclosed mark is kept as text', () {
      final parsed = parseContent('a {em | b');
      expect(parsed.nodes, [ContentNode.text('a {em | b')]);
      expect(parsed.problems, [_p(ContentProblemKind.unclosedMark, 2)]);
    });

    test('a mark inside an unclosed one is still read', () {
      final parsed = parseContent('{em | {sub | x}');
      expect(parsed.nodes, [
        ContentNode.text('{em | '),
        const ContentNode.mark('sub', content: [ContentNode.text('x')]),
      ]);
      expect(parsed.problems, [_p(ContentProblemKind.unclosedMark, 0)]);
    });

    test('a stray close is kept as text', () {
      final parsed = parseContent('a } b');
      expect(parsed.nodes, [ContentNode.text('a } b')]);
      expect(parsed.problems, [_p(ContentProblemKind.unexpectedClose, 2)]);
    });

    test('a brace without a key is kept as text', () {
      for (final source in ['{ x}', '{}', '{1x}', '{=}', '{', 'a{']) {
        final parsed = parseContent(source);
        expect(_allText(parsed.nodes), source, reason: source);
        expect(
          parsed.problems.first.kind,
          anyOf(
            ContentProblemKind.invalidMark,
            ContentProblemKind.unclosedMark,
          ),
          reason: source,
        );
      }
    });

    test('a head that cannot be read is kept as text', () {
      for (final source in [
        '{x=y}',
        '{x"a"}',
        '{x "a"b}',
        '{x a"b"}',
        '{x =y}',
        '{x #=y}',
        '{x a{b}',
        r'{x a\b}',
      ]) {
        final parsed = parseContent(source);
        expect(
          parsed.nodes.whereType<MarkNode>().where((m) => m.key == 'x'),
          isEmpty,
          reason: source,
        );
        expect(parsed.problems, isNotEmpty, reason: source);
      }
    });

    test('an unterminated quote is reported where it starts', () {
      final parsed = parseContent('ab{x "open}');
      expect(parsed.nodes, [ContentNode.text('ab{x "open}')]);
      expect(parsed.problems, [
        _p(ContentProblemKind.unterminatedQuote, 5),
        _p(ContentProblemKind.unexpectedClose, 10),
      ]);
    });

    test('a broken named value is reported', () {
      expect(
        parseContent('{x a="open}').problems.first,
        _p(ContentProblemKind.unterminatedQuote, 5),
      );
      expect(
        parseContent('{x a=b"c"}').problems.first,
        _p(ContentProblemKind.invalidMark, 0),
      );
    });

    test('a trailing backslash is kept', () {
      final parsed = parseContent(r'a\');
      expect(parsed.nodes, [ContentNode.text(r'a\')]);
      expect(parsed.problems, [_p(ContentProblemKind.trailingBackslash, 1)]);
    });

    test('a repeated named argument keeps the last value', () {
      final parsed = parseContent('{x a=1 a=2}');
      expect(parsed.nodes, [
        const ContentNode.mark('x', named: {'a': '2'}),
      ]);
      expect(parsed.problems, [_p(ContentProblemKind.duplicateArgument, 7)]);
    });

    test('marks nested too deeply are kept as text', () {
      final depth = maxContentDepth + 1;
      final source = '${'{em | ' * depth}x${'}' * depth}';
      final parsed = parseContent(source);
      expect(parsed.problems.first.kind, ContentProblemKind.tooDeep);

      var nodes = parsed.nodes;
      var levels = 0;
      while (nodes.whereType<MarkNode>().isNotEmpty) {
        nodes = nodes.whereType<MarkNode>().first.content!;
        levels++;
      }
      expect(levels, maxContentDepth);
    });

    test('a mark without content past the limit is kept as text', () {
      final open = '{em | ' * maxContentDepth;
      final close = '}' * maxContentDepth;
      final parsed = parseContent('$open{x}$close');
      expect(parsed.problems.single.kind, ContentProblemKind.tooDeep);
      expect(_allText(parsed.nodes), '{x}');
    });

    test('a too deep mark that is never closed is kept as text', () {
      final open = '{em | ' * maxContentDepth;
      final parsed = parseContent('$open{em | \\{a');
      expect(
        parsed.problems.map((p) => p.kind),
        contains(ContentProblemKind.unclosedMark),
      );
      expect(_allText(parsed.nodes), endsWith(r'{em | \{a'));
    });

    test('the deepest allowed nesting is read', () {
      final source = '${'{em | ' * maxContentDepth}x${'}' * maxContentDepth}';
      expect(_parse(source), hasLength(1));
    });

    test('deeply nested unclosed marks are read quickly', () {
      final watch = Stopwatch()..start();
      final parsed = parseContent('{em | ' * 3000);
      expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
      expect(parsed.problems, isNotEmpty);
      expect(_allText(parsed.nodes), '{em | ' * 3000);
    });
  });

  group('comments', () {
    test('are read up to the matching close', () {
      expect(_parse('a{# note }b'), [
        ContentNode.text('a'),
        const ContentNode.comment('note'),
        ContentNode.text('b'),
      ]);
      expect(_parse('{#}{#  }'), [
        const ContentNode.comment(''),
        const ContentNode.comment(''),
      ]);
      expect(_parse(r'{# {em | x} \} \ }'), [
        const ContentNode.comment('{em | x} }  '),
      ]);
      expect(_parse('{em | {#x} y}'), [
        const ContentNode.mark(
          'em',
          content: [ContentNode.comment('x'), ContentNode.text(' y')],
        ),
      ]);
    });

    test('a comment that is never closed is kept as text', () {
      final parsed = parseContent('a{# b {c}');
      expect(parsed.nodes, [
        ContentNode.text('a{# b '),
        const ContentNode.mark('c'),
      ]);
      expect(parsed.problems, [_p(ContentProblemKind.unclosedMark, 1)]);
    });

    test('are passed over inside marks nested too deeply', () {
      final open = '{em | ' * (maxContentDepth + 1);
      final close = '}' * (maxContentDepth + 1);
      final parsed = parseContent('$open{# \\} } x$close');
      expect(parsed.problems.single.kind, ContentProblemKind.tooDeep);
      expect(_allText(parsed.nodes), endsWith(r'{em | {# \} } x}'));
    });

    test('are written with their ends and braces protected', () {
      expect(
        writeContent([
          const ContentNode.comment(''),
          const ContentNode.comment(r' {a} \ '),
        ]),
        r'{#}{# \ \{a\} \\\ }',
      );
    });
  });

  group('writing', () {
    test('writes the canonical form', () {
      expect(
        writeContent(_parse('今日は{ruby  てんき|天気 }が{em|いい}です。')),
        '今日は{ruby てんき | 天気}が{em | いい}です。',
      );
      expect(
        writeContent([
          const ContentNode.mark(
            'field',
            args: ['Word', 'two words', ''],
            named: {'role': 'prompt', 'hint': 'a "city"'},
          ),
          const ContentNode.mark('x', content: []),
        ]),
        r'{field Word "two words" "" role=prompt hint="a \"city\""}{x |}',
      );
    });

    test('escapes braces and backslashes in text', () {
      expect(writeContent([ContentNode.text(r'{a} | b\c')]), r'\{a\} | b\\c');
    });

    test('protects whitespace at the ends of content', () {
      expect(
        writeContent([
          const ContentNode.mark('em', content: [ContentNode.text(' a ')]),
          const ContentNode.mark('em', content: [ContentNode.text('  ')]),
          const ContentNode.mark('em', content: [ContentNode.text('\n')]),
        ]),
        '{em | \\ a\\ }{em | \\ \\ }{em | \\\n}',
      );
    });

    test('joins adjacent text and leaves out empty text', () {
      expect(
        writeContent([
          const ContentNode.mark(
            'em',
            content: [
              ContentNode.text(' '),
              ContentNode.text(''),
              ContentNode.text('a '),
            ],
          ),
        ]),
        r'{em | \ a\ }',
      );
    });

    test('rejects keys and names that cannot be read back', () {
      expect(
        () => writeContent([const ContentNode.mark('two words')]),
        throwsArgumentError,
      );
      expect(
        () => writeContent([
          const ContentNode.mark('x', named: {'a b': '1'}),
        ]),
        throwsArgumentError,
      );
    });
  });

  group('round trips', () {
    test('generated content reads back as written', () {
      final random = Random(7);
      for (var i = 0; i < 3000; i++) {
        final nodes = _generate(random, 3);
        final source = writeContent(nodes);
        final parsed = parseContent(source);
        expect(parsed.problems, isEmpty, reason: source);
        expect(parsed.nodes, _normalized(nodes), reason: source);
      }
    });

    test('any source settles into a canonical form', () {
      final random = Random(11);
      const alphabet = '{}|\\" =ab\n漢😀#';
      final chars = alphabet.runes.map(String.fromCharCode).toList();
      for (var i = 0; i < 5000; i++) {
        final source = [
          for (var j = random.nextInt(24); j > 0; j--)
            chars[random.nextInt(chars.length)],
        ].join();
        final first = parseContent(source).nodes;
        final written = writeContent(first);
        final second = parseContent(written);
        expect(second.problems, isEmpty, reason: '$source → $written');
        expect(second.nodes, first, reason: '$source → $written');
        expect(writeContent(second.nodes), written);
      }
    });
  });
}

/// All text in [nodes], with marks unwrapped.
String _allText(List<ContentNode> nodes) => nodes
    .map(
      (n) => switch (n) {
        TextNode(:final text) => text,
        MarkNode(:final content) => _allText(content ?? const []),
        CommentNode(:final text) => text,
      },
    )
    .join();

/// [nodes] as the parser returns them: adjacent text joined, empty text
/// left out.
List<ContentNode> _normalized(List<ContentNode> nodes) {
  final out = <ContentNode>[];
  for (final node in nodes) {
    switch (node) {
      case TextNode(:final text):
        if (text.isEmpty) continue;
        if (out.lastOrNull case TextNode(text: final previous)) {
          out[out.length - 1] = ContentNode.text(previous + text);
        } else {
          out.add(node);
        }
      case MarkNode():
        out.add(
          node.copyWith(
            content: node.content == null ? null : _normalized(node.content!),
          ),
        );
      case CommentNode():
        out.add(node);
    }
  }
  return out;
}

const _pieces = [
  ' ',
  '  ',
  '\n',
  'a',
  '漢字',
  '{',
  '}',
  '|',
  r'\',
  '"',
  '=',
  '😀',
  'b c',
];
const _keys = ['em', 'ruby', 'x', 'jp:pitch', 'a-b_c.d'];

String _string(Random random, {int max = 4}) => [
  for (var i = random.nextInt(max + 1); i > 0; i--)
    _pieces[random.nextInt(_pieces.length)],
].join();

List<ContentNode> _generate(Random random, int depth) => [
  for (var i = random.nextInt(4); i > 0; i--)
    if (random.nextInt(8) == 0)
      ContentNode.comment(_string(random))
    else if (depth == 0 || random.nextBool())
      ContentNode.text(_string(random))
    else
      ContentNode.mark(
        _keys[random.nextInt(_keys.length)],
        args: [for (var j = random.nextInt(3); j > 0; j--) _string(random)],
        named: {
          for (var j = random.nextInt(3); j > 0; j--)
            _keys[random.nextInt(_keys.length)]: _string(random),
        },
        content: random.nextInt(4) == 0 ? null : _generate(random, depth - 1),
      ),
];
