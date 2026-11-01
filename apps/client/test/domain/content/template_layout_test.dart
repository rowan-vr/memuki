import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_node.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/template_layout.dart';

TemplateLayout? _read(String source) =>
    TemplateLayout.read(parseContent(source).nodes);

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
  test('reads a template in lines', () {
    expect(
      _read(_vocabulary),
      TemplateLayout(
        front: const [FieldBlock('Word', role: 'prompt')],
        back: const [
          FieldBlock('Reading', role: 'reading'),
          FieldBlock('Meaning', role: 'answer'),
          IfBlock('Example', [FieldBlock('Example', role: 'example')]),
        ],
        requires: const ['Word'],
        comments: [
          CommentNode('The word in front; its reading and meaning behind.'),
        ],
      ),
    );
  });

  test('writes the canonical form, which reads back the same', () {
    final layout = _read(_vocabulary)!;
    expect(layout.write(), _vocabulary.trimLeft());
    expect(_read(layout.write()), layout);
  });

  test('lines that are not a lone field or if', () {
    final layout = _read('''
{front |
  Meaning: {em | of} {ruby ご | 語}
  The word {field Word}
  {em | {field Word}}
  {field Word role=prompt}{field Other}
  {field Word extra=1}
  {if A | {if B | x}}
  {pitch 0 | はし}
  {# note}
}
{back | }''')!;
    expect(layout.front, [
      TextBlock(parseContent('Meaning: {em | of} {ruby ご | 語}').nodes),
      SourceBlock(parseContent('The word {field Word}').nodes),
      SourceBlock(parseContent('{em | {field Word}}').nodes),
      SourceBlock(parseContent('{field Word role=prompt}{field Other}').nodes),
      SourceBlock(parseContent('{field Word extra=1}').nodes),
      IfBlock('A', [SourceBlock(parseContent('{if B | x}').nodes)]),
      SourceBlock(parseContent('{pitch 0 | はし}').nodes),
      TextBlock([CommentNode('note')]),
    ]);
    expect(layout.back, isEmpty);
    expect(_read(layout.write()), layout);
  });

  test('a mark over several lines stays one block', () {
    final layout = _read('{front | {em | a\nb}\nc} {back | }')!;
    expect(layout.front, [
      TextBlock(parseContent('{em | a\nb}').nodes),
      TextBlock([ContentNode.text('c')]),
    ]);
  });

  test('an if over several lines, and an empty one', () {
    const source = '''
{front |
  {if Example |
    {field Example role=example}
    note
  }
  {if Empty |
  }
}
{back |
}''';
    final layout = _read(source)!;
    expect(layout.front, [
      IfBlock('Example', [
        const FieldBlock('Example', role: 'example'),
        TextBlock([ContentNode.text('note')]),
      ]),
      const IfBlock('Empty', []),
    ]);
    expect(layout.write(), source);
  });

  test('names that need quotes are quoted', () {
    final layout = TemplateLayout(
      front: const [
        FieldBlock('Kanji word', role: 'prompt'),
        IfBlock('My example', [FieldBlock('My example')]),
      ],
      requires: const ['Kanji word', 'Meaning'],
    );
    expect(
      layout.write(),
      '{front |\n'
      '  {field "Kanji word" role=prompt}\n'
      '  {if "My example" | {field "My example"}}\n'
      '}\n'
      '{back |\n'
      '}\n'
      '{requires "Kanji word" Meaning}',
    );
    expect(_read(layout.write()), layout);
  });

  test('requires are joined, without repeats', () {
    expect(_read('{front | }{back | }{requires A B}{requires B C}')!.requires, [
      'A',
      'B',
      'C',
    ]);
  });

  test('a template whose top level does not fit is not read', () {
    for (final source in [
      '{back | }',
      '{front | }',
      '{front | }{front | }{back | }',
      'loose {front | }{back | }',
      '{front | }{back | }{em | x}',
      '{front}{back | }',
      '{front | }{back | }{requires | x}',
    ]) {
      expect(_read(source), isNull, reason: source);
    }
  });

  test('copyWith keeps what it is not given', () {
    final layout = _read(_vocabulary)!;
    final changed = layout.copyWith(requires: ['Meaning']);
    expect(changed.requires, ['Meaning']);
    expect(changed.front, layout.front);
    expect(changed.comments, layout.comments);
    expect(layout.copyWith(), layout);
    expect(layout.copyWith().hashCode, layout.hashCode);
  });

  test('blocks compare by value', () {
    expect(
      const FieldBlock('A').withRole('prompt'),
      const FieldBlock('A', role: 'prompt'),
    );
    expect(
      const FieldBlock('A', role: 'x').withName('B'),
      const FieldBlock('B', role: 'x'),
    );
    expect(const IfBlock('A', []).withName('B'), const IfBlock('B', []));
    expect(
      const IfBlock('A', []).withBlocks(const [FieldBlock('A')]).hashCode,
      const IfBlock('A', [FieldBlock('A')]).hashCode,
    );
    expect(
      TextBlock([ContentNode.text('a')]).hashCode,
      TextBlock([ContentNode.text('a')]).hashCode,
    );
    expect(
      SourceBlock([ContentNode.text('a')]).hashCode,
      SourceBlock([ContentNode.text('a')]).hashCode,
    );
    for (final block in [
      const FieldBlock('A'),
      const IfBlock('A', []),
      TextBlock(const []),
      SourceBlock(const []),
      const TemplateLayout(),
    ]) {
      expect(block.toString(), isNotEmpty);
    }
  });
}
