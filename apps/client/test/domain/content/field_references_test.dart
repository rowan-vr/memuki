import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/content/content_writer.dart';
import 'package:memuki/domain/content/field_references.dart';

const _template =
    '{front | {field Word role=prompt}}\n'
    '{back | {field Meaning}{if Word | {field Word}}}\n'
    '{requires Word Meaning}';

void main() {
  test('finds the fields a template names', () {
    expect(fieldReferences(parseContent(_template).nodes), {'Word', 'Meaning'});
    expect(fieldReferences(parseContent('{lang Word | x}').nodes), isEmpty);
  });

  test('renames placements, conditions, and requirements', () {
    final renamed = renameFieldReferences(
      parseContent(_template).nodes,
      'Word',
      'Term',
    );
    expect(
      writeContent(renamed),
      '{front | {field Term role=prompt}}\n'
      '{back | {field Meaning}{if Term | {field Term}}}\n'
      '{requires Term Meaning}',
    );
  });

  test('removes a field with what shows only for it', () {
    final removed = removeFieldReferences(
      parseContent(_template).nodes,
      'Word',
    );
    expect(
      writeContent(removed),
      '{front |}\n{back | {field Meaning}}\n{requires Meaning}',
    );
    expect(
      writeContent(
        removeFieldReferences(parseContent('{requires Word}').nodes, 'Word'),
      ),
      '',
    );
  });

  test('a basic template asks with the first field', () {
    expect(
      basicTemplateSource(['Word', 'Meaning', 'Example sentence']),
      '{front | {field Word role=prompt}}\n'
      '{back | {field Meaning role=answer}\n'
      '{field "Example sentence"}}',
    );
    expect(basicTemplateSource([]), '{front |}\n{back |}');
  });
}
