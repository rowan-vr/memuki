import 'package:drift/drift.dart';

import '../domain/note.dart' show SourceKind;
import '../domain/note_type.dart' show FieldType;
import '../domain/review.dart' show Grade, ReviewEventKind, StudyCardState;
import 'converters.dart';

// Row classes are named `*Row` and mapped to domain models by repositories.
//
// IDs are stored as 16-byte blobs and times as UTC milliseconds. Enums are
// stored by name, so adding or reordering values does not change stored data.
//
// Rows that belong to a collection carry `collection_id`, and references
// between them are composite foreign keys on `(collection_id, id)`. A
// reference into another collection is therefore rejected by the database on
// every write path. `collection_id` cannot change after creation (see
// triggers.drift). Self-references (deck and tag parents) are deferred to
// commit, so a subtree can be written in any order within a transaction.

@DataClassName('CollectionRow')
class Collections extends Table {
  BlobColumn get id => blob().map(collectionIdConverter)();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'decks_parent', columns: {#collectionId, #parentId})
@DataClassName('DeckRow')
class Decks extends Table {
  BlobColumn get id => blob().map(deckIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get parentId => blob().map(deckIdConverter).nullable()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {collectionId, id},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (collection_id, parent_id) '
        'REFERENCES decks (collection_id, id) DEFERRABLE INITIALLY DEFERRED',
  ];
}

@TableIndex(name: 'tags_parent', columns: {#collectionId, #parentId})
@DataClassName('TagRow')
class Tags extends Table {
  BlobColumn get id => blob().map(tagIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get parentId => blob().map(tagIdConverter).nullable()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {collectionId, id},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (collection_id, parent_id) '
        'REFERENCES tags (collection_id, id) DEFERRABLE INITIALLY DEFERRED',
  ];
}

@TableIndex(name: 'note_types_collection', columns: {#collectionId})
@DataClassName('NoteTypeRow')
class NoteTypes extends Table {
  BlobColumn get id => blob().map(noteTypeIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {collectionId, id},
  ];
}

/// Fields of a note type, ordered by [position]. Unique positions and names
/// are enforced by the domain model, so reordering needs no temporary values.
@TableIndex(name: 'field_definitions_note_type', columns: {#noteTypeId})
@DataClassName('FieldDefinitionRow')
class FieldDefinitions extends Table {
  BlobColumn get id => blob().map(fieldDefinitionIdConverter)();
  BlobColumn get noteTypeId => blob()
      .map(noteTypeIdConverter)
      .references(NoteTypes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<FieldType>()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Card templates of a note type, ordered by [position].
@TableIndex(name: 'study_card_templates_note_type', columns: {#noteTypeId})
@DataClassName('StudyCardTemplateRow')
class StudyCardTemplates extends Table {
  BlobColumn get id => blob().map(studyCardTemplateIdConverter)();
  BlobColumn get noteTypeId => blob()
      .map(noteTypeIdConverter)
      .references(NoteTypes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'notes_note_type', columns: {#collectionId, #noteTypeId})
@DataClassName('NoteRow')
class Notes extends Table {
  BlobColumn get id => blob().map(noteIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get noteTypeId => blob().map(noteTypeIdConverter)();
  TextColumn get sourceKind => textEnum<SourceKind>().nullable()();
  TextColumn get sourceReference => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {collectionId, id},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (collection_id, note_type_id) '
        'REFERENCES note_types (collection_id, id)',
    'CHECK (source_reference IS NULL OR source_kind IS NOT NULL)',
  ];
}

/// One row per field value of a note. Fields without a value have no row.
@TableIndex(name: 'note_fields_field', columns: {#fieldId})
@DataClassName('NoteFieldRow')
class NoteFields extends Table {
  BlobColumn get noteId => blob()
      .map(noteIdConverter)
      .references(Notes, #id, onDelete: KeyAction.cascade)();
  BlobColumn get fieldId => blob()
      .map(fieldDefinitionIdConverter)
      .references(FieldDefinitions, #id, onDelete: KeyAction.cascade)();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {noteId, fieldId};
}

/// A tag on a note. Both must be in [collectionId].
@TableIndex(name: 'note_tags_tag', columns: {#collectionId, #tagId})
@DataClassName('NoteTagRow')
class NoteTags extends Table {
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get noteId => blob().map(noteIdConverter)();
  BlobColumn get tagId => blob().map(tagIdConverter)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (collection_id, note_id) '
        'REFERENCES notes (collection_id, id) ON DELETE CASCADE',
    'FOREIGN KEY (collection_id, tag_id) '
        'REFERENCES tags (collection_id, id) ON DELETE CASCADE',
  ];
}

/// A card. Its note and deck must be in [collectionId]; its ID is derived
/// from `(note_id, template_id)`.
@TableIndex(name: 'study_cards_deck', columns: {#collectionId, #deckId})
@TableIndex(name: 'study_cards_template', columns: {#templateId})
@DataClassName('StudyCardRow')
class StudyCards extends Table {
  BlobColumn get id => blob().map(studyCardIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get noteId => blob().map(noteIdConverter)();
  BlobColumn get templateId => blob()
      .map(studyCardTemplateIdConverter)
      .references(StudyCardTemplates, #id)();
  BlobColumn get deckId => blob().map(deckIdConverter)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {noteId, templateId},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (collection_id, note_id) '
        'REFERENCES notes (collection_id, id)',
    'FOREIGN KEY (collection_id, deck_id) '
        'REFERENCES decks (collection_id, id)',
  ];
}

@DataClassName('MediaAssetRow')
class MediaAssets extends Table {
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get hash => blob().map(const ContentHashConverter())();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get originalName => text().nullable()();

  @override
  Set<Column> get primaryKey => {collectionId, hash};
}

/// The append-only review history.
@TableIndex(name: 'review_events_card', columns: {#studyCardId, #at})
@TableIndex(name: 'review_events_at', columns: {#at})
@DataClassName('ReviewEventRow')
class ReviewEvents extends Table {
  BlobColumn get id => blob().map(reviewEventIdConverter)();
  BlobColumn get studyCardId =>
      blob().map(studyCardIdConverter).references(StudyCards, #id)();
  TextColumn get kind => textEnum<ReviewEventKind>()();
  IntColumn get at => integer().map(const UtcMillisConverter())();
  TextColumn get grade => textEnum<Grade>().nullable()();
  IntColumn get responseTime =>
      integer().map(const DurationMillisConverter()).nullable()();
  IntColumn get dueBefore =>
      integer().map(const UtcMillisConverter()).nullable()();
  IntColumn get dueAfter =>
      integer().map(const UtcMillisConverter()).nullable()();
  BlobColumn get undoneEventId => blob()
      .map(reviewEventIdConverter)
      .nullable()
      .references(ReviewEvents, #id)();
  TextColumn get schedulerId => text()();
  IntColumn get schedulerVersion => integer()();
  IntColumn get configVersion => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The materialized scheduling state of each card, rebuildable from
/// [ReviewEvents].
@TableIndex(name: 'scheduling_states_due', columns: {#state, #due})
@DataClassName('SchedulingStateRow')
class SchedulingStates extends Table {
  BlobColumn get studyCardId => blob()
      .map(studyCardIdConverter)
      .references(StudyCards, #id, onDelete: KeyAction.cascade)();
  TextColumn get state => textEnum<StudyCardState>()();
  IntColumn get due => integer().map(const UtcMillisConverter()).nullable()();
  IntColumn get interval => integer().map(const DurationMillisConverter())();
  RealColumn get ease => real().nullable()();
  IntColumn get step => integer()();
  IntColumn get lapses => integer()();
  IntColumn get reviewCount => integer()();
  BlobColumn get lastEventId => blob()
      .map(reviewEventIdConverter)
      .nullable()
      .references(ReviewEvents, #id)();

  @override
  Set<Column> get primaryKey => {studyCardId};
}
