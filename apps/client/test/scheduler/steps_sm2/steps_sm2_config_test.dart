import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/scheduler/steps_sm2/steps_sm2_config.dart';

void main() {
  test('an empty preset decodes to the defaults', () {
    final config = StepsSm2Config.fromJson({});
    expect(config.learningSteps, [
      const Duration(minutes: 1),
      const Duration(hours: 4),
      const Duration(hours: 12),
      const Duration(days: 1),
      const Duration(days: 2),
    ]);
    expect(config.relearningSteps.first, const Duration(minutes: 10));
    expect(config.graduatingInterval, 3);
    expect(config.easyInterval, 14);
    expect(config.minimumInterval, 2);
    expect(config.lapseIntervalPercent, 0);
    expect(config.startingEase, 250);
    expect(config.goodEaseRecovery, 5);
    expect(config.fuzz, isTrue);
  });

  test('decodes steps in minutes and other settings', () {
    final config = StepsSm2Config.fromJson({
      'learningSteps': [10, 1440],
      'relearningSteps': <Object?>[],
      'graduatingInterval': 4,
      'lapseIntervalPercent': 20,
      'fuzz': false,
    });
    expect(config.learningSteps, [
      const Duration(minutes: 10),
      const Duration(days: 1),
    ]);
    expect(config.relearningSteps, isEmpty);
    expect(config.graduatingInterval, 4);
    expect(config.lapseIntervalPercent, 20);
    expect(config.fuzz, isFalse);
  });

  test('rejects values of the wrong type', () {
    expect(
      () => StepsSm2Config.fromJson({'graduatingInterval': '3'}),
      throwsFormatException,
    );
    expect(
      () => StepsSm2Config.fromJson({
        'learningSteps': ['1m'],
      }),
      throwsFormatException,
    );
  });

  test('rejects invalid steps', () {
    expect(() => StepsSm2Config(learningSteps: []), throwsArgumentError);
    expect(
      () => StepsSm2Config(learningSteps: [Duration.zero]),
      throwsArgumentError,
    );
    expect(
      () => StepsSm2Config(relearningSteps: [const Duration(hours: 36)]),
      throwsArgumentError,
    );
  });

  test('rejects settings out of range', () {
    expect(() => StepsSm2Config(graduatingInterval: 0), throwsArgumentError);
    expect(
      () => StepsSm2Config(graduatingInterval: 5, easyInterval: 4),
      throwsArgumentError,
    );
    expect(
      () => StepsSm2Config(lapseIntervalPercent: 101),
      throwsArgumentError,
    );
    expect(() => StepsSm2Config(minimumEase: 300), throwsArgumentError);
    expect(
      () => StepsSm2Config(hardMultiplierPercent: 90),
      throwsArgumentError,
    );
    expect(() => StepsSm2Config(goodEaseRecovery: -1), throwsArgumentError);
  });
}
