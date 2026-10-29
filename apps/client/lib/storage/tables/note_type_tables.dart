import 'package:drift/drift.dart';

import '../../domain/note_type.dart' show FieldType;
import '../converters.dart';
import 'collection_tables.dart';

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
