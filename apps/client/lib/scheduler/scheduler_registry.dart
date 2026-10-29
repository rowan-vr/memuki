import 'scheduler.dart';

/// The available schedulers, by ID and version. Old versions stay registered
/// so review events replay with the version they were recorded with.
class SchedulerRegistry {
  SchedulerRegistry(Iterable<Scheduler> schedulers) {
    for (final scheduler in schedulers) {
      final versions = _schedulers.putIfAbsent(scheduler.id, () => {});
      if (versions.containsKey(scheduler.version)) {
        throw ArgumentError(
          'Scheduler ${scheduler.id} v${scheduler.version} is registered twice',
        );
      }
      versions[scheduler.version] = scheduler;
    }
  }

  final _schedulers = <String, Map<int, Scheduler>>{};

  /// The scheduler with [id] and [version].
  Scheduler resolve(String id, int version) =>
      _schedulers[id]?[version] ??
      (throw UnknownSchedulerException('$id v$version'));

  /// The newest version of the scheduler with [id], used for new reviews.
  Scheduler latest(String id) {
    final versions = _schedulers[id];
    if (versions == null) throw UnknownSchedulerException(id);
    return versions[versions.keys.reduce((a, b) => a > b ? a : b)]!;
  }
}

/// No registered scheduler matches a review event or preset, e.g. because
/// the event was recorded by a newer version of the app.
class UnknownSchedulerException implements Exception {
  const UnknownSchedulerException(this.scheduler);

  final String scheduler;

  @override
  String toString() => 'UnknownSchedulerException: $scheduler';
}
