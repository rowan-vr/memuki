import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/collection.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/storage/database.dart';
import 'package:memuki/storage/media/io_media_store.dart';
import 'package:memuki/storage/repositories/media_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

/// Everything a write case needs: the database, its repositories, and the
/// collection already in it.
typedef _World = ({
  MemukiDatabase db,
  Repositories repos,
  MediaRepository media,
  CollectionFixture fixture,
});

/// A repository write, with optional setup that runs before the database is
/// compared.
typedef _Case = ({
  Future<Object?> Function(_World w)? arrange,
  Future<void> Function(_World w, Object? arranged) act,
});

/// Every repository write. A write that is missing here is not checked, so
/// new write methods belong in this list.
final _writes = <String, _Case>{
  'createCollection': (
    arrange: null,
    act: (w, _) => w.repos.collections.createCollection(
      Collection(id: CollectionId.generate(), name: 'New'),
    ),
  ),
  'updateCollection': (
    arrange: null,
    act: (w, _) => w.repos.collections.updateCollection(
      w.fixture.collection.copyWith(name: 'Renamed'),
    ),
  ),
  'deleteCollection': (
    arrange: null,
    act: (w, _) => w.repos.collections.deleteCollection(w.fixture.id),
  ),
  'createDeck': (
    arrange: null,
    act: (w, _) => w.repos.collections.createDeck(
      Deck(
        id: DeckId.generate(),
        collectionId: w.fixture.id,
        parentId: w.fixture.decks.first.id,
        name: 'New',
      ),
    ),
  ),
  'updateDeck': (
    arrange: null,
    act: (w, _) => w.repos.collections.updateDeck(
      w.fixture.decks.last.copyWith(name: 'Renamed'),
    ),
  ),
  'deleteDeck': (
    arrange: null,
    act: (w, _) => w.repos.collections.deleteDeck(w.fixture.decks.first.id),
  ),
  'createTag': (
    arrange: null,
    act: (w, _) => w.repos.tags.createTag(
      Tag(id: TagId.generate(), collectionId: w.fixture.id, name: 'new'),
    ),
  ),
  'updateTag': (
    arrange: null,
    act: (w, _) =>
        w.repos.tags.updateTag(w.fixture.tags.last.copyWith(name: 'renamed')),
  ),
  'deleteTag': (
    arrange: null,
    act: (w, _) => w.repos.tags.deleteTag(w.fixture.tags.first.id),
  ),
  'createNoteType': (
    arrange: null,
    act: (w, _) => w.repos.noteTypes.createNoteType(_spareNoteType(w)),
  ),
  'updateNoteType': (
    arrange: null,
    act: (w, _) {
      final noteType = w.fixture.noteType;
      return w.repos.noteTypes.updateNoteType(
        noteType.copyWith(
          name: 'Renamed',
          fields: [
            noteType.fields.first,
            FieldDefinition(id: FieldDefinitionId.generate(), name: 'Extra'),
          ],
        ),
      );
    },
  ),
  'deleteNoteType': (
    arrange: (w) async {
      final noteType = _spareNoteType(w);
      await w.repos.noteTypes.createNoteType(noteType);
      return noteType.id;
    },
    act: (w, id) => w.repos.noteTypes.deleteNoteType(id! as NoteTypeId),
  ),
  'createNote': (
    arrange: null,
    act: (w, _) => w.repos.notes.createNote(_newNote(w)),
  ),
  'updateNote': (
    arrange: null,
    act: (w, _) {
      final note = w.fixture.notes.first;
      return w.repos.notes.updateNote(
        note.copyWith(
          fields: {
            for (final field in w.fixture.noteType.fields) field.id: 'changed',
          },
        ),
      );
    },
  ),
  'deleteNote': (
    arrange: null,
    act: (w, _) => w.repos.notes.deleteNote(w.fixture.notes.first.id),
  ),
  'addTag': (
    arrange: (w) async {
      final note = _newNote(w);
      await w.repos.notes.createNote(note);
      return note.id;
    },
    act: (w, id) =>
        w.repos.notes.addTag(id! as NoteId, w.fixture.tags.first.id),
  ),
  'removeTag': (
    arrange: (w) async {
      final note = w.fixture.notes.first;
      await w.repos.notes.addTag(note.id, w.fixture.tags.first.id);
      return note.id;
    },
    act: (w, id) =>
        w.repos.notes.removeTag(id! as NoteId, w.fixture.tags.first.id),
  ),
  'createCard': (
    arrange: (w) async {
      final note = _newNote(w);
      await w.repos.notes.createNote(note);
      return note.id;
    },
    act: (w, id) => w.repos.cards.createCard(
      StudyCard(
        noteId: id! as NoteId,
        templateId: w.fixture.noteType.templates.first.id,
        deckId: w.fixture.decks.first.id,
      ),
    ),
  ),
  'moveCard': (
    arrange: (w) async {
      final deck = Deck(
        id: DeckId.generate(),
        collectionId: w.fixture.id,
        name: 'Target',
      );
      await w.repos.collections.createDeck(deck);
      return deck.id;
    },
    act: (w, id) =>
        w.repos.cards.moveCard(w.fixture.cards.first.id, id! as DeckId),
  ),
  'deleteCard': (
    arrange: null,
    act: (w, _) => w.repos.cards.deleteCard(w.fixture.cards.first.id),
  ),
  'saveSchedulingState': (
    arrange: null,
    act: (w, _) => w.repos.cards.saveSchedulingState(
      SchedulingState(
        studyCardId: w.fixture.cards.first.id,
        state: StudyCardState.burned,
      ),
    ),
  ),
  'append': (
    arrange: null,
    act: (w, _) => w.repos.reviews.append(
      ReviewEvent(
        id: ReviewEventId.generate(),
        studyCardId: w.fixture.cards.first.id,
        kind: ReviewEventKind.review,
        at: fixtureEpoch,
        grade: Grade.good,
        schedulerId: 'sm2',
        schedulerVersion: 1,
        configVersion: 1,
      ),
    ),
  ),
  'addMedia': (
    arrange: null,
    act: (w, _) => w.media.addMedia(
      w.fixture.id,
      Stream.value(utf8.encode('new')),
      name: 'new.txt',
    ),
  ),
  'deleteMedia': (
    arrange: (w) async => (await w.media.mediaOf(w.fixture.id)).first.hash,
    act: (w, hash) => w.media.deleteMedia(w.fixture.id, hash! as ContentHash),
  ),
};

