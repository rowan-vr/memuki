import 'package:drift/drift.dart';

import '../converters.dart';
import 'collection_tables.dart';
import 'sync_tables.dart';

@TableIndex(name: 'media_assets_hlc', columns: {#hlc})
@DataClassName('MediaAssetRow')
class MediaAssets extends Table with SyncedColumns {
  BlobColumn get collectionId =>
      blob().map(collectionIdConverter).references(Collections, #id)();
  BlobColumn get hash => blob().map(const ContentHashConverter())();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get originalName => text().nullable()();

  @override
  Set<Column> get primaryKey => {collectionId, hash};
}
