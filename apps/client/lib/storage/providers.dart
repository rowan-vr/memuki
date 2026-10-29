import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';
import 'repositories/collection_repository.dart';
import 'repositories/note_repository.dart';
import 'repositories/note_type_repository.dart';
import 'repositories/review_repository.dart';
import 'repositories/study_card_repository.dart';
import 'repositories/tag_repository.dart';

/// The open database. `main` overrides it with the database it opened at
/// startup; tests override it with an in-memory database.
final databaseProvider = Provider<MemukiDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final collectionRepositoryProvider = Provider(
  (ref) => CollectionRepository(ref.watch(databaseProvider)),
);

final tagRepositoryProvider = Provider(
  (ref) => TagRepository(ref.watch(databaseProvider)),
);

final noteTypeRepositoryProvider = Provider(
  (ref) => NoteTypeRepository(ref.watch(databaseProvider)),
);

final noteRepositoryProvider = Provider(
  (ref) => NoteRepository(ref.watch(databaseProvider)),
);

final studyCardRepositoryProvider = Provider(
  (ref) => StudyCardRepository(ref.watch(databaseProvider)),
);

final reviewRepositoryProvider = Provider(
  (ref) => ReviewRepository(ref.watch(databaseProvider)),
);
