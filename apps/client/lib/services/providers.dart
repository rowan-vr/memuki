import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../scheduler/scheduler_registry.dart';
import '../scheduler/steps_sm2/steps_sm2_scheduler.dart';
import '../storage/providers.dart';
import 'rebuild_service.dart';
import 'review_service.dart';
import 'study_queue_service.dart';

/// Every scheduler version the app can replay.
final schedulerRegistryProvider = Provider(
  (ref) => SchedulerRegistry([const StepsSm2Scheduler()]),
);

final reviewServiceProvider = Provider(
  (ref) => ReviewService(
    db: ref.watch(databaseProvider),
    collections: ref.watch(collectionRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    cards: ref.watch(studyCardRepositoryProvider),
    notes: ref.watch(noteRepositoryProvider),
    tags: ref.watch(tagRepositoryProvider),
    reviews: ref.watch(reviewRepositoryProvider),
    schedulers: ref.watch(schedulerRegistryProvider),
  ),
);

final rebuildServiceProvider = Provider(
  (ref) => RebuildService(
    db: ref.watch(databaseProvider),
    collections: ref.watch(collectionRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    cards: ref.watch(studyCardRepositoryProvider),
    reviews: ref.watch(reviewRepositoryProvider),
    schedulers: ref.watch(schedulerRegistryProvider),
  ),
);

final studyQueueServiceProvider = Provider(
  (ref) => StudyQueueService(
    db: ref.watch(databaseProvider),
    collections: ref.watch(collectionRepositoryProvider),
    presets: ref.watch(presetRepositoryProvider),
    cards: ref.watch(studyCardRepositoryProvider),
    reviews: ref.watch(reviewRepositoryProvider),
    schedulers: ref.watch(schedulerRegistryProvider),
  ),
);
