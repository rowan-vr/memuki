import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/scheduler/scheduler_registry.dart';

import 'fake_scheduler.dart';

void main() {
  final v1 = FakeScheduler(1);
  final v2 = FakeScheduler(2);
  final registry = SchedulerRegistry([v2, v1]);

  test('resolves a scheduler by ID and version', () {
    expect(registry.resolve('test.fake', 1), same(v1));
    expect(registry.resolve('test.fake', 2), same(v2));
  });

  test('the latest version is the highest', () {
    expect(registry.latest('test.fake'), same(v2));
  });

  test('rejects unknown schedulers and versions', () {
    expect(
      () => registry.resolve('test.fake', 3),
      throwsA(isA<UnknownSchedulerException>()),
    );
    expect(
      () => registry.resolve('other', 1),
      throwsA(isA<UnknownSchedulerException>()),
    );
    expect(
      () => registry.latest('other'),
      throwsA(isA<UnknownSchedulerException>()),
    );
  });

  test('rejects a version registered twice', () {
    expect(
      () => SchedulerRegistry([FakeScheduler(1), FakeScheduler(1)]),
      throwsArgumentError,
    );
  });
}
