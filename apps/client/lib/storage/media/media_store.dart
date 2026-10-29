import '../../domain/ids.dart';

/// Where media files are kept, outside the database.
///
/// Files are content-addressed: a file is named by the SHA-256 hash of its
/// bytes, so the same file is stored once per collection. Each collection has
/// its own files, so a collection can be synced, shared, or exported on its
/// own.
abstract interface class MediaStore {
  /// Stores [bytes] for [collectionId] and returns their hash and size. If
  /// the collection already has a file with the same bytes, it is kept and
  /// the new copy is dropped.
  ///
  /// The file is complete once this returns; an interrupted write leaves no
  /// file behind.
  Future<StoredMedia> put(CollectionId collectionId, Stream<List<int>> bytes);

  Future<bool> contains(CollectionId collectionId, ContentHash hash);

  /// The bytes of a stored file. The stream fails with a
  /// [MediaFileNotFoundException] if there is no such file.
  Stream<List<int>> read(CollectionId collectionId, ContentHash hash);
}

typedef StoredMedia = ({ContentHash hash, int sizeBytes});

class MediaFileNotFoundException implements Exception {
  MediaFileNotFoundException(this.collectionId, this.hash);

  final CollectionId collectionId;
  final ContentHash hash;

  @override
  String toString() =>
      'MediaFileNotFoundException: collection $collectionId has no file $hash';
}
