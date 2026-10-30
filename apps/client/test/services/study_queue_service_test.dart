import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/preset.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/scheduler/scheduler_registry.dart';
import 'package:memuki/scheduler/steps_sm2/steps_sm2_scheduler.dart';
import 'package:memuki/services/review_service.dart';
import 'package:memuki/services/study_queue_service.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;
  late ReviewService reviews;
  late StudyQueueService queues;
  // 21:00 on 29 October in UTC+9.
  var now = DateTime.utc(2026, 10, 29, 12);
  const offset = Duration(hours: 9);

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
    now = DateTime.utc(2026, 10, 29, 12);
    final schedulers = SchedulerRegistry([const StepsSm2Scheduler()]);
    reviews = ReviewService(
      db: repos.db,
      collections: repos.collections,
      presets: repos.presets,
      cards: repos.cards,
      notes: repos.notes,
      tags: repos.tags,
      reviews: repos.reviews,
      schedulers: schedulers,
      now: () => (at: now, utcOffset: offset),
    );
    queues = StudyQueueService(
      db: repos.db,
      collections: repos.collections,
      presets: repos.presets,
      cards: repos.cards,
      reviews: repos.reviews,
      schedulers: schedulers,
      now: () => (at: now, utcOffset: offset),
    );
  });

  Future<void> setLimits(
    PresetId presetId, {
    int newCards = 50,
    int reviewsPerDay = 500,
    NewCardMix mix = NewCardMix.mixed,
  }) => repos.presets.updateSettings(
    presetId,
    PresetVersion(
      id: PresetVersionId.generate(),
      schedulerConfig: {'fuzz': false},
      newCardsPerDay: newCards,
      reviewsPerDay: reviewsPerDay,
      newCardMix: mix,
    ),
  );

  Future<List<StudyCard>> addNotes(int count, {DeckId? deckId}) async => [
    for (var i = 0; i < count; i++)
      (await japanese.addNote('$i', deckId: deckId)).$2,
  ];

  test('new cards come in creation order', () async {
    final cards = await addNotes(3);
    final queue = await queues.queue(japanese.deck.id);
    expect(queue.next, cards.first.id);
    expect(queue.newCount, 3);
  });

  test(
    'a card studied for the first time today uses a new-card slot',
    () async {
      await setLimits(japanese.preset.id, newCards: 2);
      final cards = await addNotes(3);
      await reviews.review(cards.first.id, Grade.good);

      final queue = await queues.queue(japanese.deck.id);
      expect(queue.newCount, 1);
      expect(queue.learningCount, 0);
      expect(queue.next, cards[1].id);
    },
  );

  test('learning reviews use no slot; review-phase reviews do', () async {
    await setLimits(japanese.preset.id, reviewsPerDay: 2);
    final cards = await addNotes(3);
    for (final card in cards) {
      await reviews.review(card.id, Grade.easy);
    }
    // Fourteen days later, all three are due.
    now = now.add(const Duration(days: 14));
    await reviews.review(cards.first.id, Grade.again);
    now = now.add(const Duration(minutes: 10));
    await reviews.review(cards.first.id, Grade.again);

    final queue = await queues.queue(japanese.deck.id);
    // The first review of the lapsed card used a slot; relearning did not.
    expect(queue.reviewCount, 1);
    expect(queue.learningCount, 1);
    // The relearning card is not due for ten minutes; a review comes first.
    expect(queue.next, cards[1].id);
  });

  test('yesterday\'s reviews do not count', () async {
    await setLimits(japanese.preset.id, newCards: 1);
    final cards = await addNotes(2);
    await reviews.review(cards.first.id, Grade.easy);
    now = now.add(const Duration(days: 1));
    expect((await queues.queue(japanese.deck.id)).newCount, 1);
  });

  test('an undo gives the slot back', () async {
    await setLimits(japanese.preset.id, newCards: 1);
    final cards = await addNotes(2);
    await reviews.review(cards.first.id, Grade.easy);
    expect((await queues.queue(japanese.deck.id)).newCount, 0);

    await reviews.undo(cards.first.id);
    final queue = await queues.queue(japanese.deck.id);
    expect(queue.newCount, 1);
    expect(queue.next, cards.first.id);
  });

  test('studying a parent deck includes its subdecks with their own '
      'limits', () async {
    final strict = Preset(
      id: PresetId.generate(),
      collectionId: japanese.id,
      name: 'Strict',
      version: PresetVersion(id: PresetVersionId.generate(), newCardsPerDay: 1),
    );
    await repos.presets.createPreset(strict);
    final n5 = await japanese.addDeck('N5', parentId: japanese.deck.id);
    await repos.collections.updateDeck(n5.copyWith(presetId: strict.id));
    await setLimits(japanese.preset.id, newCards: 3);
    final subdeckCards = await addNotes(3, deckId: n5.id);
    await addNotes(3);

    expect((await queues.queue(japanese.deck.id)).newCount, 3);
    expect((await queues.queue(n5.id)).newCount, 1);

    await reviews.review(subdeckCards.first.id, Grade.good);
    expect((await queues.queue(japanese.deck.id)).newCount, 2);
    expect((await queues.queue(n5.id)).newCount, 0);
  });

  test('uses the order settings of the studied deck\'s preset', () async {
    await setLimits(japanese.preset.id, mix: NewCardMix.newFirst);
    final cards = await addNotes(2);
    await reviews.review(cards.first.id, Grade.easy);
    now = now.add(const Duration(days: 14));
    // Mixed would show the review first.
    expect((await queues.queue(japanese.deck.id)).next, cards[1].id);
  });

  test('cards whose history cannot be replayed count as not studied', () async {
    final cards = await addNotes(2);
    await reviews.review(cards.first.id, Grade.good);
    await repos.reviews.append(
      ReviewEvent(
        id: ReviewEventId.generate(),
        studyCardId: cards.first.id,
        kind: ReviewEventKind.reschedule,
        at: now,
        utcOffset: offset,
        schedulerId: 'memuki.steps-sm2',
        schedulerVersion: 1,
        presetVersionId: japanese.preset.version.id,
      ),
    );
    final queue = await queues.queue(japanese.deck.id);
    expect(queue.newCount, 1);
    expect(queue.next, cards[1].id);
  });

  test('rejects unknown decks', () async {
    await expectLater(
      queues.queue(DeckId.generate()),
      throwsA(isA<EntityNotFoundException>()),
    );
  });
}
