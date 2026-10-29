import '../domain/invariants.dart';
import '../domain/review.dart';
import 'study_day.dart';

/// A scheduling algorithm: computes a card's next state from a grade.
///
/// Implementations are pure. The same state, grade, and context always give
/// the same outcome, and they never read the clock, the database, or the
/// device's time zone. Everything independent of the algorithm, such as
/// burning, undo, and replay, is handled by the scheduling engine.
abstract interface class Scheduler {
  /// Identifies the algorithm, e.g. `memuki.steps-sm2`. Recorded on every
  /// review event.
  String get id;

  /// Increased whenever the outcome for the same inputs changes. Each
  /// released version stays available so history replays as it happened.
  int get version;

  /// Decodes this scheduler's settings from a preset.
  SchedulerConfig decodeConfig(Map<String, Object?> json);

  /// Applies [grade] to a card in [state], which is never burned.
  ///
  /// The outcome sets the card's state, due time, interval, ease, step, and
  /// lapses. The engine keeps the card's identity, review count, and last
  /// event.
  ReviewOutcome review(
    SchedulingState state,
    Grade grade,
    ReviewContext context,
  );
}

/// The settings of one scheduler, decoded by [Scheduler.decodeConfig].
abstract interface class SchedulerConfig {}

/// What a scheduler needs besides the card's state and the grade.
final class ReviewContext {
  ReviewContext({required this.now, required this.day, required this.config}) {
    requireUtc(now, 'now');
  }

  /// When the card was graded.
  final DateTime now;

  /// The study days in the reviewer's UTC offset at [now].
  final StudyDay day;

  final SchedulerConfig config;
}

final class ReviewOutcome {
  const ReviewOutcome(this.state, {this.lapsed = false});

  final SchedulingState state;

  /// Whether the grade was a lapse: a failed review of a graduated card.
  final bool lapsed;
}
