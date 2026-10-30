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

    test('template placeholders read as nothing', () {
      expect(_plain('{front | Q: {field Word} {requires Word}}'), 'Q:  ');
    });

    test('a kind can read differently', () {
      final kinds = MarkKinds([
        MarkKind(
          'ruby',
          scopes: const {MarkScope.field},
          args: 1,
          plainText: (mark, content) => '$content(${mark.args.single})',
        ),
      ]);
      expect(kinds.plainText(_parse('{ruby てんき | 天気}')), '天気(てんき)');
      expect(kinds['ruby']?.key, 'ruby');
      expect(kinds['em'], isNull);
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
          '{front | {field Word role=prompt}}'
          '{back | {if Example | {field Example}}}'
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
      expect(_issues('{em | x}', MarkScope.template), [
        MarkIssueKind.wrongScope,
      ]);
    });

    test('reports wrong arguments and content, at any depth', () {
      expect(_issues('{em | {ruby | 天気}}', MarkScope.field), [
        MarkIssueKind.wrongArgumentCount,
      ]);
      expect(_issues('{requires}', MarkScope.template), [
        MarkIssueKind.wrongArgumentCount,
      ]);
      expect(_issues('{field Word colour=red}', MarkScope.template), [
        MarkIssueKind.unknownArgument,
      ]);
      expect(_issues('{em}', MarkScope.field), [MarkIssueKind.missingContent]);
      expect(_issues('{field Word | x}', MarkScope.template), [
        MarkIssueKind.unexpectedContent,
      ]);
    });

    test('says which mark has the issue', () {
      final issues = MarkKinds.builtIn.check(
        _parse('{em | {ruby | 天気}}'),
        MarkScope.field,
      );
      expect(issues.single.mark.key, 'ruby');
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
          issues.single.mark,
        ).hashCode,
      );
    });

    test('leaves unknown kinds alone', () {
      expect(_issues('{pitch 0 1 2 | x}', MarkScope.field), isEmpty);
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

  test('isContentKey accepts the key grammar', () {
    expect(isContentKey('jp:pitch-2'), isTrue);
    expect(isContentKey('2x'), isFalse);
    expect(isContentKey(''), isFalse);
  });
}
