import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_node.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/mark_kinds.dart';

List<ContentNode> _parse(String source) => parseContent(source).nodes;

String _plain(String source) => MarkKinds.builtIn.plainText(_parse(source));

List<MarkIssueKind> _issues(String source, MarkScope scope) => [
  for (final issue in MarkKinds.builtIn.check(_parse(source), scope))
    issue.kind,
];

void main() {
  group('plain text', () {
    test('drops the marks and keeps their content', () {
      expect(_plain('今日は{ruby てんき | 天気}が{em | いい}です。'), '今日は天気がいいです。');
      expect(_plain('{lang zh-Hans | {ruby "nǐ hǎo" | 你好}}'), '你好');
      expect(_plain('H{sub | 2}O'), 'H2O');
    });

    test('unknown kinds read as their content', () {
      expect(_plain('a{pitch 0 | はし}b{nothing}c'), 'aはしbc');
    });

    test('template placeholders and comments read as nothing', () {
      expect(_plain('{front | Q: {field Word} {requires Word}}'), 'Q:  ');
      expect(_plain('a{# note}b'), 'ab');
    });

    test('a kind can read differently', () {
      final kinds = MarkKinds([
        MarkKind(
          'ruby',
          description: 'Reading in brackets.',
          example: '{ruby てんき | 天気}',
          scopes: const {MarkScope.field},
          args: const [MarkArgument('reading', 'The reading.')],
          plainText: (mark, content) => '$content(${mark.args.single})',
        ),
      ]);
      expect(kinds.plainText(_parse('{ruby てんき | 天気}')), '天気(てんき)');
      expect(kinds['ruby']?.key, 'ruby');
      expect(kinds['em'], isNull);
      expect(kinds.all.map((k) => k.key), ['ruby']);
    });
  });

  group('checking', () {
    test('accepts well-formed fields and templates', () {
      expect(
        _issues('今日は{ruby てんき | 天気}が{em | {lang ja | いい}}', MarkScope.field),
        isEmpty,
      );
      expect(
        _issues(
          '{# a comment}\n'
          '{front | {field Word role=prompt}}\n'
          '{back | {if Example | {field Example}}}\n'
          '{requires Word Meaning}',
          MarkScope.template,
        ),
        isEmpty,
      );
    });

    test('reports marks outside their scope', () {
      expect(_issues('{field Word}', MarkScope.field), [
        MarkIssueKind.wrongScope,
      ]);
      expect(_issues('{front | {em | x}}{back |}', MarkScope.template), [
        MarkIssueKind.wrongScope,
      ]);
    });

    test('reports wrong arguments and content, at any depth', () {
      expect(_issues('{em | {ruby | 天気}}', MarkScope.field), [
        MarkIssueKind.wrongArgumentCount,
      ]);
      expect(_issues('{front |}{back |}{requires}', MarkScope.template), [
        MarkIssueKind.wrongArgumentCount,
      ]);
      expect(
        _issues(
          '{front | {field Word colour=red}}{back |}',
          MarkScope.template,
        ),
        [MarkIssueKind.unknownArgument],
      );
      expect(_issues('{em}', MarkScope.field), [MarkIssueKind.missingContent]);
      expect(
        _issues('{front | {field Word | x}}{back |}', MarkScope.template),
        [MarkIssueKind.unexpectedContent],
      );
    });

    test('templates have one front and one back at the top level', () {
      expect(_issues('{front | x}{back | {back | y}}', MarkScope.template), [
        MarkIssueKind.misplaced,
      ]);
      expect(_issues('{front |}{back | a}{back | b}', MarkScope.template), [
        MarkIssueKind.repeated,
      ]);
      expect(
        _issues(
          '{front |}{back |}{requires A}{requires B}',
          MarkScope.template,
        ),
        isEmpty,
      );
      expect(_issues('{front | x}', MarkScope.template), [
        MarkIssueKind.missing,
      ]);
      expect(_issues('', MarkScope.template), [
        MarkIssueKind.missing,
        MarkIssueKind.missing,
      ]);
    });

    test('templates have nothing outside their sides', () {
      final issues = MarkKinds.builtIn.check(
        _parse('hi {field Word}{pitch 0 | x}{front |}{back |}'),
        MarkScope.template,
      );
      expect(issues.map((i) => i.kind), [
        ...List.filled(3, MarkIssueKind.loose),
        MarkIssueKind.unknownKind,
      ]);
      expect(issues.take(3).map((i) => i.node), [
        ContentNode.text('hi '),
        const ContentNode.mark('field', args: ['Word']),
        const ContentNode.mark(
          'pitch',
          args: ['0'],
          content: [ContentNode.text('x')],
        ),
      ]);
    });

    test('fields are not checked as templates', () {
      expect(_issues('a {# b} c', MarkScope.field), isEmpty);
    });

    test('says which mark has the issue', () {
      final issues = MarkKinds.builtIn.check(
        _parse('{em | {ruby | 天気}}'),
        MarkScope.field,
      );
      expect((issues.single.node as MarkNode).key, 'ruby');
      expect(
        issues.single,
        MarkIssue(
          MarkIssueKind.wrongArgumentCount,
          const ContentNode.mark('ruby', content: [ContentNode.text('天気')])
              as MarkNode,
        ),
      );
      expect(issues.single.toString(), contains('wrongArgumentCount'));
      expect(
        issues.single.hashCode,
        MarkIssue(
          MarkIssueKind.wrongArgumentCount,
          issues.single.node,
        ).hashCode,
      );
    });

    test('reports unknown kinds, and nothing else about them', () {
      expect(_issues('{pitch 0 1 2 | x}', MarkScope.field), [
        MarkIssueKind.unknownKind,
      ]);
      expect(
        _issues('{front | {pitch 0 1 2 | x}}{back |}', MarkScope.template),
        [MarkIssueKind.unknownKind],
      );
    });
  });

  test('problems describe themselves', () {
    final problem = parseContent('}').problems.single;
    expect(problem.toString(), 'ContentProblem(unexpectedClose at 0)');
    expect(
      problem.hashCode,
      const ContentProblem(ContentProblemKind.unexpectedClose, 0).hashCode,
    );
  });

  test('every built-in example is well formed and fits its kind', () {
    for (final kind in MarkKinds.builtIn.all) {
      final parsed = parseContent(kind.example);
      expect(parsed.problems, isEmpty, reason: kind.key);
      expect(_keys(parsed.nodes), contains(kind.key), reason: kind.key);
      // Examples show one mark, not a whole template.
      final issues = MarkKinds.builtIn
          .check(parsed.nodes, kind.scopes.first)
          .where(
            (i) =>
                i.kind != MarkIssueKind.loose &&
                i.kind != MarkIssueKind.missing,
          );
      expect(issues, isEmpty, reason: kind.key);
    }
  });

  test('isContentKey accepts the key grammar', () {
    expect(isContentKey('jp:pitch-2'), isTrue);
    expect(isContentKey('2x'), isFalse);
    expect(isContentKey(''), isFalse);
  });
}

/// The keys of all marks in [nodes], at any depth.
Iterable<String> _keys(List<ContentNode> nodes) => nodes
    .whereType<MarkNode>()
    .expand((m) => [m.key, ..._keys(m.content ?? const [])]);
