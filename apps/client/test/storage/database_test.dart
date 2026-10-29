import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/storage/database.dart';
import 'package:memuki/storage/database_exceptions.dart';
import 'package:memuki/storage/sync/hlc.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;

import 'generated_migrations/memuki/generated/schema.dart';

final _hlc = Hlc(0, 0, '0000000000000000');

/// A collection with one deck, note type, and note.
class _Seed {
  _Seed()
    : collectionId = CollectionId.generate(),
      deckId = DeckId.generate(),
      noteTypeId = NoteTypeId.generate(),
      fieldId = FieldDefinitionId.generate(),
      templateId = StudyCardTemplateId.generate(),
      noteId = NoteId.generate();

  final CollectionId collectionId;
  final DeckId deckId;
  final NoteTypeId noteTypeId;
  final FieldDefinitionId fieldId;
  final StudyCardTemplateId templateId;
  final NoteId noteId;

  Future<void> insertInto(MemukiDatabase db) => db.batch((b) {
    b.insert(
      db.collections,
      CollectionsCompanion.insert(
        hlc: _hlc,
        id: collectionId,
        name: 'Japanese',
      ),
    );
    b.insert(
      db.decks,
      DecksCompanion.insert(
        hlc: _hlc,
        id: deckId,
        collectionId: collectionId,
        name: 'Vocab',
      ),
    );
    b.insert(
      db.noteTypes,
      NoteTypesCompanion.insert(
        hlc: _hlc,
        id: noteTypeId,
        collectionId: collectionId,
        name: 'Basic',
      ),
    );
    b.insert(
      db.fieldDefinitions,
      FieldDefinitionsCompanion.insert(
        hlc: _hlc,
        id: fieldId,
        noteTypeId: noteTypeId,
        position: 0,
        name: 'Front',
        type: FieldType.text,
      ),
    );
    b.insert(
      db.studyCardTemplates,
      StudyCardTemplatesCompanion.insert(
        hlc: _hlc,
        id: templateId,
        noteTypeId: noteTypeId,
        position: 0,
        name: 'Card 1',
      ),
    );
    b.insert(
      db.notes,
      NotesCompanion.insert(
        hlc: _hlc,
        id: noteId,
        collectionId: collectionId,
        noteTypeId: noteTypeId,
      ),
    );
  });
}

final _throwsConstraint = throwsA(isA<SqliteException>());

/// A database one schema version ahead, with [steps] as its upgrade.
class _NextVersionDatabase extends MemukiDatabase {
  _NextVersionDatabase(super.e, this.steps, {super.backupDirectory});

  final Future<void> Function(MemukiDatabase db) steps;

  @override
  int get schemaVersion => 3;

  @override
  Future<void> upgradeSchema(Migrator m, int from, int to) => steps(this);
}

int _userVersion(File file) {
  final db = sqlite3.open(file.path);
  try {
    return db.userVersion;
  } finally {
    db.close();
  }
}

