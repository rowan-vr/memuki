import 'package:drift/drift.dart';

part 'db.g.dart';

// Representative subset of the Phase 1 schema: UUIDv7 blob keys, HLC text
// timestamps, tombstones, nested decks, per-collection note types, and a
// change outbox.

class Collections extends Table {
  BlobColumn get id => blob()();
  TextColumn get name => text()();
  TextColumn get hlc => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Decks extends Table {
  BlobColumn get id => blob()();
  BlobColumn get collectionId => blob().references(Collections, #id)();
  BlobColumn get parentId => blob().nullable().references(Decks, #id)();
  TextColumn get name => text()();
  TextColumn get hlc => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class NoteTypes extends Table {
  BlobColumn get id => blob()();
  BlobColumn get collectionId => blob().references(Collections, #id)();
  TextColumn get name => text()();
  TextColumn get hlc => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'notes_collection', columns: {#collectionId})
class Notes extends Table {
  BlobColumn get id => blob()();
  BlobColumn get collectionId => blob().references(Collections, #id)();
  BlobColumn get noteTypeId => blob().references(NoteTypes, #id)();
  TextColumn get fields => text()();
  TextColumn get hlc => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'cards_deck', columns: {#deckId})
class Cards extends Table {
  BlobColumn get id => blob()();
  BlobColumn get noteId => blob().references(Notes, #id)();
  BlobColumn get templateId => blob()();
  BlobColumn get deckId => blob().references(Decks, #id)();
  TextColumn get hlc => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {noteId, templateId},
  ];
}

@TableIndex(name: 'reviews_card', columns: {#cardId, #reviewedAt})
class ReviewEvents extends Table {
  BlobColumn get id => blob()();
  BlobColumn get cardId => blob().references(Cards, #id)();
  IntColumn get grade => integer()();
  IntColumn get reviewedAt => integer()();
  TextColumn get hlc => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Outbox extends Table {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get entityType => text()();
  BlobColumn get entityId => blob()();
  TextColumn get hlc => text()();
  TextColumn get payload => text()();
}

@DriftDatabase(
  tables: [Collections, Decks, NoteTypes, Notes, Cards, ReviewEvents, Outbox],
)
class AppDb extends _$AppDb {
  AppDb(super.e);

  @override
  int get schemaVersion => 1;
}

// Dictionaries live in their own database so a package can be removed without
// touching study data.
@TableIndex(name: 'dict_expression', columns: {#expression})
@TableIndex(name: 'dict_reading', columns: {#reading})
class DictEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get expression => text()();
  TextColumn get reading => text()();
  IntColumn get sequence => integer()();
  IntColumn get score => integer()();
  TextColumn get gloss => text()();
  TextColumn get content => text().nullable()();
}

@DriftDatabase(tables: [DictEntries])
class DictDb extends _$DictDb {
  DictDb(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        "CREATE VIRTUAL TABLE dict_fts USING fts5(expression, reading, gloss, "
        "content='dict_entries', content_rowid='id', tokenize='trigram')",
      );
    },
  );
}
