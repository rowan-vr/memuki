import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/card_renderer.dart';
import 'package:memuki/domain/content/content_node.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/content_writer.dart';

/// The sides [template] renders from [fields], both given as source, written
/// back as source.
(String, String) _render(
  String template, [
  Map<String, String> fields = const {},
]) {
  final card = renderCard(parseContent(template).nodes, {
    for (final MapEntry(:key, :value) in fields.entries)
      key: parseContent(value).nodes,
  });
  return (writeContent(card.front), writeContent(card.back));
}

const _vocabulary = '''
{# The word in front; its reading and meaning behind.}
{front |
  {field Word role=prompt}
}
{back |
  {field Reading role=reading}
  {field Meaning role=answer}
  {if Example | {field Example role=example}}
}
{requires Word}''';

void main() {
  test('puts each field in its place, with its role', () {
    expect(
      _render(_vocabulary, {
        'Word': '{ruby ねこ | 猫}',
        'Reading': 'ねこ',
        'Meaning': 'cat',
        'Example': '猫が好き',
      }),
      (
        '{field Word role=prompt | {ruby ねこ | 猫}}',
        '{field Reading role=reading | ねこ}\n'
            '{field Meaning role=answer | cat}\n'
            '{field Example role=example | 猫が好き}',
      ),
    );
  });

  test('an if shows its content only when its field is not empty', () {
    const template = '{front | a{if X | b}c} {back | }';
    expect(_render(template, {'X': 'x'}).$1, 'abc');
    expect(_render(template, {'X': ''}).$1, 'ac');
    expect(_render(template, {'X': ' {# only a comment} '}).$1, 'ac');
    expect(_render(template).$1, 'ac');
    expect(_render(template, {'X': '{em | x}'}).$1, 'abc');
  });

  test('an empty field leaves no empty line', () {
    expect(_render(_vocabulary, {'Word': 'w', 'Meaning': 'm'}), (
      '{field Word role=prompt | w}',
      '{field Meaning role=answer | m}',
    ));
    expect(_render(_vocabulary), ('', ''));
  });

  test("whitespace lays out the template's text but not the fields'", () {
    final card = renderCard(
      parseContent('{front |  a \n\n   b  {field X}  } {back | x}').nodes,
      {
        'X': [ContentNode.text('  two\n\n lines ')],
      },
    );
    expect(card.front, [
      ContentNode.text('a\nb  '),
      const ContentNode.mark(
        'field',
        args: ['X'],
        content: [ContentNode.text('  two\n\n lines ')],
      ),
    ]);
  });

  test('comments and requires are dropped, other marks kept', () {
    expect(
      _render('{front | {# note}{em | {field X}}{pitch 0 | はし}{requires X}}', {
        'X': 'x',
      }).$1,
      '{em | {field X | x}}{pitch 0 | はし}',
    );
  });

  test('a missing side is empty, and only the first of each is used', () {
    expect(_render('{back | b}'), ('', 'b'));
    expect(_render('{front | 1}{front | 2}{back | b}'), ('1', 'b'));
    expect(_render('nothing here'), ('', ''));
  });

  test('cards are equal by their sides', () {
    final a = renderCard(parseContent(_vocabulary).nodes, const {});
    final b = renderCard(parseContent(_vocabulary).nodes, const {});
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(
      a,
      isNot(RenderedCard(front: [ContentNode.text('x')], back: const [])),
    );
    expect(a.toString(), contains('RenderedCard'));
  });

  test('isEmptyContent', () {
    expect(isEmptyContent(const []), isTrue);
    expect(isEmptyContent(parseContent(' {# c} ').nodes), isTrue);
    expect(isEmptyContent(parseContent('{em |}').nodes), isFalse);
    expect(isEmptyContent(parseContent('x').nodes), isFalse);
  });
}
