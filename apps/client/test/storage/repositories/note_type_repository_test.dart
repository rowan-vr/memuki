import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
  });

  test('round-trips fields and templates in order', () async {
    expect(
      await repos.noteTypes.noteType(japanese.noteType.id),
      japanese.noteType,
    );
  });

  test('reordering and renaming fields keeps note values', () async {
    final (note, _) = await japanese.addNote('猫');
    final [front, back] = japanese.noteType.fields;
    final updated = japanese.noteType.copyWith(
      fields: [
        back,
        front.copyWith(name: 'Word'),
      ],
    );

    await repos.noteTypes.updateNoteType(updated);

    expect(await repos.noteTypes.noteType(updated.id), updated);
    expect((await repos.notes.note(note.id))!.fields, {front.id: '猫'});
  });

  test('removing a field removes its values from notes', () async {
    final (note, _) = await japanese.addNote('猫');
    final [front, back] = japanese.noteType.fields;
    await repos.noteTypes.updateNoteType(
      japanese.noteType.copyWith(fields: [back]),
    );
    expect((await repos.notes.note(note.id))!.fields, isEmpty);
    expect(front.id, isNot(back.id));
  });

  test('removing a template that has cards is rejected', () async {
    await japanese.addNote('猫');
    await expectLater(
      repos.noteTypes.updateNoteType(
        japanese.noteType.copyWith(
          templates: [
            StudyCardTemplate(id: StudyCardTemplateId.generate(), name: 'New'),
          ],
        ),
      ),
      throwsA(isA<EntityInUseException>()),
    );
    expect(
      await repos.noteTypes.noteType(japanese.noteType.id),
      japanese.noteType,
    );
  });

  test('cannot take over fields of another note type', () async {
    final korean = await repos.seedCollection(name: 'Korean');
    await expectLater(
      repos.noteTypes.updateNoteType(
        japanese.noteType.copyWith(fields: korean.noteType.fields),
      ),
      throwsA(isA<NoteTypeMismatchException>()),
    );
  });

  test('deleting one that notes use is rejected', () async {
    await japanese.addNote('猫');
    await expectLater(
      repos.noteTypes.deleteNoteType(japanese.noteType.id),
      throwsA(isA<EntityInUseException>()),
    );
  });

  test('deleting an unused one removes it with its parts', () async {
    await repos.noteTypes.deleteNoteType(japanese.noteType.id);
    expect(await repos.noteTypes.noteTypes(japanese.id), isEmpty);
    expect(await repos.db.select(repos.db.fieldDefinitions).get(), isEmpty);
  });

  test('watching emits when a field is renamed', () async {
    final names = repos.noteTypes
        .watchNoteTypes(japanese.id)
        .map((ts) => ts.single.fields.first.name);
    expect(names, emitsThrough('Word'));
    final [front, back] = japanese.noteType.fields;
    await repos.noteTypes.updateNoteType(
      japanese.noteType.copyWith(
        fields: [
          front.copyWith(name: 'Word'),
          back,
        ],
      ),
    );
  });
}