NoteType _spareNoteType(_World w) => NoteType(
  id: NoteTypeId.generate(),
  collectionId: w.fixture.id,
  name: 'Spare',
  fields: [FieldDefinition(id: FieldDefinitionId.generate(), name: 'Text')],
  templates: [
    StudyCardTemplate(id: StudyCardTemplateId.generate(), name: 'Card'),
  ],
);

Note _newNote(_World w) => Note(
  id: NoteId.generate(),
  collectionId: w.fixture.id,
  noteTypeId: w.fixture.noteType.id,
  fields: {w.fixture.noteType.fields.first.id: 'new'},
);

/// Makes the last steps of a write fail: recording it in the outbox, and
/// saving scheduling state.
Future<void> _injectFailure(MemukiDatabase db) async {
  for (final table in ['outbox', 'scheduling_states']) {
    for (final event in ['INSERT', 'UPDATE']) {
      await db.customStatement(
        'CREATE TEMP TRIGGER fail_${table}_${event.toLowerCase()} '
        'BEFORE $event ON $table '
        "BEGIN SELECT RAISE(ABORT, 'injected failure'); END",
      );
    }
  }
}

void main() {
  late _World world;

  setUp(() async {
    final db = openFixtureDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final root = await Directory.systemTemp.createTemp('memuki_rollback_test');
    addTearDown(() => root.delete(recursive: true));
    final media = MediaRepository(db, await IoMediaStore.open(root));
    final repos = Repositories(db);
    final fixture = CollectionFixture.generate(seed: 11);
    await fixture.writeTo(repos, media);
    world = (db: db, repos: repos, media: media, fixture: fixture);
  });

  group('a write that fails partway leaves nothing behind', () {
    for (final MapEntry(key: name, value: write) in _writes.entries) {
      test(name, () async {
        final arranged = await write.arrange?.call(world);
        final before = await dumpTables(world.db);
        await _injectFailure(world.db);

        // Only the injected error counts: a write that fails for another
        // reason, or changes nothing, would not reach it.
        await expectLater(
          write.act(world, arranged),
          throwsA(
            predicate((e) => '$e'.contains('injected failure'), 'injected'),
          ),
        );
        expect(await dumpTables(world.db), before);
      });
    }
  });
}
