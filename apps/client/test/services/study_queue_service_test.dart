import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/collection.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note_type.dart';
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

  test('learning ahead reaches into the next study day', () async {
    await repos.presets.updateSettings(
      japanese.preset.id,
      PresetVersion(
        id: PresetVersionId.generate(),
        schedulerConfig: {
          'learningSteps': [15],
        },
      ),
    );
    final cards = await addNotes(1);
    // 02:50 local; the study day ends at 03:00.
    now = DateTime.utc(2026, 10, 29, 17, 50);
    final state = await reviews.review(cards.single.id, Grade.again);
    // Due at 03:05, within 20 minutes.
    expect(state.due, DateTime.utc(2026, 10, 29, 18, 5));
    final queue = await queues.queue(japanese.deck.id);
    expect(queue.next, cards.single.id);
    expect(queue.learningCount, 1);
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
        stateBefore: StudyCardState.newCard,
        schedulerId: 'memuki.steps-sm2',
        schedulerVersion: 1,
        presetVersionId: japanese.preset.version.id,
      ),
    );
    final queue = await queues.queue(japanese.deck.id);
    expect(queue.newCount, 1);
    expect(queue.next, cards[1].id);
  });

  test('suspended cards and cards buried until later are left out', () async {
    final cards = await addNotes(3);
    await repos.cards.setSuspended([cards[0].id], true);
    await repos.cards.setBuriedUntil([
      cards[1].id,
    ], now.add(const Duration(hours: 1)));
    var queue = await queues.queue(japanese.deck.id);
    expect(queue.newCount, 1);
    expect(queue.next, cards[2].id);

    now = now.add(const Duration(hours: 1));
    queue = await queues.queue(japanese.deck.id);
    expect(queue.newCount, 2);
    expect(queue.next, cards[1].id);
  });

  test('cards skipped for the session are left out', () async {
    final cards = await addNotes(2);
    final queue = await queues.queue(japanese.deck.id, skip: {cards[0].id});
    expect(queue.newCount, 1);
    expect(queue.next, cards[1].id);
  });

  group('sibling burying', () {
    late StudyCard first;
    late StudyCard sibling;
    late Deck other;

    setUp(() async {
      final template = StudyCardTemplate(
        id: StudyCardTemplateId.generate(),
        name: 'Card 2',
      );
      await repos.noteTypes.updateNoteType(
        japanese.noteType.copyWith(
          templates: [...japanese.noteType.templates, template],
        ),
      );
      other = await japanese.addDeck('Reverse');
      final (note, card) = await japanese.addNote('猫');
      first = card;
      sibling = StudyCard(
        noteId: note.id,
        templateId: template.id,
        deckId: japanese.deck.id,
      );
      await repos.cards.createCard(sibling);
    });

    test('studying a card buries its new sibling for the day', () async {
      await reviews.review(first.id, Grade.good);
      expect((await queues.queue(japanese.deck.id)).newCount, 0);
      now = now.add(const Duration(days: 1));
      expect((await queues.queue(japanese.deck.id)).newCount, 1);
    });

    test('an undo brings the sibling back', () async {
      await reviews.review(first.id, Grade.good);
      await reviews.undo(first.id);
      expect((await queues.queue(japanese.deck.id)).newCount, 2);
    });

    test('a sibling studied in another deck counts', () async {
      await repos.cards.moveCard(first.id, other.id);
      await reviews.review(first.id, Grade.good);
      expect((await queues.queue(japanese.deck.id)).newCount, 0);
    });

    test('can be turned off in the preset', () async {
      await repos.presets.updateSettings(
        japanese.preset.id,
        PresetVersion(id: PresetVersionId.generate(), buryNewSiblings: false),
      );
      await reviews.review(first.id, Grade.good);
      expect((await queues.queue(japanese.deck.id)).next, sibling.id);
    });
  });

  test('rejects unknown decks', () async {
    await expectLater(
      queues.queue(DeckId.generate()),
      throwsA(isA<EntityNotFoundException>()),
    );
  });
}
