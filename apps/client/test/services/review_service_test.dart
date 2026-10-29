import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/scheduler/scheduler_registry.dart';
import 'package:memuki/scheduler/scheduling_engine.dart';
import 'package:memuki/scheduler/steps_sm2/steps_sm2_scheduler.dart';
import 'package:memuki/services/review_service.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;
  late ReviewService service;
  // 21:00 on 29 October in UTC+9.
  var now = DateTime.utc(2026, 10, 29, 12);
  const offset = Duration(hours: 9);
  const settings = SchedulingSettings(
    configVersion: 3,
    schedulerConfig: {'fuzz': false},
  );

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
    now = DateTime.utc(2026, 10, 29, 12);
    service = ReviewService(
      db: repos.db,
      cards: repos.cards,
      notes: repos.notes,
      tags: repos.tags,
      reviews: repos.reviews,
      schedulers: SchedulerRegistry([const StepsSm2Scheduler()]),
      now: () => (at: now, utcOffset: offset),
    );
  });

  test('records a complete event and the new state', () async {
    final (_, card) = await japanese.addNote('猫');
    final state = await service.review(
      card.id,
      Grade.good,
      settings: settings,
      responseTime: const Duration(seconds: 4),
    );

    expect(state.state, StudyCardState.learning);
    expect(state.due, now.add(const Duration(hours: 4)));
    expect(await repos.cards.schedulingState(card.id), state);

    final event = (await repos.reviews.history(card.id)).single;
    expect(event.id, state.lastEventId);
    expect(event.kind, ReviewEventKind.review);
    expect(event.grade, Grade.good);
    expect(event.at, now);
    expect(event.utcOffset, offset);
    expect(event.responseTime, const Duration(seconds: 4));
    expect(event.dueBefore, isNull);
    expect(event.dueAfter, state.due);
    expect(event.schedulerId, 'memuki.steps-sm2');
    expect(event.schedulerVersion, 1);
    expect(event.configVersion, 3);
  });

  test('later reviews continue from the saved state', () async {
    final (_, card) = await japanese.addNote('猫');
    final first = await service.review(card.id, Grade.good, settings: settings);
    now = first.due!;
    final second = await service.review(
      card.id,
      Grade.good,
      settings: settings,
    );

    expect(second.step, 2);
    expect(second.reviewCount, 2);
    final history = await repos.reviews.history(card.id);
    expect(history.last.dueBefore, first.due);
    expect(history.last.dueAfter, second.due);
  });

  test('study days follow the device offset', () async {
    final (_, card) = await japanese.addNote('猫');
    final state = await service.review(card.id, Grade.easy, settings: settings);
    // 14 days later at 03:00 in UTC+9.
    expect(state.due, DateTime.utc(2026, 11, 11, 18));
  });

  test('rejects unknown cards and schedulers without writing', () async {
    final (_, card) = await japanese.addNote('猫');
    final before = await repos.cards.schedulingState(card.id);
    final missing = StudyCardId.derive(
      NoteId.generate(),
      StudyCardTemplateId.generate(),
    );
    await expectLater(
      service.review(missing, Grade.good, settings: settings),
      throwsA(isA<EntityNotFoundException>()),
    );
    await expectLater(
      service.review(
        card.id,
        Grade.good,
        settings: const SchedulingSettings(schedulerId: 'other'),
      ),
      throwsA(isA<UnknownSchedulerException>()),
    );
    expect(await repos.reviews.history(card.id), isEmpty);
    expect(await repos.cards.schedulingState(card.id), before);
  });

  group('leeches', () {
    /// A card in review that has lapsed [lapses] times.
    Future<(Note, StudyCard)> lapsedCard(String front, int lapses) async {
      final (note, card) = await japanese.addNote(front);
      await repos.cards.saveSchedulingState(
        SchedulingState(
          studyCardId: card.id,
          state: StudyCardState.review,
          due: now,
          interval: const Duration(days: 10),
          ease: 2.5,
          lapses: lapses,
        ),
      );
      return (note, card);
    }

    Future<List<String>> tagNames(Note note) async {
      final tags = await repos.tags.tags(japanese.id);
      final ids = await repos.notes.tagIds(note.id);
      return [
        for (final tag in tags)
          if (ids.contains(tag.id)) tag.name,
      ];
    }

    test('the lapse that reaches the threshold tags the note', () async {
      final (note, card) = await lapsedCard('猫', 7);
      final state = await service.review(
        card.id,
        Grade.again,
        settings: settings,
      );
      expect(state.lapses, 8);
      expect(await tagNames(note), ['leech']);
      final tag = (await repos.tags.tags(japanese.id)).single;
      expect(tag.parentId, isNull);
    });

    test('other lapses and passes do not tag the note', () async {
      final (lapsing, lapsingCard) = await lapsedCard('猫', 8);
      final (passing, passingCard) = await lapsedCard('犬', 7);
      await service.review(lapsingCard.id, Grade.again, settings: settings);
      await service.review(passingCard.id, Grade.good, settings: settings);
      expect(await tagNames(lapsing), isEmpty);
      expect(await tagNames(passing), isEmpty);
    });

    test('a card is tagged again every half threshold', () async {
      final (note, card) = await lapsedCard('猫', 11);
      await service.review(card.id, Grade.again, settings: settings);
      expect(await tagNames(note), ['leech']);
    });

    test('leeches share one tag, reusing an existing one', () async {
      final existing = await japanese.addTag('Leech');
      final (first, firstCard) = await lapsedCard('猫', 7);
      final (second, secondCard) = await lapsedCard('犬', 7);
      await service.review(firstCard.id, Grade.again, settings: settings);
      await service.review(secondCard.id, Grade.again, settings: settings);
      expect(await repos.notes.tagIds(first.id), {existing.id});
      expect(await repos.notes.tagIds(second.id), {existing.id});
      expect(await repos.tags.tags(japanese.id), [existing]);
    });

    test('a nested tag named leech is not reused', () async {
      final parent = await japanese.addTag('JLPT');
      await japanese.addTag('leech', parentId: parent.id);
      final (note, card) = await lapsedCard('猫', 7);
      await service.review(card.id, Grade.again, settings: settings);
      final tag = (await repos.tags.tags(japanese.id))
          .singleWhere((t) => t.parentId == null && t.name == 'leech');
      expect(await repos.notes.tagIds(note.id), {tag.id});
    });

    test('nothing is tagged when leech detection is off', () async {
      final (note, card) = await lapsedCard('猫', 7);
      await service.review(
        card.id,
        Grade.again,
        settings: const SchedulingSettings(leechThreshold: null),
      );
      expect(await tagNames(note), isEmpty);
    });
  });
}
