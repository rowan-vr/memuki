import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/content/content_parser.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note_type.dart';

void main() {
  final word = FieldDefinition(id: FieldDefinitionId.generate(), name: 'Word');
  final meaning = FieldDefinition(
    id: FieldDefinitionId.generate(),
    name: 'Meaning',
  );
  final recognition = StudyCardTemplate(
    id: StudyCardTemplateId.generate(),
    name: 'Recognition',
    source: '{front | {field Word}}\n{back | {field Meaning}}',
  );
  final listening = StudyCardTemplate(
    id: StudyCardTemplateId.generate(),
    name: 'Listening',
    source: '{front | {field Audio}}\n{back | {field Word}}',
  );
  final noteType = NoteType(
    id: NoteTypeId.generate(),
    collectionId: CollectionId.generate(),
    name: 'Vocabulary',
    fields: [word, meaning],
    templates: [recognition, listening],
    duplicateCheck: word.id,
  );

  test('templates start blank', () {
    final template = StudyCardTemplate(
      id: StudyCardTemplateId.generate(),
      name: 'Card',
    );
    expect(template.source, StudyCardTemplate.blank);
    expect(template.fieldNames, isEmpty);
  });

  test('knows which templates name a field, and the names it lacks', () {
    expect(noteType.templatesUsing(meaning.id), [recognition]);
    expect(noteType.templatesUsing(word.id), [recognition, listening]);
    expect(noteType.missingFields(listening), {'Audio'});
    expect(noteType.missingFields(recognition), isEmpty);
  });

  test('renaming a field renames it in the templates', () {
    final renamed = noteType.renameField(word.id, 'Term');
    expect(renamed.field(word.id)!.name, 'Term');
    expect(
      renamed.templates.first.source,
      '{front | {field Term}}\n{back | {field Meaning}}',
    );
    expect(renamed.templates.last.fieldNames, {'Audio', 'Term'});
    expect(noteType.renameField(word.id, 'Word'), noteType);
  });

  test('removing a field takes it out of the templates and the duplicate '
      'check', () {
    final removed = noteType.removeField(word.id);
    expect(removed.fields, [meaning]);
    expect(
      removed.templates.first.source,
      '{front |}\n{back | {field Meaning}}',
    );
    expect(removed.duplicateCheck, isNull);
    // A template that does not name it keeps its source as written.
    expect(noteType.removeField(meaning.id).templates.last, listening);
    expect(noteType.removeField(FieldDefinitionId.generate()), noteType);
  });

  test('the duplicate check is one of its fields', () {
    expect(
      () => noteType.copyWith(duplicateCheck: FieldDefinitionId.generate()),
      throwsArgumentError,
    );
  });

  test('a required field is missing when its value shows nothing', () {
    final required = word.copyWith(isRequired: true);
    expect(required.isMissing(parseContent(' {# note} ').nodes), isTrue);
    expect(required.isMissing(parseContent('{audio a.mp3}').nodes), isFalse);
    expect(word.isMissing(const []), isFalse);
  });

  test('allowed marks cover what is inside them', () {
    final limited = meaning.copyWith(allowedMarks: {'list', 'em'});
    expect(limited.allows('list'), isTrue);
    expect(limited.allows('ruby'), isFalse);
    expect(meaning.allows('ruby'), isTrue);
    final value = parseContent('{list | {item | {em | a}}}{ruby x | {sup | y}}')
        .nodes;
    expect(limited.disallowedMarks(value), {'ruby', 'sup'});
    expect(meaning.disallowedMarks(value), isEmpty);
  });

  test('a language must not be blank', () {
    expect(() => word.copyWith(language: ' '), throwsArgumentError);
    expect(word.copyWith(language: 'ja').language, 'ja');
  });
}
