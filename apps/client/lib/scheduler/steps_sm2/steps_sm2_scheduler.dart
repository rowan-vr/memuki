import 'dart:convert';
import 'dart:math' as math;

import '../../domain/review.dart';
import '../scheduler.dart';
import 'steps_sm2_config.dart';

/// The default scheduler: learning and relearning steps, then SM-2-style
/// review intervals that grow by the card's ease.
///
/// Grades on a step: Again returns to the first step, Hard repeats the
/// current step, Good moves to the next step and graduates after the last,
/// and Easy graduates immediately. A new card is on the first step.
class StepsSm2Scheduler implements Scheduler {
  const StepsSm2Scheduler();

  @override
  String get id => 'memuki.steps-sm2';

  @override
  int get version => 1;

  @override
  StepsSm2Config decodeConfig(Map<String, Object?> json) =>
      StepsSm2Config.fromJson(json);

  @override
  ReviewOutcome review(
    SchedulingState state,
    Grade grade,
    ReviewContext context,
  ) {
    final config = context.config as StepsSm2Config;
    return switch (state.state) {
      StudyCardState.newCard || StudyCardState.learning => ReviewOutcome(
        _learn(state, grade, context, config),
      ),
      StudyCardState.relearning => ReviewOutcome(
        _relearn(state, grade, context, config),
      ),
      StudyCardState.review => _review(state, grade, context, config),
      StudyCardState.burned => throw ArgumentError.value(
        state.state,
        'state',
        'is handled by the engine',
      ),
    };
  }

  SchedulingState _learn(
    SchedulingState state,
    Grade grade,
    ReviewContext context,
    StepsSm2Config config,
  ) {
    final steps = config.learningSteps;
    final step = switch (grade) {
      Grade.again => 0,
      Grade.hard => state.step,
      Grade.good => state.step + 1,
      Grade.easy => steps.length,
    };
    if (step < steps.length) {
      return state.copyWith(
        state: StudyCardState.learning,
        step: step,
        due: _afterStep(steps[step], context),
      );
    }
    final days = grade == Grade.easy
        ? config.easyInterval
        : config.graduatingInterval;
    return _toReview(
      state,
      days,
      context,
    ).copyWith(ease: config.startingEase / 100);
  }

  SchedulingState _relearn(
    SchedulingState state,
    Grade grade,
    ReviewContext context,
    StepsSm2Config config,
  ) {
    final steps = config.relearningSteps;
    final step = switch (grade) {
      Grade.again => 0,
      Grade.hard => state.step,
      Grade.good => state.step + 1,
      Grade.easy => steps.length,
    };
    if (step < steps.length) {
      return state.copyWith(step: step, due: _afterStep(steps[step], context));
    }
    return _toReview(
      state,
      math.max(config.minimumInterval, state.interval.inDays),
      context,
    );
  }

  ReviewOutcome _review(
    SchedulingState state,
    Grade grade,
    ReviewContext context,
    StepsSm2Config config,
  ) {
    // A card burned manually before graduating has no ease yet.
    final ease = ((state.ease ?? config.startingEase / 100) * 100).round();
    final interval = state.interval.inDays;
    if (grade == Grade.again) {
      final lapsed = state.copyWith(
        lapses: state.lapses + 1,
        ease:
            math.max(config.minimumEase, ease - config.againEasePenalty) / 100,
        // Kept until the card returns to review after relearning.
        interval: Duration(
          days: (interval * config.lapseIntervalPercent / 100).round(),
        ),
      );
      final relearning = lapsed.copyWith(
        state: StudyCardState.relearning,
        step: 0,
      );
      final next = config.relearningSteps.isEmpty
          ? _relearn(relearning, Grade.easy, context, config)
          : relearning.copyWith(
              due: _afterStep(config.relearningSteps.first, context),
            );
      return ReviewOutcome(next, lapsed: true);
    }

    // Reviews before the due time are treated as on time.
    final late = state.due == null
        ? 0
        : math.max(
            0,
            context.day
                .startOf(context.now)
                .difference(context.day.startOf(state.due!))
                .inDays,
          );
    final hard = math.max(
      interval + 1,
      (interval * config.hardMultiplierPercent / 100).round(),
    );
    final good = math.max(
      hard + 1,
      ((interval + late / 2) * ease / 100).round(),
    );
    final easy = math.max(
      good + 1,
      ((interval + late) * ease / 100 * config.easyBonusPercent / 100).round(),
    );
    final (days, nextEase) = switch (grade) {
      Grade.hard => (
        hard,
        math.max(config.minimumEase, ease - config.hardEasePenalty),
      ),
      Grade.good => (
        good,
        ease < config.startingEase
            ? math.min(config.startingEase, ease + config.goodEaseRecovery)
            : ease,
      ),
      Grade.easy => (easy, ease + config.easyEaseBonus),
      Grade.again => throw StateError('Again is handled above'),
    };
    final fuzzed = math.min(
      config.maximumInterval,
      math.max(
        // Fuzz never shrinks an interval below the floor for its grade.
        switch (grade) {
          Grade.hard => interval + 1,
          Grade.good => hard + 1,
          _ => good + 1,
        },
        config.fuzz ? _fuzz(days, state) : days,
      ),
    );
    return ReviewOutcome(
      _toReview(state, fuzzed, context).copyWith(ease: nextEase / 100),
    );
  }

  SchedulingState _toReview(
    SchedulingState state,
    int days,
    ReviewContext context,
  ) => state.copyWith(
    state: StudyCardState.review,
    step: 0,
    interval: Duration(days: days),
    due: context.day.startAfter(context.now, days),
  );

  /// Steps under a day are exact; longer steps fall due at the start of a
  /// study day.
  DateTime _afterStep(Duration step, ReviewContext context) =>
      step < const Duration(days: 1)
      ? context.now.add(step)
      : context.day.startAfter(context.now, step.inDays);
}

/// Spreads [days] within a range that widens with the interval, so cards
/// learned together do not all fall due together. Intervals under three days
/// are not fuzzed. The choice is seeded by the card and its review count, so
/// replay reproduces it.
int _fuzz(int days, SchedulingState state) {
  if (days < 3) return days;
  var delta = 1.0;
  for (final (start, end, factor) in const [
    (2.5, 7.0, 0.15),
    (7.0, 20.0, 0.1),
    (20.0, double.infinity, 0.05),
  ]) {
    delta += factor * math.max(0, math.min(days.toDouble(), end) - start);
  }
  final low = (days - delta).round();
  final high = (days + delta).round();
  return low +
      (_unitHash('${state.studyCardId}:${state.reviewCount}') *
              (high - low + 1))
          .floor();
}

/// A number in [0, 1) derived from [seed]. Uses only arithmetic that is exact
/// in both native and web numbers, so every platform agrees.
double _unitHash(String seed) {
  const modulus = 2147483647;
  var hash = 0;
  for (final byte in utf8.encode(seed)) {
    hash = (hash * 31 + byte) % modulus;
  }
  for (var i = 0; i < 3; i++) {
    hash = (hash * 48271) % modulus;
  }
  return hash / modulus;
}
