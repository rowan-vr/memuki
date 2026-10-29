import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/storage/media/io_media_store.dart';
import 'package:memuki/storage/media/media_store.dart';

void main() {
  late Directory root;
  late IoMediaStore store;
  final japanese = CollectionId.generate();
  final korean = CollectionId.generate();
  final bytes = utf8.encode('neko');

  setUp(() async {
    root = await Directory.systemTemp.createTemp('memuki_media_test');
    addTearDown(() => root.delete(recursive: true));
    store = await IoMediaStore.open(root);
  });

  Future<List<int>> readAll(Stream<List<int>> stream) async => [
    for (final chunk in await stream.toList()) ...chunk,
  ];

  test('stores a file under its hash in its collection\'s folder', () async {
    final stored = await store.put(
      japanese,
      Stream.fromIterable([bytes.sublist(0, 2), bytes.sublist(2)]),
    );
    expect(stored.hash, ContentHash.of(bytes));
    expect(stored.sizeBytes, bytes.length);
    expect(
      store.file(japanese, stored.hash).path,
      '${root.path}/${japanese.value}/${stored.hash.value}',
    );
    expect(await readAll(store.read(japanese, stored.hash)), bytes);
    expect(await store.contains(japanese, stored.hash), isTrue);
    expect(await store.contains(korean, stored.hash), isFalse);
  });

  test('storing the same bytes again keeps one file', () async {
    final first = await store.put(japanese, Stream.value(bytes));
    final modified = store.file(japanese, first.hash).lastModifiedSync();
    final second = await store.put(japanese, Stream.value(bytes));
    expect(second, first);
    expect(store.file(japanese, first.hash).lastModifiedSync(), modified);
    expect(Directory('${root.path}/.tmp').listSync(), isEmpty);
  });

  test('each collection keeps its own copy', () async {
    final stored = await store.put(japanese, Stream.value(bytes));
    await store.put(korean, Stream.value(bytes));
    expect(await store.contains(korean, stored.hash), isTrue);
    expect(
      store.file(korean, stored.hash).path,
      isNot(store.file(japanese, stored.hash).path),
    );
  });

  test('an interrupted write leaves no file', () async {
    final failing = Stream<List<int>>.multi((c) {
      c.add(bytes);
      c.addError(const FileSystemException('source went away'));
    });
    await expectLater(
      store.put(japanese, failing),
      throwsA(isA<FileSystemException>()),
    );
    expect(Directory('${root.path}/.tmp').listSync(), isEmpty);
    expect(Directory('${root.path}/${japanese.value}').existsSync(), isFalse);
  });

  test('opening removes partial files from a crash', () async {
    final partial = File('${root.path}/.tmp/partial')..writeAsStringSync('ne');
    store = await IoMediaStore.open(root);
    expect(partial.existsSync(), isFalse);
    expect(Directory('${root.path}/.tmp').existsSync(), isTrue);
  });

  test('reading a missing file fails', () async {
    await expectLater(
      store.read(japanese, ContentHash.of(bytes)).toList(),
      throwsA(
        isA<MediaFileNotFoundException>().having(
          (e) => e.toString(),
          'message',
          contains(japanese.value),
        ),
      ),
    );
  });
}
