import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/scheduler/scheduler_registry.dart';
import 'package:memuki/scheduler/scheduling_engine.dart';

import 'fake_scheduler.dart';

void main() {
  final engine = SchedulingEngine(
    SchedulerRegistry([FakeScheduler(1), FakeScheduler(2)]),
  );
  final cardId = StudyCardId.derive(
    NoteId.generate(),
    StudyCardTemplateId.generate(),
  );
  // 21:00 in UTC+9.
  final at = DateTime.utc(2026, 10, 29, 12);
  const settings = SchedulingSettings();

  ReviewEvent event({
    ReviewEventKind kind = ReviewEventKind.review,
    Grade? grade = Grade.good,
    int version = 1,
    Duration utcOffset = const Duration(hours: 9),
    StudyCardId? card,
  }) => ReviewEvent(
    id: ReviewEventId.generate(),
    studyCardId: card ?? cardId,
    kind: kind,
    at: at,
    utcOffset: utcOffset,
    grade: kind == ReviewEventKind.review ? grade : null,
    schedulerId: 'test.fake',
    schedulerVersion: version,
    presetVersionId: PresetVersionId.generate(),
  );

  SchedulingState review({Duration? burnThreshold}) => engine.apply(
    engine.initial(cardId),
    event(),
    SchedulingSettings(burnThreshold: burnThreshold),
  );

  test('a new card has no due time or history', () {
    final state = engine.initial(cardId);
    expect(state.state, StudyCardState.newCard);
    expect(state.due, isNull);
    expect(state.reviewCount, 0);
    expect(state.lastEventId, isNull);
  });

  test('applies each event with the scheduler version recorded on it', () {
    final first = event();
    final second = event(version: 2);
    final afterFirst = engine.apply(engine.initial(cardId), first, settings);
    final afterSecond = engine.apply(afterFirst, second, settings);
    expect(afterFirst.interval, const Duration(days: 10));
    expect(afterSecond.interval, const Duration(days: 20));
    expect(afterSecond.reviewCount, 2);
    expect(afterSecond.lastEventId, second.id);
  });

  test('computes study days in the UTC offset recorded on the event', () {
    SchedulingState after(Duration utcOffset) => engine.apply(
      engine.initial(cardId),
      event(utcOffset: utcOffset),
      settings,
    );
    // Ten study days later at 03:00 local time.
    expect(after(const Duration(hours: 9)).due, DateTime.utc(2026, 11, 7, 18));
    expect(after(const Duration(hours: -5)).due, DateTime.utc(2026, 11, 8, 8));
  });

  test('passes the preset settings to the scheduler', () {
    final state = engine.apply(
      engine.initial(cardId),
      event(),
      const SchedulingSettings(schedulerConfig: {'days': 3}),
    );
    expect(state.interval, const Duration(days: 3));
  });

  test('rejects events of unknown schedulers', () {
    expect(
      () => engine.apply(engine.initial(cardId), event(version: 9), settings),
      throwsA(isA<UnknownSchedulerException>()),
    );
  });

  test('rejects events of another card', () {
    final other = StudyCardId.derive(
      NoteId.generate(),
      StudyCardTemplateId.generate(),
    );
    expect(
      () => engine.apply(engine.initial(cardId), event(card: other), settings),
      throwsArgumentError,
    );
  });

  group('burning', () {
    test('burns a card whose interval reaches the threshold', () {
      final state = review(burnThreshold: const Duration(days: 10));
      expect(state.state, StudyCardState.burned);
      expect(state.due, isNull);
      expect(state.interval, const Duration(days: 10));
    });

    test('keeps a card below the threshold in review', () {
      final state = review(burnThreshold: const Duration(days: 11));
      expect(state.state, StudyCardState.review);
      expect(state.due, isNotNull);
    });

    test('never burns when the threshold is disabled', () {
      expect(review().state, StudyCardState.review);
    });

    test('a manual burn burns the card without reviewing it', () {
      final burn = event(kind: ReviewEventKind.burn);
      final state = engine.apply(review(), burn, settings);
      expect(state.state, StudyCardState.burned);
      expect(state.due, isNull);
      expect(state.reviewCount, 1);
      expect(state.lastEventId, burn.id);
    });

    test('passing a burned card keeps it burned', () {
      final burned = review(burnThreshold: const Duration(days: 1));
      for (final grade in [Grade.hard, Grade.good, Grade.easy]) {
        final pass = event(grade: grade);
        final state = engine.apply(burned, pass, settings);
        expect(state.state, StudyCardState.burned, reason: grade.name);
        expect(state.due, isNull);
        expect(state.interval, burned.interval);
        expect(state.reviewCount, 2);
        expect(state.lastEventId, pass.id);
      }
    });

    test('failing a burned card sends it to relearning', () {
      final burned = review(burnThreshold: const Duration(days: 1));
      final state = engine.apply(burned, event(grade: Grade.again), settings);
      expect(state.state, StudyCardState.relearning);
      expect(state.lapses, 1);
      expect(state.due, at.add(const Duration(minutes: 10)));
    });
  });

  group('unburning', () {
    test('returns a burned card to reviews, due at the start of today', () {
      final burned = review(burnThreshold: const Duration(days: 1));
      final unburn = event(kind: ReviewEventKind.unburn);
      final state = engine.apply(burned, unburn, settings);
      expect(state.state, StudyCardState.review);
      // 03:00 on 29 October in UTC+9.
      expect(state.due, DateTime.utc(2026, 10, 28, 18));
      expect(state.interval, burned.interval);
      expect(state.ease, burned.ease);
      expect(state.reviewCount, 1);
      expect(state.lastEventId, unburn.id);
    });

    test('uses the collection\'s study day start', () {
      final burned = review(burnThreshold: const Duration(days: 1));
      final state = engine.apply(
        burned,
        event(kind: ReviewEventKind.unburn),
        const SchedulingSettings(dayStart: Duration(hours: 22)),
      );
      // 22:00 on 28 October in UTC+9.
      expect(state.due, DateTime.utc(2026, 10, 28, 13));
    });

    test('leaves other cards unchanged', () {
      final reviewed = review();
      final state = engine.apply(
        reviewed,
        event(kind: ReviewEventKind.unburn),
        settings,
      );
      expect(state.copyWith(lastEventId: reviewed.lastEventId), reviewed);
    });
  });

  test('undo events cannot be applied', () {
    final reviewed = review();
    final undo = ReviewEvent(
      id: ReviewEventId.generate(),
      studyCardId: cardId,
      kind: ReviewEventKind.undo,
      at: at,
      utcOffset: Duration.zero,
      undoneEventId: reviewed.lastEventId,
      schedulerId: 'test.fake',
      schedulerVersion: 1,
      presetVersionId: PresetVersionId.generate(),
    );
    expect(() => engine.apply(reviewed, undo, settings), throwsArgumentError);
  });

  group('leeches', () {
    SchedulingState lapses(int count) =>
        engine.initial(cardId).copyWith(lapses: count);

    List<int> leechLapses(SchedulingSettings settings) => [
      for (var n = 1; n <= 20; n++)
        if (engine.becameLeech(lapses(n - 1), lapses(n), settings)) n,
    ];

    test('a card becomes a leech at the threshold and every half after', () {
      expect(leechLapses(settings), [8, 12, 16, 20]);
      expect(leechLapses(const SchedulingSettings(leechThreshold: 3)), [
        3,
        5,
        7,
        9,
        11,
        13,
        15,
        17,
        19,
      ]);
      expect(
        leechLapses(const SchedulingSettings(leechThreshold: 1)),
        List.generate(20, (i) => i + 1),
      );
    });

    test('only a new lapse makes a leech', () {
      expect(engine.becameLeech(lapses(8), lapses(8), settings), isFalse);
    });

    test('leech detection can be disabled', () {
      expect(
        leechLapses(const SchedulingSettings(leechThreshold: null)),
        isEmpty,
      );
    });
  });
}
