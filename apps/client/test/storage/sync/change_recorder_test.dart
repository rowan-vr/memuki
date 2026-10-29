import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/storage/database.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';
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
    'deleting a deck leaves tombstones for decks, cards, and notes',
    () async {
      final child = await japanese.addDeck('Child', parentId: japanese.deck.id);
      final (note, card) = await japanese.addNote('猫', deckId: child.id);
      await db.delete(db.outbox).go();

      await repos.collections.deleteDeck(japanese.deck.id);

      expect(await repos.collections.decks(japanese.id), isEmpty);
      expect(await repos.notes.note(note.id), isNull);
      final decks = await db.select(db.decks).get();
      expect(decks.map((d) => d.deleted), [true, true]);
      expect((await db.select(db.studyCards).getSingle()).deleted, isTrue);
      expect((await db.select(db.notes).getSingle()).deleted, isTrue);
      expect(await outboxCounts(), {'decks': 2, 'study_cards': 1, 'notes': 1});
      expect(await repos.cards.card(card.id), isNull);
    },
  );

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
    final (note, card) = await japanese.addNote('猫');
    await repos.cards.deleteCard(card.id);
    await repos.cards.createCard(card);
    expect(await repos.cards.card(card.id), card);
    await expectLater(
      repos.cards.createCard(card),
      throwsA(isA<DuplicateEntityException>()),
    );
    expect(note.id, card.noteId);
  });

  test('a removed field value is a tombstone', () async {
    final [front, back] = japanese.noteType.fields;
    final note = Note(
      id: NoteId.generate(),
      collectionId: japanese.id,
      noteTypeId: japanese.noteType.id,
      fields: {front.id: '猫', back.id: 'cat'},
    );
    await repos.notes.createNote(note);
    await repos.noteTypes.updateNoteType(
      japanese.noteType.copyWith(fields: [front]),
    );
    expect((await repos.notes.note(note.id))!.fields, {front.id: '猫'});
    final backRow = await (db.select(
      db.noteFields,
    )..where((f) => f.fieldId.equalsValue(back.id))).getSingle();
    expect(backRow.deleted, isTrue);
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
