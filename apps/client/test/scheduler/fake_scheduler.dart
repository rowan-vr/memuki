import 'package:memuki/domain/review.dart';
import 'package:memuki/scheduler/scheduler.dart';

/// A scheduler whose outcomes reveal its version and inputs.
///
/// Again sends a card to relearning, due in ten minutes. Any other grade
/// makes it a review card whose interval is `days` from the config times the
/// version, due at the start of that study day.
class FakeScheduler implements Scheduler {
  FakeScheduler(this.version);

  @override
  String get id => 'test.fake';

  @override
  final int version;

  @override
  FakeConfig decodeConfig(Map<String, Object?> json) =>
      FakeConfig(json['days'] as int? ?? 10);

  @override
  ReviewOutcome review(
    SchedulingState state,
    Grade grade,
    ReviewContext context,
  ) {
    if (grade == Grade.again) {
      return ReviewOutcome(
        state.copyWith(
          state: StudyCardState.relearning,
          due: context.now.add(const Duration(minutes: 10)),
          lapses: state.lapses + 1,
        ),
        lapsed: state.state == StudyCardState.review,
      );
    }
    final days = (context.config as FakeConfig).days * version;
    return ReviewOutcome(
      state.copyWith(
        state: StudyCardState.review,
        due: context.day.startAfter(context.now, days),
        interval: Duration(days: days),
      ),
    );
  }
}

class FakeConfig implements SchedulerConfig {
  const FakeConfig(this.days);

  final int days;
}
