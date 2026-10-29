import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/storage/database.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';
import 'package:memuki/storage/sync/change_recorder.dart';
import 'package:memuki/storage/sync/hlc.dart';

import '../../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late MemukiDatabase db;
  late SeededCollection japanese;

  setUp(() async {
    db = openTestDatabase();
    repos = Repositories(db);
    japanese = await repos.seedCollection();
    await db.delete(db.outbox).go();
  });

  Future<Map<String, int>> outboxCounts() async {
    final counts = <String, int>{};
    for (final row in await db.select(db.outbox).get()) {
      counts.update(row.entityTable, (n) => n + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  test('records each changed entity with its collection', () async {
    await japanese.addNote('猫');
    expect(await outboxCounts(), {
      'notes': 1,
      'note_fields': 1,
      'study_cards': 1,
    });
    final rows = await db.select(db.outbox).get();
    expect(rows.map((r) => r.collectionId), everyElement(japanese.id));
  });

  test('repeated edits of an entity coalesce into one entry', () async {
    final deck = japanese.deck;
    await repos.collections.updateDeck(deck.copyWith(name: 'A'));
    await repos.collections.updateDeck(deck.copyWith(name: 'B'));
    final rows = await db.select(db.outbox).get();
    expect(rows, hasLength(1));
    final row = await db.select(db.decks).getSingle();
    expect(rows.single.hlc, row.hlc);
  });

  test('updating a note stamps only the fields that changed', () async {
    final [front, back] = japanese.noteType.fields;
    final note = Note(
      id: NoteId.generate(),
      collectionId: japanese.id,
      noteTypeId: japanese.noteType.id,
      fields: {front.id: '猫', back.id: 'cat'},
    );
    await repos.notes.createNote(note);
    Future<Hlc> stampOf(FieldDefinitionId field) async => (await (db.select(
      db.noteFields,
    )..where((f) => f.fieldId.equalsValue(field))).getSingle()).hlc;
    final frontBefore = await stampOf(front.id);
    final noteBefore = (await db.select(db.notes).getSingle()).hlc;

    await repos.notes.updateNote(
      note.copyWith(fields: {front.id: '猫', back.id: 'kitty'}),
    );

    expect(await stampOf(front.id), frontBefore);
    expect(await stampOf(back.id) > frontBefore, isTrue);
    expect((await db.select(db.notes).getSingle()).hlc, noteBefore);
  });

  test(
    'deleting a deck stamps only the deck and hides what is below',
    () async {
      final child = await japanese.addDeck('Child', parentId: japanese.deck.id);
      final (note, card) = await japanese.addNote('猫', deckId: child.id);
      await db.delete(db.outbox).go();

      await repos.collections.deleteDeck(japanese.deck.id);

      expect(await repos.collections.decks(japanese.id), isEmpty);
      expect(await repos.cards.card(card.id), isNull);
      expect(await repos.notes.note(note.id), isNull);
      expect(await outboxCounts(), {'decks': 1});
      final decks = await db.select(db.decks).get();
      expect(decks.where((d) => d.deleted).single.id, japanese.deck.id);
      expect((await db.select(db.studyCards).getSingle()).deleted, isFalse);
      expect((await db.select(db.notes).getSingle()).deleted, isFalse);
    },
  );

  test('undoing a delete brings back everything below it', () async {
    final child = await japanese.addDeck('Child', parentId: japanese.deck.id);
    final (note, card) = await japanese.addNote('猫', deckId: child.id);
    await repos.collections.deleteDeck(japanese.deck.id);

    // As if a concurrent edit won over the delete during sync.
    await (db.update(
      db.decks,
    )..where((d) => d.id.equalsValue(japanese.deck.id))).write(
      DecksCompanion(deleted: const Value(false), hlc: Value(db.clock.tick())),
    );

    expect(await repos.collections.decks(japanese.id), hasLength(2));
    expect(await repos.cards.card(card.id), card);
    expect(await repos.notes.note(note.id), note);
  });

  test('a card moved out of a deck survives its deletion', () async {
    final other = await japanese.addDeck('Other');
    final (_, card) = await japanese.addNote('猫');
    await repos.cards.moveCard(card.id, other.id);
    await repos.collections.deleteDeck(japanese.deck.id);
    expect(await repos.cards.card(card.id), card.copyWith(deckId: other.id));
  });

  test('deleting a collection stamps only the collection', () async {
    await japanese.addNote('猫');
    await japanese.addTag('animals');
    await db.delete(db.outbox).go();

    await repos.collections.deleteCollection(japanese.id);

    expect(await outboxCounts(), {'collections': 1});
    expect(await repos.collections.decks(japanese.id), isEmpty);
    expect(await repos.tags.tags(japanese.id), isEmpty);
    expect(await repos.noteTypes.noteTypes(japanese.id), isEmpty);
    expect(await repos.notes.notes(japanese.id), isEmpty);
  });

  test('deleting a tag hides it and the tags below it on notes', () async {
    final (note, _) = await japanese.addNote('猫');
    final animals = await japanese.addTag('animals');
    final cats = await japanese.addTag('cats', parentId: animals.id);
    await repos.notes.addTag(note.id, cats.id);
    await db.delete(db.outbox).go();

    await repos.tags.deleteTag(animals.id);

    expect(await outboxCounts(), {'tags': 1});
    expect(await repos.tags.tags(japanese.id), isEmpty);
    expect(await repos.notes.tagIds(note.id), isEmpty);
  });

  test('a removed tag is revived when added again', () async {
    final (note, _) = await japanese.addNote('猫');
    final tag = await japanese.addTag('animals');
    await repos.notes.addTag(note.id, tag.id);
    await repos.notes.removeTag(note.id, tag.id);
    expect(await repos.notes.tagIds(note.id), isEmpty);

    await repos.notes.addTag(note.id, tag.id);
    expect(await repos.notes.tagIds(note.id), {tag.id});
    expect(await db.select(db.noteTags).get(), hasLength(1));
  });

  test('a deleted tag frees its name', () async {
    final tag = await japanese.addTag('grammar');
    await repos.tags.deleteTag(tag.id);
    await japanese.addTag('grammar');
    expect(await repos.tags.tags(japanese.id), hasLength(1));
  });

  test('a deleted card is revived by creating it again', () async {
    final second = StudyCardTemplate(
      id: StudyCardTemplateId.generate(),
      name: 'Card 2',
    );
    await repos.noteTypes.updateNoteType(
      japanese.noteType.copyWith(
        templates: [...japanese.noteType.templates, second],
      ),
    );
    final (note, _) = await japanese.addNote('猫');
    final card = StudyCard(
      noteId: note.id,
      templateId: second.id,
      deckId: japanese.deck.id,
    );
    await repos.cards.createCard(card);
    await repos.cards.deleteCard(card.id);
    await repos.cards.createCard(card);
    expect(await repos.cards.card(card.id), card);
    await expectLater(
      repos.cards.createCard(card),
      throwsA(isA<DuplicateEntityException>()),
    );
  });

  test("deleting a note's last card hides the note", () async {
    final (note, card) = await japanese.addNote('猫');
    await repos.cards.deleteCard(card.id);
    expect(await repos.notes.note(note.id), isNull);
    expect((await db.select(db.notes).getSingle()).deleted, isFalse);
  });

  test('removing a field hides its values until it is added back', () async {
    final [front, back] = japanese.noteType.fields;
    final note = Note(
      id: NoteId.generate(),
      collectionId: japanese.id,
      noteTypeId: japanese.noteType.id,
      fields: {front.id: '猫', back.id: 'cat'},
    );
    await repos.notes.createNote(note);
    await db.delete(db.outbox).go();

    await repos.noteTypes.updateNoteType(
      japanese.noteType.copyWith(fields: [front]),
    );
    expect((await repos.notes.note(note.id))!.fields, {front.id: '猫'});
    expect(await outboxCounts(), {'field_definitions': 1});

    await repos.noteTypes.updateNoteType(japanese.noteType);
    expect((await repos.notes.note(note.id))!.fields, note.fields);
  });

  test('a failed write records nothing', () async {
    await expectLater(
      repos.cards.createCard(
        StudyCard(
          noteId: NoteId.generate(),
          templateId: japanese.noteType.templates.single.id,
          deckId: japanese.deck.id,
        ),
      ),
      throwsA(isA<EntityNotFoundException>()),
    );
    expect(await db.select(db.outbox).get(), isEmpty);
  });

  test('an update that keeps the old timestamp is rejected', () async {
    await expectLater(
      db.update(db.decks).write(const DecksCompanion(name: Value('Renamed'))),
      throwsA(
        isA<SqliteException>().having(
          (e) => e.message,
          'message',
          contains('hlc must change'),
        ),
      ),
    );
    expect((await db.select(db.decks).getSingle()).name, japanese.deck.name);
  });

  test('review events cannot be updated', () async {
    final (_, card) = await japanese.addNote('猫');
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
    await expectLater(
      db
          .update(db.reviewEvents)
          .write(ReviewEventsCompanion(hlc: Value(db.clock.tick()))),
      throwsA(
        isA<SqliteException>().having(
          (e) => e.message,
          'message',
          contains('append-only'),
        ),
      ),
    );
  });

  test('a received timestamp is stored for the next start', () async {
    final remote = db.clock.last;
    final ahead = Hlc(remote.millis + 30000, 0, 'fedcba9876543210');
    await ChangeRecorder(db).receive(ahead);
    final stored = (await db.select(db.device).getSingle()).lastHlc!;
    expect(stored > ahead, isTrue);
    expect(stored.node, db.clock.node);
  });

  test('the clock continues across restarts', () async {
    final dir = await Directory.systemTemp.createTemp('memuki_clock_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/memuki.sqlite');
    // A clock far ahead of the wall clock, e.g. after receiving a change from
    // a device with a fast clock.
    final future = DateTime.utc(2100);

    final first = MemukiDatabase(NativeDatabase(file), now: () => future);
    await Repositories(first).seedCollection();
    final last = (await first.select(first.device).getSingle()).lastHlc!;
    final node = first.clock.node;
    await first.close();

    final second = MemukiDatabase(NativeDatabase(file));
    addTearDown(second.close);
    await second.ensureOpen();
    expect(second.clock.node, node);
    expect(second.clock.tick() > last, isTrue);
  });
}
