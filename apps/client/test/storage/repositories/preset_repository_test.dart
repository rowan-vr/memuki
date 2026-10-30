import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/collection.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/preset.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
  });

  Preset newPreset(String name, {CollectionId? collectionId}) => Preset(
    id: PresetId.generate(),
    collectionId: collectionId ?? japanese.id,
    name: name,
    version: PresetVersion(id: PresetVersionId.generate()),
  );

  Future<Preset> addPreset(String name) async {
    final preset = newPreset(name);
    await repos.presets.createPreset(preset);
    return preset;
  }

  group('collections', () {
    test('a new collection gets a default preset with the defaults', () {
      final preset = japanese.preset;
      expect(preset.name, 'Default');
      expect(preset.collectionId, japanese.id);
      expect(preset.version, PresetVersion(id: preset.version.id));
      expect(preset.version.burnThreshold, const Duration(days: 365));
      expect(preset.version.leechThreshold, 8);
      expect(preset.version.newCardsPerDay, 50);
      expect(preset.version.reviewsPerDay, 500);
    });

    test('a collection can be created with its own default preset', () async {
      final collection = Collection(id: CollectionId.generate(), name: 'Kanji');
      final preset = newPreset('Kanji', collectionId: collection.id);
      await repos.collections.createCollection(
        collection,
        defaultPreset: preset,
      );
      expect(await repos.presets.defaultPreset(collection.id), preset);
    });

    test('a default preset of another collection is rejected', () async {
      final collection = Collection(id: CollectionId.generate(), name: 'Kanji');
      await expectLater(
        repos.collections.createCollection(
          collection,
          defaultPreset: newPreset('Other'),
        ),
        throwsA(isA<CrossCollectionException>()),
      );
      expect(await repos.collections.collection(collection.id), isNull);
    });

    test('the study day start is stored and changed', () async {
      final collection = Collection(
        id: CollectionId.generate(),
        name: 'Kanji',
        dayStart: const Duration(hours: 5),
      );
      await repos.collections.createCollection(collection);
      expect(await repos.collections.collection(collection.id), collection);

      final changed = collection.copyWith(dayStart: Duration.zero);
      await repos.collections.updateCollection(changed);
      expect(await repos.collections.collection(collection.id), changed);
    });
  });

  group('presets', () {
    test('are listed by name', () async {
      final slow = await addPreset('Slow');
      final kanji = await addPreset('Kanji');
      expect(await repos.presets.presets(japanese.id), [
        japanese.preset,
        kanji,
        slow,
      ]);
    });

    test('a preset of a missing collection is rejected', () async {
      await expectLater(
        repos.presets.createPreset(
          newPreset('Lost', collectionId: CollectionId.generate()),
        ),
        throwsA(isA<EntityNotFoundException>()),
      );
    });

    test('can be renamed', () async {
      final preset = await addPreset('Slow');
      await repos.presets.renamePreset(preset.id, 'Slower');
      expect((await repos.presets.preset(preset.id))!.name, 'Slower');
      await expectLater(
        repos.presets.renamePreset(preset.id, ' '),
        throwsArgumentError,
      );
      await expectLater(
        repos.presets.renamePreset(PresetId.generate(), 'Lost'),
        throwsA(isA<EntityNotFoundException>()),
      );
    });

    test('editing settings adds a version and keeps the old one', () async {
      final preset = await addPreset('Slow');
      final edited = PresetVersion(
        id: PresetVersionId.generate(),
        schedulerConfig: {
          'learningSteps': [10, 60],
        },
        burnThreshold: null,
        newCardsPerDay: 10,
        newCardMix: NewCardMix.reviewsFirst,
        newCardOrder: NewCardOrder.random,
        buryNewSiblings: false,
        buryReviewSiblings: false,
        buryLearningSiblings: LearningSiblingBury.day,
      );
      await repos.presets.updateSettings(preset.id, edited);

      expect((await repos.presets.preset(preset.id))!.version, edited);
      expect(await repos.presets.version(preset.version.id), preset.version);
      expect(await repos.presets.version(edited.id), edited);
    });

    test('deleted presets are hidden but their versions remain', () async {
      final preset = await addPreset('Slow');
      await repos.presets.deletePreset(preset.id);
      expect(await repos.presets.preset(preset.id), isNull);
      expect(await repos.presets.presets(japanese.id), [japanese.preset]);
      expect(await repos.presets.version(preset.version.id), preset.version);
      await expectLater(
        repos.presets.updateSettings(
          preset.id,
          PresetVersion(id: PresetVersionId.generate()),
        ),
        throwsA(isA<EntityNotFoundException>()),
      );
    });

    test('the default preset cannot be deleted', () async {
      await expectLater(
        repos.presets.deletePreset(japanese.preset.id),
        throwsA(isA<ProtectedEntityException>()),
      );
      expect(await repos.presets.preset(japanese.preset.id), japanese.preset);
    });
  });

  group('decks', () {
    test('use the nearest preset above them, else the default', () async {
      final slow = await addPreset('Slow');
      final fast = await addPreset('Fast');
      final vocab = japanese.deck;
      final n5 = await japanese.addDeck('N5', parentId: vocab.id);
      final verbs = await japanese.addDeck('Verbs', parentId: n5.id);

      expect(await repos.presets.effectivePreset(verbs.id), japanese.preset);

      await repos.collections.updateDeck(vocab.copyWith(presetId: slow.id));
      expect(await repos.presets.effectivePreset(verbs.id), slow);
      expect(await repos.presets.effectivePreset(vocab.id), slow);

      await repos.collections.updateDeck(n5.copyWith(presetId: fast.id));
      expect(await repos.presets.effectivePreset(verbs.id), fast);
      expect(await repos.presets.effectivePreset(vocab.id), slow);

      await repos.collections.updateDeck(n5.copyWith(presetId: null));
      expect(await repos.presets.effectivePreset(verbs.id), slow);
    });

    test('fall back past a deleted preset', () async {
      final slow = await addPreset('Slow');
      final fast = await addPreset('Fast');
      await repos.collections.updateDeck(
        japanese.deck.copyWith(presetId: slow.id),
      );
      final n5 = await japanese.addDeck('N5', parentId: japanese.deck.id);
      await repos.collections.updateDeck(n5.copyWith(presetId: fast.id));

      await repos.presets.deletePreset(fast.id);
      expect(await repos.presets.effectivePreset(n5.id), slow);
      await repos.presets.deletePreset(slow.id);
      expect(await repos.presets.effectivePreset(n5.id), japanese.preset);
    });

    test('store their own preset', () async {
      final slow = await addPreset('Slow');
      final deck = Deck(
        id: DeckId.generate(),
        collectionId: japanese.id,
        name: 'Kanji',
        presetId: slow.id,
      );
      await repos.collections.createDeck(deck);
      expect(await repos.collections.deck(deck.id), deck);
    });

    test('reject presets that are missing or in another collection', () async {
      final other = await repos.seedCollection(name: 'Kanji');
      final deck = japanese.deck;
      await expectLater(
        repos.collections.updateDeck(
          deck.copyWith(presetId: PresetId.generate()),
        ),
        throwsA(isA<EntityNotFoundException>()),
      );
      await expectLater(
        repos.collections.updateDeck(deck.copyWith(presetId: other.preset.id)),
        throwsA(isA<CrossCollectionException>()),
      );
      await expectLater(
        repos.collections.createDeck(
          Deck(
            id: DeckId.generate(),
            collectionId: japanese.id,
            name: 'Kanji',
            presetId: other.preset.id,
          ),
        ),
        throwsA(isA<CrossCollectionException>()),
      );
    });

    test('the preset of a missing deck is an error', () async {
      await expectLater(
        repos.presets.effectivePreset(DeckId.generate()),
        throwsA(isA<EntityNotFoundException>()),
      );
    });
  });
}
