import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/mark_kinds.dart';
import 'package:memuki/presentation/developer/content_warnings.dart';

List<ContentWarning> _warnings(
  String source, {
  MarkScope scope = MarkScope.field,
  MarkKinds? kinds,
}) {
  final all = kinds ?? MarkKinds.builtIn;
  final parsed = parseContent(source);
  return contentWarnings(source, parsed, all.check(parsed.nodes, scope), all);
}

List<String> _titles(String source, {MarkScope scope = MarkScope.field}) => [
  for (final w in _warnings(source, scope: scope)) w.title,
];

void main() {
  test('explains every problem in the source, with its position', () {
    expect(_titles('{em | a'), ['Unclosed mark']);
    expect(_titles('a\n}'), ['Stray close']);
    expect(_titles('{ x'), ['Invalid mark']);
    expect(_titles('{em "a | b'), ['Unterminated quote']);
    expect(_titles(r'a\'), ['Trailing backslash']);
    expect(_titles('{x a=1 a=2}'), ['Repeated argument', 'Unknown mark']);
    final deep = '{em | ' * (maxContentDepth + 1);
    expect(_titles('$deep${'}' * (maxContentDepth + 1)}'), [
      'Nested too deeply',
    ]);
    expect(_warnings('a\nb}').single.where, 'Line 2, column 2');
  });

  test('explains every issue with a mark, with its source', () {
    final unknown = _warnings('{pitch 0 | はし}').single;
    expect(unknown.title, 'Unknown mark');
    expect(unknown.detail, contains('"pitch"'));
    expect(unknown.where, '{pitch 0 | はし}');

    expect(
      _warnings('{field Word}').single.detail,
      '"field" belongs in templates.',
    );
    expect(
      _warnings('{ruby | 天気}').single.detail,
      '"ruby" takes 1 (reading), but has 0.',
    );
    expect(
      _warnings('{em x | a}').single.detail,
      '"em" takes no arguments, but has 1.',
    );
    expect(_titles('{em x=1 | a}'), ['Unknown named argument']);
    expect(_titles('{em}'), ['Missing content']);
  });

  test('explains every issue with a template', () {
    const scope = MarkScope.template;
    final sides = '{front |}{back |}';
    expect(
      _warnings('$sides{requires}', scope: scope).single.detail,
      '"requires" takes at least 1 (name …), but has 0.',
    );
    expect(
      _warnings('$sides{requires A x=1}', scope: scope).single.detail,
      '"requires" takes no named arguments.',
    );
    expect(
      _warnings('{front | {field A x=1}}{back |}', scope: scope).single.detail,
      '"field" accepts role= only.',
    );
    expect(_titles('{front | {field A | x}}{back |}', scope: scope), [
      'Unexpected content',
    ]);
    expect(_titles('{front | {back |}}{back |}', scope: scope), [
      'Misplaced "back"',
    ]);
    expect(_titles('$sides{back |}', scope: scope), ['Second "back"']);
    final missing = _warnings('{front |}', scope: scope).single;
    expect(missing.title, 'No "back"');
    expect(missing.where, isNull);
    final loose = _warnings('${'word ' * 20}\n$sides', scope: scope).single;
    expect(loose.title, 'Outside the sides');
    expect(loose.where, hasLength(60));
    expect(loose.where, endsWith('…'));
  });

  test('lists several named arguments', () {
    final kinds = MarkKinds([
      const MarkKind(
        'x',
        description: 'x',
        example: '{x | a}',
        scopes: {MarkScope.field},
        named: [MarkArgument('a', 'a'), MarkArgument('b', 'b')],
      ),
    ]);
    final parsed = parseContent('{x c=1 | a}');
    final warnings = contentWarnings(
      '',
      parsed,
      kinds.check(parsed.nodes, MarkScope.field),
      kinds,
    );
    expect(warnings.single.detail, '"x" accepts a= or b= only.');
    expect(
      _warnings(
        '{x | a}',
        scope: MarkScope.template,
        kinds: kinds,
      ).map((w) => w.detail),
      contains('"x" belongs in fields.'),
    );
  });
}