void main() {
  late MemukiDatabase db;

  // Tests open several databases, each on its own connection.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUp(() => db = MemukiDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('matches the snapshot of the current schema', () async {
    final verifier = SchemaVerifier(GeneratedHelper());
    final current = GeneratedHelper.versions.last;
    final connection = await verifier.startAt(current);
    final migrated = MemukiDatabase(connection);
    expect(migrated.schemaVersion, current);
    await verifier.migrateAndValidate(migrated, current);
    await migrated.close();
  });

  test('round-trips IDs, hashes, times, and durations', () async {
    final seed = _Seed();
    await seed.insertInto(db);
    final cardId = StudyCardId.derive(seed.noteId, seed.templateId);
    final eventId = ReviewEventId.generate();
    final at = DateTime.utc(2026, 10, 29, 8, 30, 15, 123);

    await db
        .into(db.studyCards)
        .insert(
          StudyCardsCompanion.insert(
            hlc: _hlc,
            id: cardId,
            collectionId: seed.collectionId,
            noteId: seed.noteId,
            templateId: seed.templateId,
            deckId: seed.deckId,
          ),
        );
    await db
        .into(db.reviewEvents)
        .insert(
          ReviewEventsCompanion.insert(
            hlc: _hlc,
            id: eventId,
            studyCardId: cardId,
            kind: ReviewEventKind.review,
            at: at,
            grade: const Value(Grade.good),
            responseTime: const Value(Duration(milliseconds: 4250)),
            schedulerId: 'sm2',
            schedulerVersion: 1,
            configVersion: 1,
          ),
        );

    final event = await db.select(db.reviewEvents).getSingle();
    expect(event.id, eventId);
    expect(event.studyCardId, cardId);
    expect(event.at, at);
    expect(event.at.isUtc, isTrue);
    expect(event.grade, Grade.good);
    expect(event.responseTime, const Duration(milliseconds: 4250));

    final raw = await db
        .customSelect('SELECT id, typeof(at) AS at_type FROM review_events')
        .getSingle();
    expect(raw.read<Uint8List>('id'), hasLength(16));
    expect(raw.read<String>('at_type'), 'integer');

    final hash = ContentHash.of([1, 2, 3]);
    await db
        .into(db.mediaAssets)
        .insert(
          MediaAssetsCompanion.insert(
            hlc: _hlc,
            collectionId: seed.collectionId,
            hash: hash,
            mimeType: 'audio/mpeg',
            sizeBytes: 3,
          ),
        );
    expect((await db.select(db.mediaAssets).getSingle()).hash, hash);
  });

  group('foreign keys', () {
    late _Seed seed;
    late _Seed other;

    setUp(() async {
      seed = _Seed();
      other = _Seed();
      await seed.insertInto(db);
      await other.insertInto(db);
    });

    test('reject a parent deck in another collection', () async {
      await expectLater(
        db
            .into(db.decks)
            .insert(
              DecksCompanion.insert(
                hlc: _hlc,
                id: DeckId.generate(),
                collectionId: seed.collectionId,
                parentId: Value(other.deckId),
                name: 'Child',
              ),
            ),
        _throwsConstraint,
      );
    });

    test('reject a parent tag in another collection', () async {
      final otherTag = TagId.generate();
      await db
          .into(db.tags)
          .insert(
            TagsCompanion.insert(
              hlc: _hlc,
              id: otherTag,
              collectionId: other.collectionId,
              name: 'grammar',
            ),
          );
      await expectLater(
        db
            .into(db.tags)
            .insert(
              TagsCompanion.insert(
                hlc: _hlc,
                id: TagId.generate(),
                collectionId: seed.collectionId,
                parentId: Value(otherTag),
                name: 'particles',
              ),
            ),
        _throwsConstraint,
      );
    });

    test('reject a note type in another collection', () async {
      await expectLater(
        db
            .into(db.notes)
            .insert(
              NotesCompanion.insert(
                hlc: _hlc,
                id: NoteId.generate(),
                collectionId: seed.collectionId,
                noteTypeId: other.noteTypeId,
              ),
            ),
        _throwsConstraint,
      );
    });

    test('reject a card in a deck of another collection', () async {
      await expectLater(
        db
            .into(db.studyCards)
            .insert(
              StudyCardsCompanion.insert(
                hlc: _hlc,
                id: StudyCardId.derive(seed.noteId, seed.templateId),
                collectionId: seed.collectionId,
                noteId: seed.noteId,
                templateId: seed.templateId,
                deckId: other.deckId,
              ),
            ),
        _throwsConstraint,
      );
    });

    test('reject a note tag across collections', () async {
      final otherTag = TagId.generate();
      await db
          .into(db.tags)
          .insert(
            TagsCompanion.insert(
              hlc: _hlc,
              id: otherTag,
              collectionId: other.collectionId,
              name: 'grammar',
            ),
          );
      await expectLater(
        db
            .into(db.noteTags)
            .insert(
              NoteTagsCompanion.insert(
                hlc: _hlc,
                collectionId: seed.collectionId,
                noteId: seed.noteId,
                tagId: otherTag,
              ),
            ),
        _throwsConstraint,
      );
    });

    test('allow a child deck before its parent within a transaction', () async {
      final parent = DeckId.generate();
      await db.transaction(() async {
        await db
            .into(db.decks)
            .insert(
              DecksCompanion.insert(
                hlc: _hlc,
                id: DeckId.generate(),
                collectionId: seed.collectionId,
                parentId: Value(parent),
                name: 'Child',
              ),
            );
        await db
            .into(db.decks)
            .insert(
              DecksCompanion.insert(
                hlc: _hlc,
                id: parent,
                collectionId: seed.collectionId,
                name: 'Parent',
              ),
            );
      });
      expect(await db.select(db.decks).get(), hasLength(4));
    });

    test('reject a missing parent deck at commit', () async {
      await expectLater(
        db.transaction(
          () => db
              .into(db.decks)
              .insert(
                DecksCompanion.insert(
                  hlc: _hlc,
                  id: DeckId.generate(),
                  collectionId: seed.collectionId,
                  parentId: Value(DeckId.generate()),
                  name: 'Orphan',
                ),
              ),
        ),
        _throwsConstraint,
      );
      expect(await db.select(db.decks).get(), hasLength(2));
    });
  });

  test('collection_id cannot change', () async {
    final seed = _Seed();
    final other = _Seed();
    await seed.insertInto(db);
    await other.insertInto(db);

    await expectLater(
      (db.update(db.decks)..where((d) => d.id.equalsValue(seed.deckId))).write(
        DecksCompanion(collectionId: Value(other.collectionId)),
      ),
      throwsA(
        isA<SqliteException>().having(
          (e) => e.message,
          'message',
          contains('collection_id is immutable'),
        ),
      ),
    );
    // Updating other columns still works.
    await (db.update(db.decks)..where((d) => d.id.equalsValue(seed.deckId)))
        .write(const DecksCompanion(name: Value('Renamed')));
  });

  group('opening', () {
    late Directory dir;
    late File file;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('memuki_db_test');
      file = File('${dir.path}/memuki.sqlite');
      final v1 = MemukiDatabase(NativeDatabase(file));
      await _Seed().insertInto(v1);
      await v1.close();
    });

    tearDown(() => dir.delete(recursive: true));

    test('exceptions describe the versions involved', () {
      expect(
        const DatabaseTooNewException(found: 3, supported: 2).toString(),
        contains('v3 is newer than the supported v2'),
      );
      expect(
        DatabaseMigrationException(
          from: 1,
          to: 2,
          cause: StateError('boom'),
        ).toString(),
        allOf(contains('from v1 to v2'), contains('boom')),
      );
    });

    test('refuses a database from a newer schema', () async {
      final newer = _NextVersionDatabase(NativeDatabase(file), (_) async {});
      await newer.customSelect('SELECT 1').get();
      await newer.close();

      final current = MemukiDatabase(NativeDatabase(file));
      await expectLater(
        current.customSelect('SELECT 1').get(),
        throwsA(
          isA<DatabaseTooNewException>()
              .having((e) => e.found, 'found', 3)
              .having((e) => e.supported, 'supported', 2),
        ),
      );
      await current.close();
      expect(_userVersion(file), 3);
    });

    test('upgrades and writes a backup first', () async {
      final next = _NextVersionDatabase(
        NativeDatabase(file),
        (db) => db.customStatement('ALTER TABLE decks ADD COLUMN note TEXT'),
        backupDirectory: () async => dir,
      );
      await next.customSelect('SELECT 1').get();
      await next.close();

      expect(_userVersion(file), 3);
      final backups = dir.listSync().whereType<File>().where(
        (f) => f.path.contains('memuki-v2-'),
      );
      expect(backups, hasLength(1));
      expect(_userVersion(backups.single), 2);
    });

    test('rolls back a failed upgrade', () async {
      final failing = _NextVersionDatabase(NativeDatabase(file), (db) async {
        await db.customStatement('DROP TABLE notes');
        throw StateError('step failed');
      });
      await expectLater(
        failing.customSelect('SELECT 1').get(),
        throwsA(
          isA<DatabaseMigrationException>()
              .having((e) => e.from, 'from', 2)
              .having((e) => e.to, 'to', 3),
        ),
      );
      await failing.close();

      expect(_userVersion(file), 2);
      final reopened = MemukiDatabase(NativeDatabase(file));
      expect(await reopened.select(reopened.notes).get(), hasLength(1));
      await reopened.close();
    });

    test('rejects an upgrade that leaves foreign key violations', () async {
      final violating = _NextVersionDatabase(
        NativeDatabase(file),
        (db) => db.customStatement('DELETE FROM note_types'),
      );
      await expectLater(
        violating.customSelect('SELECT 1').get(),
        throwsA(isA<DatabaseMigrationException>()),
      );
      await violating.close();

      final reopened = MemukiDatabase(NativeDatabase(file));
      expect(await reopened.select(reopened.noteTypes).get(), hasLength(1));
      await reopened.close();
    });
  });
}
