import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/collection.dart';
import '../domain/ids.dart';
import '../scheduler/schedulers.dart';
import '../storage/providers.dart';
import 'rebuild_service.dart';
import 'review_service.dart';
import 'study_queue_service.dart';

final schedulerRegistryProvider = Provider((ref) => allSchedulers);

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

/// The collection the app works on: the first by name, or else a new one
/// named by the argument, made the first time one is needed. A way to pick
/// another collection replaces this later.
final activeCollectionProvider = FutureProvider.family<CollectionId, String>((
  ref,
  name,
) async {
  final collections = ref.watch(collectionRepositoryProvider);
  final existing = await collections.collections();
  if (existing.isNotEmpty) return existing.first.id;
  final collection = Collection(id: CollectionId.generate(), name: name);
  await collections.createCollection(collection);
  return collection.id;
});
