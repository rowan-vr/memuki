import 'package:drift/drift.dart';

import '../converters.dart';
import 'collection_tables.dart';

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
