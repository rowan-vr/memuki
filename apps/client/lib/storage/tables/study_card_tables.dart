import 'package:drift/drift.dart';

import '../converters.dart';
import 'collection_tables.dart';
// Drift resolves the tables named in custom constraints from the imports, so
// the composite foreign key on notes needs this import.
// ignore: unused_import
import 'note_tables.dart';
import 'note_type_tables.dart';
import 'sync_tables.dart';

/// A card. Its note and deck must be in [collectionId]; its ID is derived
/// from `(note_id, template_id)`.
@TableIndex(name: 'study_cards_deck', columns: {#collectionId, #deckId})
@TableIndex(name: 'study_cards_template', columns: {#templateId})
@TableIndex(name: 'study_cards_hlc', columns: {#hlc})
@DataClassName('StudyCardRow')
class StudyCards extends Table with SyncedColumns {
  BlobColumn get id => blob().map(studyCardIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get noteId => blob().map(noteIdConverter)();
  BlobColumn get templateId => blob()
      .map(studyCardTemplateIdConverter)
      .references(StudyCardTemplates, #id)();
  BlobColumn get deckId => blob().map(deckIdConverter)();
  BoolColumn get suspended => boolean().withDefault(const Constant(false))();
  IntColumn get buriedUntil =>
      integer().map(const UtcMillisConverter()).nullable()();

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
