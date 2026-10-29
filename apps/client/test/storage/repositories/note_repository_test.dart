import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;
  late FieldDefinitionId front;
  late FieldDefinitionId back;

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
    front = japanese.noteType.fields[0].id;
    back = japanese.noteType.fields[1].id;
  });

  Note newNote(Map<FieldDefinitionId, String> fields) => Note(
    id: NoteId.generate(),
    collectionId: japanese.id,
    noteTypeId: japanese.noteType.id,
    fields: fields,
    source: SourceAttribution(
      kind: SourceKind.dictionary,
      reference: 'jmdict:1',
    ),
  );

  test('round-trips fields and source', () async {
    final note = newNote({front: '猫', back: 'cat'});
    await repos.notes.createNote(note);
    expect(await repos.notes.note(note.id), note);
  });

  test('updating replaces fields and drops missing ones', () async {
    final note = newNote({front: '猫', back: 'cat'});
    await repos.notes.createNote(note);
    final updated = note.copyWith(fields: {front: 'ねこ'}, source: null);
    await repos.notes.updateNote(updated);
    expect(await repos.notes.note(note.id), updated);
  });

  test('rejects fields of another note type', () async {
    await expectLater(
      repos.notes.createNote(newNote({FieldDefinitionId.generate(): 'x'})),
      throwsA(isA<NoteTypeMismatchException>()),
    );
  });

  test('cannot change its note type', () async {
    final note = newNote({front: '猫'});
    await repos.notes.createNote(note);
    final other = NoteType(
      id: NoteTypeId.generate(),
      collectionId: japanese.id,
      name: 'Other',
      fields: [FieldDefinition(id: front, name: 'Front')],
      templates: [
        StudyCardTemplate(id: StudyCardTemplateId.generate(), name: 'Card'),
      ],
    );
    await expectLater(
      repos.notes.updateNote(note.copyWith(noteTypeId: other.id)),
      throwsA(isA<NoteTypeMismatchException>()),
    );
  });

  test('cannot use a note type of another collection', () async {
    final korean = await repos.seedCollection(name: 'Korean');
    await expectLater(
      repos.notes.createNote(
        newNote({}).copyWith(noteTypeId: korean.noteType.id),
      ),
      throwsA(isA<CrossCollectionException>()),
    );
  });

  test('deleting one removes its cards and their history', () async {
    final (note, card) = await japanese.addNote('猫');
    await repos.reviews.append(
      ReviewEvent(
        id: ReviewEventId.generate(),
        studyCardId: card.id,
        kind: ReviewEventKind.review,
        at: DateTime.utc(2026, 10, 29),
        grade: Grade.good,
        schedulerId: 'sm2',
        schedulerVersion: 1,
        configVersion: 1,
      ),
    );
    await repos.notes.deleteNote(note.id);
    expect(await repos.cards.card(card.id), isNull);
    expect(await repos.reviews.history(card.id), isEmpty);
  });

  group('tags', () {
    test('are attached once and can be removed', () async {
      final (note, _) = await japanese.addNote('猫');
      final tag = await japanese.addTag('animals');
      await repos.notes.addTag(note.id, tag.id);
      await repos.notes.addTag(note.id, tag.id);
      expect(await repos.notes.tagIds(note.id), {tag.id});
      await repos.notes.removeTag(note.id, tag.id);
      expect(await repos.notes.tagIds(note.id), isEmpty);
    });

    test('must be in the note\'s collection', () async {
      final korean = await repos.seedCollection(name: 'Korean');
      final (note, _) = await japanese.addNote('猫');
      final foreign = await korean.addTag('animals');
      await expectLater(
        repos.notes.addTag(note.id, foreign.id),
        throwsA(isA<CrossCollectionException>()),
      );
    });

    test('notesWithTag includes tags below it', () async {
      final grammar = await japanese.addTag('grammar');
      final particles = await japanese.addTag(
        'particles',
        parentId: grammar.id,
      );
      final (tagged, _) = await japanese.addNote('は');
      await japanese.addNote('untagged');
      await repos.notes.addTag(tagged.id, particles.id);

      expect(await repos.notes.notesWithTag(grammar.id), [tagged]);
    });
  });

  test('watching emits when a field changes', () async {
    final note = newNote({front: '猫'});
    await repos.notes.createNote(note);
    final fronts = repos.notes
        .watchNotes(japanese.id)
        .map((ns) => ns.single.fields[front]);
    expect(fronts, emitsThrough('ねこ'));
    await repos.notes.updateNote(note.copyWith(fields: {front: 'ねこ'}));
  });
}
