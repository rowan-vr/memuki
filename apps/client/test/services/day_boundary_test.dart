import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/preset.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/scheduler/scheduler_registry.dart';
import 'package:memuki/scheduler/steps_sm2/steps_sm2_scheduler.dart';
import 'package:memuki/scheduler/study_queue.dart';
import 'package:memuki/services/review_service.dart';
import 'package:memuki/services/study_queue_service.dart';

import '../helpers/test_database.dart';

/// Study days, sub-day and day steps, and changes of UTC offset across
/// reviewing and the study queue. The collection's study day starts at 03:00
/// local time.
void main() {
  late Repositories repos;
  late SeededCollection japanese;
  late ReviewService reviews;
  late StudyQueueService queues;
  late DateTime now;
  late Duration offset;

  /// Sets the clock to [hour]:[minute] local time on [day] October 2026 in
  /// the current offset.
  void at(int day, int hour, [int minute = 0]) =>
      now = DateTime.utc(2026, 10, day, hour, minute).subtract(offset);

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
    offset = const Duration(hours: 9);
    at(29, 21);
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

  Future<void> configure({
    int newCards = 50,
    int reviewsPerDay = 500,
    List<int>? learningSteps,
  }) => repos.presets.updateSettings(
    japanese.preset.id,
    PresetVersion(
      id: PresetVersionId.generate(),
      schedulerConfig: {'fuzz': false, 'learningSteps': ?learningSteps},
      newCardsPerDay: newCards,
      reviewsPerDay: reviewsPerDay,
    ),
  );

  Future<List<StudyCard>> addNotes(int count) async => [
    for (var i = 0; i < count; i++) (await japanese.addNote('$i')).$2,
  ];

  Future<StudyQueue> queue() => queues.queue(japanese.deck.id);

  group('rollover', () {
    test('limits reset at the start of the study day', () async {
      await configure(newCards: 1);
      final cards = await addNotes(2);
      at(30, 2);
      await reviews.review(cards.first.id, Grade.easy);

      at(30, 2, 59);
      expect((await queue()).newCount, 0);
      at(30, 3);
      expect((await queue()).newCount, 1);
    });

    test('reviews due at the day start appear at the rollover', () async {
      final card = (await addNotes(1)).single;
      final state = await reviews.review(card.id, Grade.easy);
      // 03:00 on 12 November, fourteen study days later.
      expect(state.due, DateTime.utc(2026, 11, 11, 18));

      at(31 + 12, 2, 59);
      expect((await queue()).reviewCount, 0);
      at(31 + 12, 3);
      expect((await queue()).next, card.id);
    });
  });

  group('sub-day steps', () {
    test(
      'a step that ends after the day start belongs to the new day',
      () async {
        await configure(newCards: 1);
        final cards = await addNotes(2);
        at(29, 23, 30);
        final state = await reviews.review(cards.first.id, Grade.good);
        // Exactly four hours later, at 03:30.
        expect(state.due, DateTime.utc(2026, 10, 29, 18, 30));

        at(30, 3, 30);
        final status = await queue();
        expect(status.next, cards.first.id);
        // The review at 23:30 counted towards the previous day.
        expect(status.newCount, 1);
      },
    );

    test('a relearning step that ends after the day start keeps its lapse '
        'in the previous day', () async {
      await configure(reviewsPerDay: 1);
      final cards = await addNotes(2);
      for (final card in cards) {
        await reviews.review(card.id, Grade.easy);
      }
      // Both are due at 03:00 on 12 November; one lapses at 02:55 the next
      // night, still in the study day of the 12th.
      at(31 + 13, 2, 55);
      final lapsed = await reviews.review(cards.first.id, Grade.again);
      expect(lapsed.due, now.add(const Duration(minutes: 10)));

      at(31 + 13, 3, 5);
      final status = await queue();
      expect(status.learningCount, 1);
      expect(status.reviewCount, 1);
    });
  });

  test('day steps fall due at the day start in the offset of the '
      'review', () async {
    await configure(learningSteps: [10, 1440]);
    final card = (await addNotes(1)).single;
    final state = await reviews.review(card.id, Grade.good);
    // 03:00 on 30 October in UTC+9.
    expect(state.due, DateTime.utc(2026, 10, 29, 18));

    offset = const Duration(hours: -5);
    at(29, 21);
    final elsewhere = await reviews.review(
      (await addNotes(1)).single.id,
      Grade.good,
    );
    // 03:00 on 30 October in UTC-5.
    expect(elsewhere.due, DateTime.utc(2026, 10, 30, 8));
  });

  group('changes of UTC offset', () {
    test('after clocks go forward, a learning card on a day step is shown '
        'an hour after the day starts', () async {
      await configure(learningSteps: [10, 1440]);
      final card = (await addNotes(1)).single;
      // 21:00 on 27 March in UTC+1; summer time starts that night.
      offset = const Duration(hours: 1);
      now = DateTime.utc(2027, 3, 27, 20);
      final state = await reviews.review(card.id, Grade.good);
      // 03:00 in UTC+1, which is 04:00 summer time.
      expect(state.due, DateTime.utc(2027, 3, 28, 2));

      offset = const Duration(hours: 2);
      now = DateTime.utc(2027, 3, 28, 1);
      final atDayStart = await queue();
      expect(atDayStart.next, isNull);
      expect(atDayStart.nextDue, state.due);

      now = state.due!;
      expect((await queue()).next, card.id);
    });

    test('today is counted in the device\'s current offset', () async {
      await configure(newCards: 1);
      final cards = await addNotes(2);
      // 10:00 on 29 October in UTC+9.
      at(29, 10);
      await reviews.review(cards.first.id, Grade.easy);
      expect((await queue()).newCount, 0);

      // After a flight to UTC+1, 18:00 the same day. Its study day started
      // at 03:00 UTC+1, after the review, which no longer counts.
      offset = const Duration(hours: 1);
      at(29, 18);
      expect((await queue()).newCount, 1);
    });
  });

  test('a new day start applies to the queue at once', () async {
    await configure(newCards: 1);
    final cards = await addNotes(2);
    at(30, 2, 30);
    await reviews.review(cards.first.id, Grade.easy);

    // 04:00 is in a new study day when it starts at 03:00 ...
    at(30, 4);
    expect((await queue()).newCount, 1);
    // ... but still in the day of the review when it starts at 05:00.
    await repos.collections.updateCollection(
      japanese.collection.copyWith(dayStart: const Duration(hours: 5)),
    );
    expect((await queue()).newCount, 0);
  });
}
