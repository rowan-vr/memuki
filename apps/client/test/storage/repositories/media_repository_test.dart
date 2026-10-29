import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/storage/database.dart';
import 'package:memuki/storage/media/io_media_store.dart';
import 'package:memuki/storage/media/media_store.dart';
import 'package:memuki/storage/repositories/media_repository.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../../helpers/test_database.dart';

/// The first bytes of a PNG file.
const _png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0];

void main() {
  late MemukiDatabase db;
  late Repositories repos;
  late IoMediaStore store;
  late MediaRepository media;
  late SeededCollection japanese;

  setUp(() async {
    db = openTestDatabase();
    repos = Repositories(db);
    final root = await Directory.systemTemp.createTemp('memuki_media_test');
    addTearDown(() => root.delete(recursive: true));
    store = await IoMediaStore.open(root);
    media = MediaRepository(db, store);
    japanese = await repos.seedCollection();
  });

  Stream<List<int>> text(String value) => Stream.value(utf8.encode(value));

  test('adds a file and its metadata', () async {
    final asset = await media.addMedia(
      japanese.id,
      text('neko'),
      name: 'neko.txt',
    );
    expect(asset.hash, ContentHash.of(utf8.encode('neko')));
    expect(asset.sizeBytes, 4);
    expect(asset.originalName, 'neko.txt');
    expect(await media.media(japanese.id, asset.hash), asset);
    expect(await media.mediaOf(japanese.id), [asset]);
    final bytes = await media.read(japanese.id, asset.hash).toList();
    expect(utf8.decode(bytes.expand((b) => b).toList()), 'neko');
  });

  group('MIME type', () {
    test('is detected from the first bytes', () async {
      final asset = await media.addMedia(
        japanese.id,
        Stream.value(_png),
        name: 'picture.mp3',
        mimeType: 'audio/mpeg',
      );
      expect(asset.mimeType, 'image/png');
    });

    test('falls back to the name, then to the caller', () async {
      final named = await media.addMedia(
        japanese.id,
        text('a'),
        name: 'neko.mp3',
      );
      expect(named.mimeType, 'audio/mpeg');
      final given = await media.addMedia(
        japanese.id,
        text('b'),
        mimeType: 'audio/ogg',
      );
      expect(given.mimeType, 'audio/ogg');
      final unknown = await media.addMedia(japanese.id, text('c'));
      expect(unknown.mimeType, 'application/octet-stream');
    });
  });

  test('adding a file twice returns the existing asset', () async {
    final first = await media.addMedia(japanese.id, text('neko'), name: 'a');
    final second = await media.addMedia(japanese.id, text('neko'), name: 'b');
    expect(second, first);
    expect(await media.mediaOf(japanese.id), hasLength(1));
  });

  test('a deleted file is hidden and comes back when added again', () async {
    final asset = await media.addMedia(japanese.id, text('neko'));
    await media.deleteMedia(japanese.id, asset.hash);
    expect(await media.media(japanese.id, asset.hash), isNull);
    await expectLater(
      media.read(japanese.id, asset.hash).toList(),
      throwsA(isA<EntityNotFoundException>()),
    );
    // The file stays until tombstones are purged.
    expect(await store.contains(japanese.id, asset.hash), isTrue);
    await expectLater(
      media.deleteMedia(japanese.id, asset.hash),
      throwsA(isA<EntityNotFoundException>()),
    );

    await media.addMedia(japanese.id, text('neko'));
    expect(await media.media(japanese.id, asset.hash), asset);
  });

  test('media of a deleted collection is hidden', () async {
    final asset = await media.addMedia(japanese.id, text('neko'));
    await repos.collections.deleteCollection(japanese.id);
    expect(await media.media(japanese.id, asset.hash), isNull);
    expect(await media.mediaOf(japanese.id), isEmpty);
  });

  test('cannot add to a collection that does not exist', () async {
    final missing = CollectionId.generate();
    await expectLater(
      media.addMedia(missing, text('neko')),
      throwsA(isA<EntityNotFoundException>()),
    );
    expect(await store.contains(missing, ContentHash.of([])), isFalse);
  });

  test('a missing file is reported', () async {
    final asset = await media.addMedia(japanese.id, text('neko'));
    await store.file(japanese.id, asset.hash).delete();
    await expectLater(
      media.read(japanese.id, asset.hash).toList(),
      throwsA(isA<MediaFileNotFoundException>()),
    );
  });

  test('adding records the asset in the outbox', () async {
    await db.delete(db.outbox).go();
    await media.addMedia(japanese.id, text('neko'));
    final rows = await db.select(db.outbox).get();
    expect(rows.single.entityTable, 'media_assets');
  });
}
