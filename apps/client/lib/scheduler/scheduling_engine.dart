import '../domain/ids.dart';
import '../domain/review.dart';
import 'scheduler.dart';
import 'scheduler_registry.dart';
import 'study_day.dart';

/// The settings that apply to a review, from the card's preset and its
/// collection.
final class SchedulingSettings {
  const SchedulingSettings({
    this.schedulerId = 'memuki.steps-sm2',
    this.configVersion = 0,
    this.schedulerConfig = const {},
    this.burnThreshold,
    this.leechThreshold = 8,
    this.dayStart = StudyDay.defaultStart,
  });

  /// The scheduler that new reviews use, in its latest version.
  final String schedulerId;

  /// The version of the preset these settings come from, recorded on each
  /// review event.
  final int configVersion;

  /// The scheduler's own settings, decoded by [Scheduler.decodeConfig].
  final Map<String, Object?> schedulerConfig;

  /// Graduated cards whose next interval reaches this are burned. Null
  /// disables burning.
  final Duration? burnThreshold;

  /// The number of lapses at which a card becomes a leech, and again every
  /// half of it after. Null disables leech detection.
  final int? leechThreshold;

  /// The local time of day at which the collection's study day starts.
  final Duration dayStart;
}

/// Applies review events to scheduling state, independent of the algorithm.
///
/// Each review event is applied with the scheduler and version recorded on
/// it, in the UTC offset recorded on it, so every device computes the same
/// state from the same history. Burning and leech detection are handled here
/// rather than by the schedulers.
class SchedulingEngine {
  SchedulingEngine(this._schedulers);

  final SchedulerRegistry _schedulers;

  /// The state of a card that has never been reviewed.
  SchedulingState initial(StudyCardId studyCardId) =>
      SchedulingState(studyCardId: studyCardId, state: StudyCardState.newCard);

  /// Whether the change from [before] to [after] is a lapse that makes the
  /// card a leech: at the leech threshold, and again every half of it after,
  /// so a card stays flagged while it keeps failing.
  bool becameLeech(
    SchedulingState before,
    SchedulingState after,
    SchedulingSettings settings,
  ) {
    final threshold = settings.leechThreshold;
    if (threshold == null || after.lapses <= before.lapses) return false;
    final repeat = threshold < 2 ? 1 : (threshold + 1) ~/ 2;
    return after.lapses >= threshold &&
        (after.lapses - threshold) % repeat == 0;
  }

  /// The state of the card after [event].
  SchedulingState apply(
    SchedulingState state,
    ReviewEvent event,
    SchedulingSettings settings,
  ) {
    if (event.studyCardId != state.studyCardId) {
      throw ArgumentError.value(
        event.studyCardId,
        'event',
        'belongs to a different card than ${state.studyCardId}',
      );
    }
    final next = switch (event.kind) {
      ReviewEventKind.review => _review(
        state,
        event,
        settings,
      ).copyWith(reviewCount: state.reviewCount + 1),
      ReviewEventKind.burn => _burn(state),
      ReviewEventKind.unburn ||
      ReviewEventKind.reschedule ||
      ReviewEventKind.undo => throw UnimplementedError(
        '${event.kind.name} events are not supported yet',
      ),
    };
    return next.copyWith(lastEventId: event.id);
  }

  SchedulingState _review(
    SchedulingState state,
    ReviewEvent event,
    SchedulingSettings settings,
  ) {
    final grade = event.grade!;
    if (state.state == StudyCardState.burned) {
      // Passing a burned card keeps it burned; failing it is a lapse of a
      // review card, which the scheduler sends to relearning.
      if (grade != Grade.again) return state;
      state = state.copyWith(state: StudyCardState.review);
    }
    final scheduler = _schedulers.resolve(
      event.schedulerId,
      event.schedulerVersion,
    );
    final outcome = scheduler.review(
      state,
      grade,
      ReviewContext(
        now: event.at,
        day: StudyDay(utcOffset: event.utcOffset, start: settings.dayStart),
        config: scheduler.decodeConfig(settings.schedulerConfig),
      ),
    );
    final next = outcome.state.copyWith(studyCardId: state.studyCardId);
    final threshold = settings.burnThreshold;
    if (threshold != null &&
        next.state == StudyCardState.review &&
        next.interval >= threshold) {
      return _burn(next);
    }
    return next;
  }

  SchedulingState _burn(SchedulingState state) =>
      state.copyWith(state: StudyCardState.burned, due: null);
}
