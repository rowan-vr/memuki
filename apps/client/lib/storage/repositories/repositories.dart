import '../database.dart';
import 'collection_repository.dart';
import 'note_repository.dart';
import 'note_type_repository.dart';
import 'preset_repository.dart';
import 'review_repository.dart';
import 'study_card_repository.dart';
import 'tag_repository.dart';

/// The repositories over one database, for code outside the app's providers:
/// tests and developer tools.
class Repositories {
  Repositories(this.db)
    : collections = CollectionRepository(db),
      tags = TagRepository(db),
      noteTypes = NoteTypeRepository(db),
      notes = NoteRepository(db),
      presets = PresetRepository(db),
      cards = StudyCardRepository(db),
      reviews = ReviewRepository(db);

  final MemukiDatabase db;
  final CollectionRepository collections;
  final TagRepository tags;
  final NoteTypeRepository noteTypes;
  final NoteRepository notes;
  final PresetRepository presets;
  final StudyCardRepository cards;
  final ReviewRepository reviews;
}
