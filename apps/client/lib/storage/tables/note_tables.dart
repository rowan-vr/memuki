import 'package:drift/drift.dart';

import '../../domain/note.dart' show SourceKind;
import '../converters.dart';
import 'collection_tables.dart';
import 'note_type_tables.dart';
import 'sync_tables.dart';

@TableIndex(name: 'notes_note_type', columns: {#collectionId, #noteTypeId})
@TableIndex(name: 'notes_hlc', columns: {#hlc})
@DataClassName('NoteRow')
class Notes extends Table with SyncedColumns {
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
@TableIndex(name: 'note_fields_hlc', columns: {#hlc})
@DataClassName('NoteFieldRow')
class NoteFields extends Table with SyncedColumns {
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

@TableIndex(name: 'tags_parent', columns: {#collectionId, #parentId})
@TableIndex(name: 'tags_hlc', columns: {#hlc})
@DataClassName('TagRow')
class Tags extends Table with SyncedColumns {
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

/// A tag on a note. Both must be in [collectionId].
@TableIndex(name: 'note_tags_tag', columns: {#collectionId, #tagId})
@TableIndex(name: 'note_tags_hlc', columns: {#hlc})
@DataClassName('NoteTagRow')
class NoteTags extends Table with SyncedColumns {
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
