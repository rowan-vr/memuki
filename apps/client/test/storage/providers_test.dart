import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/storage/providers.dart';

import '../helpers/test_database.dart';

void main() {
  test('repositories use the overridden database', () async {
    final db = openTestDatabase();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
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
  });

  test('the database must be overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(() => container.read(databaseProvider), throwsA(anything));
  });
}
