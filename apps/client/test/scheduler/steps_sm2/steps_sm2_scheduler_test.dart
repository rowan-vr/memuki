import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/scheduler/scheduler.dart';
import 'package:memuki/scheduler/scheduler_registry.dart';
import 'package:memuki/scheduler/scheduling_engine.dart';
import 'package:memuki/scheduler/steps_sm2/steps_sm2_config.dart';
import 'package:memuki/scheduler/steps_sm2/steps_sm2_scheduler.dart';
import 'package:memuki/scheduler/study_day.dart';

void main() {
  const scheduler = StepsSm2Scheduler();
  final cardId = StudyCardId.derive(
    NoteId.generate(),
    StudyCardTemplateId.generate(),
  );
  // 21:00 on 29 October in UTC+9.
  final now = DateTime.utc(2026, 10, 29, 12);
  final day = StudyDay(utcOffset: const Duration(hours: 9));
  final exact = StepsSm2Config(fuzz: false);

  /// The start of the study day [days] after today: 03:00 local time.
  DateTime dayStart(int days) => day.startAfter(now, days);

  ReviewOutcome grade(
    SchedulingState state,
    Grade grade, {
    StepsSm2Config? config,
    DateTime? at,
  }) => scheduler.review(
    state,
    grade,
    ReviewContext(now: at ?? now, day: day, config: config ?? exact),
  );

  SchedulingState card(
    StudyCardState state, {
    int step = 0,
    int interval = 0,
    int? ease,
    DateTime? due,
    int lapses = 0,
  }) => SchedulingState(
    studyCardId: cardId,
    state: state,
    step: step,
    interval: Duration(days: interval),
    ease: ease == null ? null : ease / 100,
    due: due,
    lapses: lapses,
  );

  SchedulingState learning(int step) =>
      card(StudyCardState.learning, step: step);
  SchedulingState relearning(int step, {int interval = 0}) => card(
    StudyCardState.relearning,
    step: step,
    interval: interval,
    ease: 230,
  );
  SchedulingState reviewCard({
    int interval = 10,
    int ease = 250,
    DateTime? due,
  }) => card(
    StudyCardState.review,
    interval: interval,
    ease: ease,
    due: due ?? now,
  );

  void expectStep(
    ReviewOutcome outcome,
    StudyCardState state,
    int step,
    DateTime due,
  ) {
    expect(outcome.state.state, state);
    expect(outcome.state.step, step);
    expect(outcome.state.due, due);
    expect(outcome.lapsed, isFalse);
  }

  void expectReview(ReviewOutcome outcome, int interval, int ease) {
    expect(outcome.state.state, StudyCardState.review);
    expect(outcome.state.interval, Duration(days: interval));
    expect(outcome.state.due, dayStart(interval));
    expect(outcome.state.ease, ease / 100);
    expect(outcome.state.step, 0);
  }

  group('a new card', () {
    final newCard = card(StudyCardState.newCard);

    test('Again goes to the first step', () {
      expectStep(
        grade(newCard, Grade.again),
        StudyCardState.learning,
        0,
        now.add(const Duration(minutes: 1)),
      );
    });

    test('Hard repeats the first step', () {
      expectStep(
        grade(newCard, Grade.hard),
        StudyCardState.learning,
        0,
        now.add(const Duration(minutes: 1)),
      );
    });

    test('Good goes to the second step', () {
      expectStep(
        grade(newCard, Grade.good),
        StudyCardState.learning,
        1,
        now.add(const Duration(hours: 4)),
      );
    });

    test('Easy graduates with the easy interval', () {
      expectReview(grade(newCard, Grade.easy), 14, 250);
    });
  });

  group('a learning card', () {
    test('Again returns to the first step', () {
      expectStep(
        grade(learning(3), Grade.again),
        StudyCardState.learning,
        0,
        now.add(const Duration(minutes: 1)),
      );
    });

    test('Hard repeats a sub-day step exactly', () {
      expectStep(
        grade(learning(1), Grade.hard),
        StudyCardState.learning,
        1,
        now.add(const Duration(hours: 4)),
      );
    });

    test('Hard repeats a day step at the start of a study day', () {
      expectStep(
        grade(learning(4), Grade.hard),
        StudyCardState.learning,
        4,
        dayStart(2),
      );
    });

    test('Good moves to the next step', () {
      expectStep(
        grade(learning(1), Grade.good),
        StudyCardState.learning,
        2,
        now.add(const Duration(hours: 12)),
      );
      expectStep(
        grade(learning(2), Grade.good),
        StudyCardState.learning,
        3,
        dayStart(1),
      );
    });

    test('Good on the last step graduates with the graduating interval', () {
      expectReview(grade(learning(4), Grade.good), 3, 250);
    });

    test('Easy graduates with the easy interval', () {
      expectReview(grade(learning(2), Grade.easy), 14, 250);
    });

    test('five Goods take a new card through every step to review', () {
      var state = card(StudyCardState.newCard);
      var at = now;
      final dues = <DateTime>[];
      for (var i = 0; i < 5; i++) {
        state = grade(state, Grade.good, at: at).state;
        at = state.due!;
        dues.add(at);
      }
      expect(state.state, StudyCardState.review);
      expect(state.interval, const Duration(days: 3));
      expect(dues.take(2), [
        now.add(const Duration(hours: 4)),
        now.add(const Duration(hours: 16)),
      ]);
    });
  });

  group('a review card', () {
    test('Again lapses into relearning and lowers ease', () {
      final outcome = grade(reviewCard(interval: 100), Grade.again);
      expect(outcome.lapsed, isTrue);
      expect(outcome.state.state, StudyCardState.relearning);
      expect(outcome.state.step, 0);
      expect(outcome.state.due, now.add(const Duration(minutes: 10)));
      expect(outcome.state.lapses, 1);
      expect(outcome.state.ease, 2.3);
      expect(outcome.state.interval, Duration.zero);
    });

    test('Again keeps the configured share of the interval', () {
      final outcome = grade(
        reviewCard(interval: 100),
        Grade.again,
        config: StepsSm2Config(fuzz: false, lapseIntervalPercent: 50),
      );
      expect(outcome.state.interval, const Duration(days: 50));
    });

    test('Again without relearning steps returns to review at once', () {
      final outcome = grade(
        reviewCard(interval: 100),
        Grade.again,
        config: StepsSm2Config(
          fuzz: false,
          relearningSteps: [],
          lapseIntervalPercent: 10,
        ),
      );
      expect(outcome.lapsed, isTrue);
      expect(outcome.state.lapses, 1);
      expectReview(outcome, 10, 230);
    });

    test('on time: Hard, Good, and Easy grow the interval', () {
      expectReview(grade(reviewCard(), Grade.hard), 12, 235);
      expectReview(grade(reviewCard(), Grade.good), 25, 250);
      // 10 × 2.5 × 1.3 = 32.5, rounded up.
      expectReview(grade(reviewCard(), Grade.easy), 33, 265);
    });

    test('late: Good counts half the delay and Easy all of it', () {
      final late = reviewCard(due: dayStart(-4));
      expectReview(grade(late, Grade.hard), 12, 235);
      expectReview(grade(late, Grade.good), 30, 250);
      expectReview(grade(late, Grade.easy), 46, 265);
    });

    test('early reviews are treated as on time', () {
      final early = reviewCard(due: dayStart(5));
      expectReview(grade(early, Grade.good), 25, 250);
    });

    test('Good recovers ease up to the starting ease', () {
      expect(grade(reviewCard(ease: 200), Grade.good).state.ease, 2.05);
      expect(grade(reviewCard(ease: 248), Grade.good).state.ease, 2.5);
      expect(grade(reviewCard(ease: 265), Grade.good).state.ease, 2.65);
    });

    test('ease never drops below the minimum', () {
      expect(grade(reviewCard(ease: 140), Grade.hard).state.ease, 1.3);
      expect(grade(reviewCard(ease: 140), Grade.again).state.ease, 1.3);
    });

    test('each passing grade gives a longer interval than the one below', () {
      final short = reviewCard(interval: 1, ease: 130);
      expectReview(grade(short, Grade.hard), 2, 130);
      expectReview(grade(short, Grade.good), 3, 135);
      expectReview(grade(short, Grade.easy), 4, 145);
    });

    test('intervals stop at the maximum', () {
      final long = reviewCard(interval: 30000);
      expect(
        grade(long, Grade.good).state.interval,
        const Duration(days: 36500),
      );
    });
  });

  group('a relearning card', () {
    test('Again returns to the first step', () {
      expectStep(
        grade(relearning(2), Grade.again),
        StudyCardState.relearning,
        0,
        now.add(const Duration(minutes: 10)),
      );
    });

    test('Hard repeats the current step', () {
      expectStep(
        grade(relearning(1), Grade.hard),
        StudyCardState.relearning,
        1,
        now.add(const Duration(hours: 1)),
      );
    });

    test('Good moves to the next step', () {
      expectStep(
        grade(relearning(2), Grade.good),
        StudyCardState.relearning,
        3,
        dayStart(2),
      );
    });

    test('Good on the last step returns to review with at least the '
        'minimum interval', () {
      expectReview(grade(relearning(3), Grade.good), 2, 230);
      expectReview(grade(relearning(3, interval: 20), Grade.good), 20, 230);
    });

    test('Easy returns to review at once', () {
      expectReview(grade(relearning(0), Grade.easy), 2, 230);
    });
  });

  group('fuzz', () {
    final fuzzy = StepsSm2Config();

    SchedulingState goodFor(StudyCardId id, {int reviewCount = 0}) => scheduler
        .review(
          SchedulingState(
            studyCardId: id,
            state: StudyCardState.review,
            interval: const Duration(days: 100),
            ease: 2.5,
            due: now,
            reviewCount: reviewCount,
          ),
          Grade.good,
          ReviewContext(now: now, day: day, config: fuzzy),
        )
        .state;

    test('is the same every time for the same card and review', () {
      expect(goodFor(cardId), goodFor(cardId));
    });

    test('spreads intervals around the unfuzzed one', () {
      final days = {
        for (var i = 0; i < 200; i++)
          goodFor(
            StudyCardId.derive(
              NoteId.generate(),
              StudyCardTemplateId.generate(),
            ),
          ).interval.inDays,
      };
      // 250 days ± 14.
      expect(days.every((d) => d >= 236 && d <= 264), isTrue, reason: '$days');
      expect(days.length, greaterThan(10));
    });

    test('changes with the review count', () {
      final intervals = {
        for (var i = 0; i < 20; i++) goodFor(cardId, reviewCount: i).interval,
      };
      expect(intervals.length, greaterThan(1));
    });

    test('leaves short intervals alone', () {
      final short = scheduler.review(
        reviewCard(interval: 1, ease: 130),
        Grade.hard,
        ReviewContext(now: now, day: day, config: fuzzy),
      );
      expect(short.state.interval, const Duration(days: 2));
    });
  });

  group('through the engine', () {
    final engine = SchedulingEngine(SchedulerRegistry([scheduler]));

    ReviewEvent event(ReviewEventKind kind, [Grade? grade]) => ReviewEvent(
      id: ReviewEventId.generate(),
      studyCardId: cardId,
      kind: kind,
      at: now,
      utcOffset: const Duration(hours: 9),
      grade: grade,
      schedulerId: scheduler.id,
      schedulerVersion: scheduler.version,
      configVersion: 1,
    );

    test('decodes the preset and schedules a new card', () {
      final state = engine.apply(
        engine.initial(cardId),
        event(ReviewEventKind.review, Grade.good),
        const SchedulingSettings(
          schedulerConfig: {
            'learningSteps': [10, 60],
          },
        ),
      );
      expect(state.state, StudyCardState.learning);
      expect(state.due, now.add(const Duration(hours: 1)));
    });

    test('failing a card burned before it graduated relearns it', () {
      final burned = engine.apply(
        engine.initial(cardId),
        event(ReviewEventKind.burn),
        const SchedulingSettings(),
      );
      final state = engine.apply(
        burned,
        event(ReviewEventKind.review, Grade.again),
        const SchedulingSettings(),
      );
      expect(state.state, StudyCardState.relearning);
      expect(state.lapses, 1);
      expect(state.ease, 2.3);
    });
  });
}
