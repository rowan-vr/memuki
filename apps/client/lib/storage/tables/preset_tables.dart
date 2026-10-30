import 'package:drift/drift.dart';

import '../../domain/preset.dart' show NewCardMix, NewCardOrder;
import '../converters.dart';
import 'collection_tables.dart';
import 'sync_tables.dart';

/// Presets of a collection. [currentVersionId] is the version used for new
/// reviews; changing it is an ordinary synced edit.
@TableIndex(name: 'presets_collection', columns: {#collectionId})
@TableIndex(name: 'presets_hlc', columns: {#hlc})
@DataClassName('PresetRow')
class Presets extends Table with SyncedColumns {
  BlobColumn get id => blob().map(presetIdConverter)();
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  TextColumn get name => text()();
  BlobColumn get currentVersionId => blob().map(presetVersionIdConverter)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {collectionId, id},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (id, current_version_id) '
        'REFERENCES preset_versions (preset_id, id) '
        'DEFERRABLE INITIALLY DEFERRED',
  ];
}

/// The settings of each preset version. Versions are synced but never
/// changed or deleted, so review events can always find the settings they
/// were recorded with.
@TableIndex(name: 'preset_versions_hlc', columns: {#hlc})
@DataClassName('PresetVersionRow')
class PresetVersions extends Table {
  BlobColumn get id => blob().map(presetVersionIdConverter)();
  BlobColumn get presetId => blob().map(presetIdConverter)();
  TextColumn get schedulerId => text()();

  /// JSON object.
  TextColumn get schedulerConfig => text().map(const JsonMapConverter())();
  IntColumn get burnThresholdDays => integer().nullable()();
  IntColumn get leechThreshold => integer().nullable()();
  IntColumn get newCardsPerDay => integer()();
  IntColumn get reviewsPerDay => integer()();
  TextColumn get newCardMix => textEnum<NewCardMix>()();
  TextColumn get newCardOrder => textEnum<NewCardOrder>()();
  BoolColumn get buryNewSiblings =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get buryReviewSiblings =>
      boolean().withDefault(const Constant(true))();
  TextColumn get hlc => text().map(const HlcConverter())();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {presetId, id},
  ];

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (preset_id) REFERENCES presets (id) '
        'DEFERRABLE INITIALLY DEFERRED',
  ];
}
