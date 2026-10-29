import 'package:drift/drift.dart';

import '../converters.dart';

/// Columns of every synced table. [hlc] is the time of the row's last change;
/// deleted rows stay as tombstones with [deleted] set, so the deletion can be
/// synced.
mixin SyncedColumns on Table {
  TextColumn get hlc => text().map(const HlcConverter())();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
}

/// This installation. Holds a single row; not synced.
@DataClassName('DeviceRow')
class Device extends Table {
  IntColumn get id => integer()();

  /// The node ID in this device's HLC timestamps.
  TextColumn get node => text()();

  /// The latest timestamp issued, so the clock never goes backwards across
  /// restarts.
  TextColumn get lastHlc => text().map(const HlcConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Entities changed locally that are not yet pushed. One row per entity;
/// later changes overwrite its [hlc]. Sync reads the entity's current row
/// (which may be a tombstone) when pushing.
@TableIndex(name: 'outbox_hlc', columns: {#hlc})
@DataClassName('OutboxRow')
class Outbox extends Table {
  BlobColumn get collectionId => blob().map(collectionIdConverter)();
  TextColumn get entityTable => text()();

  /// The entity's primary key; composite keys are their parts' bytes
  /// concatenated.
  BlobColumn get entityKey => blob()();
  TextColumn get hlc => text().map(const HlcConverter())();

  @override
  Set<Column> get primaryKey => {entityTable, entityKey};
}
