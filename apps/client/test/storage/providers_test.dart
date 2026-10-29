import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/storage/media/io_media_store.dart';
import 'package:memuki/storage/providers.dart';

import '../helpers/test_database.dart';

void main() {
  test('repositories use the overridden database', () async {
    final db = openTestDatabase();
    final root = await Directory.systemTemp.createTemp('memuki_media_test');
    addTearDown(() => root.delete(recursive: true));
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        mediaStoreProvider.overrideWithValue(await IoMediaStore.open(root)),
      ],
    );
    addTearDown(container.dispose);

    final seeded = await Repositories(db).seedCollection();

    expect(await container.read(collectionRepositoryProvider).collections(), [
      seeded.collection,
    ]);
    expect(
      await container.read(tagRepositoryProvider).tags(seeded.id),
      isEmpty,
    );
    expect(
      await container.read(noteTypeRepositoryProvider).noteTypes(seeded.id),
      [seeded.noteType],
    );
    expect(
      await container.read(noteRepositoryProvider).notes(seeded.id),
      isEmpty,
    );
    expect(
      await container
          .read(studyCardRepositoryProvider)
          .cardsInDeck(seeded.deck.id),
      isEmpty,
    );
    container.read(reviewRepositoryProvider);
    expect(
      await container.read(mediaRepositoryProvider).mediaOf(seeded.id),
      isEmpty,
    );
  });

  test('the database and media store must be overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(() => container.read(databaseProvider), throwsA(anything));
    expect(() => container.read(mediaStoreProvider), throwsA(anything));
  });
}
