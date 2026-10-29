import 'package:freezed_annotation/freezed_annotation.dart';

import 'ids.dart';
import 'invariants.dart';

part 'review.freezed.dart';

/// The answer given when reviewing a card.
enum Grade { again, hard, good, easy }

enum ReviewEventKind {
  /// The card was reviewed and graded.
  review,

  /// The card was burned manually.
  burn,

  /// A burned card was returned to reviews manually.
  unburn,

  /// The card was rescheduled explicitly, e.g. after a configuration change.
  reschedule,

  /// A previous event was undone. The undone event is kept.
  undo,
}

/// An immutable entry in a card's review history. Scheduling state is rebuilt
/// by replaying a card's events through the scheduler recorded on each event.
///
/// Events only hold what cannot be recomputed: the grade, timing, and due
/// times, plus the scheduler and configuration needed for deterministic
/// replay.
@freezed
abstract class ReviewEvent with _$ReviewEvent {
  ReviewEvent._() {
    requireUtc(at, 'at');
    requireUtc(dueBefore, 'dueBefore');
    requireUtc(dueAfter, 'dueAfter');
    requireUtcOffset(utcOffset, 'utcOffset');
    if ((kind == ReviewEventKind.review) != (grade != null)) {
      throw ArgumentError.value(grade, 'grade', 'is required for reviews only');
    }
    if ((kind == ReviewEventKind.undo) != (undoneEventId != null)) {
      throw ArgumentError.value(
        undoneEventId,
        'undoneEventId',
        'is required for undo events only',
      );
    }
    if (responseTime != null && responseTime!.isNegative) {
      throw ArgumentError.value(
        responseTime,
        'responseTime',
        'must not be negative',
      );
    }
  }

  factory ReviewEvent({
    required ReviewEventId id,
    required StudyCardId studyCardId,
    required ReviewEventKind kind,
    required DateTime at,

    /// The reviewing device's offset from UTC at [at]. Study-day boundaries
    /// are computed in this offset, so every device rebuilds the same state.
    required Duration utcOffset,
    Grade? grade,
    Duration? responseTime,
    DateTime? dueBefore,
    DateTime? dueAfter,
    ReviewEventId? undoneEventId,
    required String schedulerId,
    required int schedulerVersion,
    required int configVersion,
  }) = _ReviewEvent;
}

enum StudyCardState { newCard, learning, review, relearning, burned }

/// A card's current scheduling state: a cache that can be rebuilt by
/// replaying the card's review events. Its exact contents are refined with the
/// scheduler in Phase 2.
@freezed
abstract class SchedulingState with _$SchedulingState {
  SchedulingState._() {
    requireUtc(due, 'due');
    if (step < 0 || lapses < 0 || reviewCount < 0) {
      throw ArgumentError('step, lapses, and reviewCount must not be negative');
    }
  }

  factory SchedulingState({
    required StudyCardId studyCardId,
    required StudyCardState state,

    /// Null for new and burned cards.
    DateTime? due,
    @Default(Duration.zero) Duration interval,

    /// SM-2-style ease multiplier; null until the card graduates.
    double? ease,

    /// Index into the learning or relearning steps.
    @Default(0) int step,
    @Default(0) int lapses,
    @Default(0) int reviewCount,

    /// The last event this state was computed from, or null for a new card.
    ReviewEventId? lastEventId,
  }) = _SchedulingState;
}
