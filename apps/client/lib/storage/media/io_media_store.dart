import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../domain/ids.dart';
import 'media_store.dart';

/// A [MediaStore] in a directory of the local file system, with a folder per
/// collection: `<root>/<collection ID>/<hash>`.
///
/// Files are first written to `<root>/.tmp` while their hash is computed,
/// flushed to disk, and then renamed into place, so a file under its hash is
/// always complete.
class IoMediaStore implements MediaStore {
  IoMediaStore._(this._root);

  /// Opens the store in [root], creating it if needed. Partial files left by
  /// an interrupted write are removed.
  static Future<IoMediaStore> open(Directory root) async {
    final temp = Directory(p.join(root.path, _tempDir));
    if (await temp.exists()) await temp.delete(recursive: true);
    await temp.create(recursive: true);
    return IoMediaStore._(root);
  }

  static const _tempDir = '.tmp';
  static const _uuid = Uuid();

  final Directory _root;

  /// The file holding [hash] for [collectionId], for players that read from a
  /// path. It does not exist if the file was never stored.
  File file(CollectionId collectionId, ContentHash hash) =>
      File(p.join(_root.path, collectionId.value, hash.value));

  @override
  Future<StoredMedia> put(
    CollectionId collectionId,
    Stream<List<int>> bytes,
  ) async {
    final temp = File(p.join(_root.path, _tempDir, _uuid.v4()));
    final digest = _DigestSink();
    final hasher = sha256.startChunkedConversion(digest);
    var size = 0;
    final out = await temp.open(mode: FileMode.writeOnly);
    try {
      await for (final chunk in bytes) {
        hasher.add(chunk);
        size += chunk.length;
        await out.writeFrom(chunk);
      }
      await out.flush();
    } catch (_) {
      await out.close();
      await temp.delete();
      rethrow;
    }
    await out.close();
    hasher.close();

    final hash = ContentHash.parse(digest.value.toString());
    final target = file(collectionId, hash);
    if (await target.exists()) {
      await temp.delete();
    } else {
      await target.parent.create(recursive: true);
      await temp.rename(target.path);
    }
    return (hash: hash, sizeBytes: size);
  }

  @override
  Future<bool> contains(CollectionId collectionId, ContentHash hash) =>
      file(collectionId, hash).exists();

  @override
  Stream<List<int>> read(CollectionId collectionId, ContentHash hash) async* {
    final source = file(collectionId, hash);
    if (!await source.exists()) {
      throw MediaFileNotFoundException(collectionId, hash);
    }
    yield* source.openRead();
  }
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
