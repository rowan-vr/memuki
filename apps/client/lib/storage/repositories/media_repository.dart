import 'package:drift/drift.dart';
import 'package:mime/mime.dart';

import '../../domain/ids.dart';
import '../../domain/media_asset.dart';
import '../database.dart';
import '../media/media_store.dart';
import '../sync/change_recorder.dart';
import 'repository_exceptions.dart';
import 'visibility.dart';

/// Media files of a collection: their bytes in a [MediaStore] and their
/// metadata in the database.
///
/// Adding writes the file before its row, so a row never points to a missing
/// file. An interrupted add can leave a file without a row, which is harmless
/// and is removed with other unused files when tombstones are purged
/// (Phase 8). Deleting tombstones the row and keeps the file for the same
/// reason.
class MediaRepository {
  MediaRepository(this._db, this._store) : _changes = ChangeRecorder(_db);

  static const _fallbackMimeType = 'application/octet-stream';

  final MemukiDatabase _db;
  final MediaStore _store;
  final ChangeRecorder _changes;

  Future<MediaAsset?> media(CollectionId collectionId, ContentHash hash) async {
    final row =
        await (_db.select(_db.visibleMediaAssets)..where(
              (m) =>
                  m.collectionId.equalsValue(collectionId) &
                  m.hash.equalsValue(hash),
            ))
            .getSingleOrNull();
    return row == null ? null : _asset(row);
  }

  /// All media of a collection, by hash.
  Future<List<MediaAsset>> mediaOf(CollectionId collectionId) =>
      (_db.select(_db.visibleMediaAssets)
            ..where((m) => m.collectionId.equalsValue(collectionId))
            ..orderBy([(m) => OrderingTerm(expression: m.hash)]))
          .map(_asset)
          .get();

  /// Adds a file to a collection and returns its asset.
  ///
  /// The MIME type is detected from the file's first bytes and its [name];
  /// [mimeType] is used when neither identifies it. Adding a file the
  /// collection already has returns the existing asset, and adding one that
  /// was deleted brings it back.
  Future<MediaAsset> addMedia(
    CollectionId collectionId,
    Stream<List<int>> bytes, {
    String? name,
    String? mimeType,
  }) async {
    await _requireCollection(collectionId);
    final header = <int>[];
    final stored = await _store.put(
      collectionId,
      bytes.map((chunk) {
        final missing = defaultMagicNumbersMaxLength - header.length;
        if (missing > 0) header.addAll(chunk.take(missing));
        return chunk;
      }),
    );
    final asset = MediaAsset(
      collectionId: collectionId,
      hash: stored.hash,
      mimeType:
          lookupMimeType(name ?? '', headerBytes: header) ??
          mimeType ??
          _fallbackMimeType,
      sizeBytes: stored.sizeBytes,
      originalName: name,
    );
    return _changes.write((hlc) async {
      await _requireCollection(collectionId);
      if (await media(collectionId, stored.hash) case final existing?) {
        return existing;
      }
      await _db
          .into(_db.mediaAssets)
          .insertOnConflictUpdate(
            MediaAssetsCompanion.insert(
              collectionId: collectionId,
              hash: asset.hash,
              mimeType: asset.mimeType,
              sizeBytes: asset.sizeBytes,
              originalName: Value(asset.originalName),
              hlc: hlc,
              deleted: const Value(false),
            ),
          );
      return asset;
    });
  }

  /// The bytes of a media file.
  ///
  /// Fails with an [EntityNotFoundException] if the collection has no such
  /// media, and with a [MediaFileNotFoundException] if the file is missing
  /// (for example, not yet downloaded by sync).
  Stream<List<int>> read(CollectionId collectionId, ContentHash hash) async* {
    if (await media(collectionId, hash) == null) throw _notFound(hash);
    yield* _store.read(collectionId, hash);
  }

  /// Deletes a media asset. Its file is kept until tombstones are purged.
  Future<void> deleteMedia(CollectionId collectionId, ContentHash hash) =>
      _changes.write((hlc) async {
        if (await media(collectionId, hash) == null) throw _notFound(hash);
        await (_db.update(_db.mediaAssets)..where(
              (m) =>
                  m.collectionId.equalsValue(collectionId) &
                  m.hash.equalsValue(hash),
            ))
            .write(
              MediaAssetsCompanion(deleted: const Value(true), hlc: Value(hlc)),
            );
      });

  Future<void> _requireCollection(CollectionId id) async {
    final collection =
        await (_db.select(_db.collections)..where(
              (c) => c.id.equalsValue(id) & _db.isVisibleCollection(c.id),
            ))
            .getSingleOrNull();
    if (collection == null) {
      throw EntityNotFoundException('Collection $id does not exist');
    }
  }
}

MediaAsset _asset(VisibleMediaAsset row) => MediaAsset(
  collectionId: row.collectionId,
  hash: row.hash,
  mimeType: row.mimeType,
  sizeBytes: row.sizeBytes,
  originalName: row.originalName,
);

EntityNotFoundException _notFound(ContentHash hash) =>
    EntityNotFoundException('Media $hash does not exist');
