import '../scheduler.dart';

/// The settings of [StepsSm2Scheduler]. Ease values and their changes are in
/// percentage points, so ease arithmetic is exact.
final class StepsSm2Config implements SchedulerConfig {
  StepsSm2Config({
    this.learningSteps = const [
      Duration(minutes: 1),
      Duration(hours: 4),
      Duration(hours: 12),
      Duration(days: 1),
      Duration(days: 2),
    ],
    this.graduatingInterval = 3,
    this.easyInterval = 14,
    this.relearningSteps = const [
      Duration(minutes: 10),
      Duration(hours: 1),
      Duration(hours: 12),
      Duration(days: 2),
    ],
    this.minimumInterval = 2,
    this.lapseIntervalPercent = 0,
    this.maximumInterval = 36500,
    this.startingEase = 250,
    this.minimumEase = 130,
    this.againEasePenalty = 20,
    this.hardEasePenalty = 15,
    this.goodEaseRecovery = 5,
    this.easyEaseBonus = 15,
    this.hardMultiplierPercent = 120,
    this.easyBonusPercent = 130,
    this.fuzz = true,
  }) {
    if (learningSteps.isEmpty) {
      throw ArgumentError.value(learningSteps, 'learningSteps', 'is empty');
    }
    for (final step in [...learningSteps, ...relearningSteps]) {
      if (step <= Duration.zero ||
          (step >= const Duration(days: 1) &&
              step.inMicroseconds % Duration.microsecondsPerDay != 0)) {
        throw ArgumentError.value(
          step,
          'step',
          'must be positive, and whole days from one day up',
        );
      }
    }
    _requireRange(graduatingInterval, 'graduatingInterval', 1, maximumInterval);
    _requireRange(
      easyInterval,
      'easyInterval',
      graduatingInterval,
      maximumInterval,
    );
    _requireRange(minimumInterval, 'minimumInterval', 1, maximumInterval);
    _requireRange(lapseIntervalPercent, 'lapseIntervalPercent', 0, 100);
    _requireRange(minimumEase, 'minimumEase', 100, startingEase);
    for (final (value, name) in [
      (againEasePenalty, 'againEasePenalty'),
      (hardEasePenalty, 'hardEasePenalty'),
      (goodEaseRecovery, 'goodEaseRecovery'),
      (easyEaseBonus, 'easyEaseBonus'),
    ]) {
      _requireRange(value, name, 0, 100);
    }
    _requireRange(hardMultiplierPercent, 'hardMultiplierPercent', 100, 1000);
    _requireRange(easyBonusPercent, 'easyBonusPercent', 100, 1000);
  }

  /// Decodes settings from a preset. Missing keys take their defaults;
  /// steps are in minutes and intervals in days.
  factory StepsSm2Config.fromJson(Map<String, Object?> json) {
    final defaults = StepsSm2Config();
    T read<T>(String key, T fallback) => switch (json[key]) {
      null => fallback,
      final T value => value,
      final other => throw FormatException('$key must be a $T', other),
    };
    List<Duration> steps(String key, List<Duration> fallback) => [
      for (final minutes in read<List<Object?>>(key, [
        for (final step in fallback) step.inMinutes,
      ]))
        if (minutes is int)
          Duration(minutes: minutes)
        else
          throw FormatException('$key must be a list of minutes', minutes),
    ];
    return StepsSm2Config(
      learningSteps: steps('learningSteps', defaults.learningSteps),
      graduatingInterval: read(
        'graduatingInterval',
        defaults.graduatingInterval,
      ),
      easyInterval: read('easyInterval', defaults.easyInterval),
      relearningSteps: steps('relearningSteps', defaults.relearningSteps),
      minimumInterval: read('minimumInterval', defaults.minimumInterval),
      lapseIntervalPercent: read(
        'lapseIntervalPercent',
        defaults.lapseIntervalPercent,
      ),
      maximumInterval: read('maximumInterval', defaults.maximumInterval),
      startingEase: read('startingEase', defaults.startingEase),
      minimumEase: read('minimumEase', defaults.minimumEase),
      againEasePenalty: read('againEasePenalty', defaults.againEasePenalty),
      hardEasePenalty: read('hardEasePenalty', defaults.hardEasePenalty),
      goodEaseRecovery: read('goodEaseRecovery', defaults.goodEaseRecovery),
      easyEaseBonus: read('easyEaseBonus', defaults.easyEaseBonus),
      hardMultiplierPercent: read(
        'hardMultiplierPercent',
        defaults.hardMultiplierPercent,
      ),
      easyBonusPercent: read('easyBonusPercent', defaults.easyBonusPercent),
      fuzz: read('fuzz', defaults.fuzz),
    );
  }

  /// Steps for new cards. Steps under a day are exact; longer steps are whole
  /// days and fall due at the start of a study day.
  final List<Duration> learningSteps;

  /// Days until the first review after the last learning step.
  final int graduatingInterval;

  /// Days until the first review when a learning card is graded Easy.
  final int easyInterval;

  /// Steps after a lapse. When empty, a lapsed card returns to review
  /// immediately.
  final List<Duration> relearningSteps;

  /// The fewest days until the next review after relearning.
  final int minimumInterval;

  /// The share of its interval a card keeps after a lapse.
  final int lapseIntervalPercent;

  final int maximumInterval;

  /// The ease of a graduating card, in percent.
  final int startingEase;

  final int minimumEase;

  final int againEasePenalty;
  final int hardEasePenalty;

  /// How much Good raises an ease below [startingEase], up to it.
  final int goodEaseRecovery;

  final int easyEaseBonus;

  /// The factor by which Hard grows a review interval, in percent.
  final int hardMultiplierPercent;

  /// The extra factor for Easy on top of the ease, in percent.
  final int easyBonusPercent;

  /// Whether review intervals are spread slightly so cards learned together
  /// do not all fall due together.
  final bool fuzz;
}

void _requireRange(int value, String name, int min, int max) {
  if (value < min || value > max) {
    throw ArgumentError.value(value, name, 'must be from $min to $max');
  }
}
