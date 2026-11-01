import 'package:drift/drift.dart';

import '../../domain/note_type.dart' show FieldType, StudyCardTemplate;
import '../converters.dart';
import 'collection_tables.dart';
import 'sync_tables.dart';

@TableIndex(name: 'note_types_collection', columns: {#collectionId})
@TableIndex(name: 'note_types_hlc', columns: {#hlc})
@DataClassName('NoteTypeRow')
class NoteTypes extends Table with SyncedColumns {
  BlobColumn get id => blob().map(noteTypeIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  TextColumn get name => text()();

  /// The field checked for duplicates. It may name a field that was
  /// removed, on this device or another; then none is checked.
  BlobColumn get duplicateCheck =>
      blob().map(fieldDefinitionIdConverter).nullable()();

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
@TableIndex(name: 'field_definitions_hlc', columns: {#hlc})
@DataClassName('FieldDefinitionRow')
class FieldDefinitions extends Table with SyncedColumns {
  BlobColumn get id => blob().map(fieldDefinitionIdConverter)();
  BlobColumn get noteTypeId => blob()
      .map(noteTypeIdConverter)
      .references(NoteTypes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
  TextColumn get type => textEnum<FieldType>()();
  TextColumn get language => text().nullable()();
  BoolColumn get required => boolean().withDefault(const Constant(false))();

  /// The mark keys its values may hold, or null for all.
  TextColumn get allowedMarks =>
      text().map(const KeySetConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Card templates of a note type, ordered by [position].
@TableIndex(name: 'study_card_templates_note_type', columns: {#noteTypeId})
@TableIndex(name: 'study_card_templates_hlc', columns: {#hlc})
@DataClassName('StudyCardTemplateRow')
class StudyCardTemplates extends Table with SyncedColumns {
  BlobColumn get id => blob().map(studyCardTemplateIdConverter)();
  BlobColumn get noteTypeId => blob()
      .map(noteTypeIdConverter)
      .references(NoteTypes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();

  /// What the card shows, in the content format.
  TextColumn get source =>
      text().withDefault(const Constant(StudyCardTemplate.blank))();

  @override
  Set<Column> get primaryKey => {id};
}
