import 'package:drift/drift.dart';

import '../converters.dart';
import 'sync_tables.dart';

@TableIndex(name: 'collections_hlc', columns: {#hlc})
@DataClassName('CollectionRow')
class Collections extends Table with SyncedColumns {
  BlobColumn get id => blob().map(collectionIdConverter)();
  TextColumn get name => text()();

  /// The preset of root decks without their own.
  BlobColumn get defaultPresetId => blob().map(presetIdConverter)();

  /// The local time of day at which a study day starts, in minutes.
  IntColumn get dayStart => integer().map(const DurationMinutesConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (id, default_preset_id) '
        'REFERENCES presets (collection_id, id) DEFERRABLE INITIALLY DEFERRED',
  ];
}

@TableIndex(name: 'decks_parent', columns: {#collectionId, #parentId})
@TableIndex(name: 'decks_hlc', columns: {#hlc})
@DataClassName('DeckRow')
class Decks extends Table with SyncedColumns {
  BlobColumn get id => blob().map(deckIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get parentId => blob().map(deckIdConverter).nullable()();
  TextColumn get name => text()();

  /// Null to use the parent's preset.
  BlobColumn get presetId => blob().map(presetIdConverter).nullable()();

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
    'FOREIGN KEY (collection_id, preset_id) '
        'REFERENCES presets (collection_id, id) DEFERRABLE INITIALLY DEFERRED',
  ];
}
