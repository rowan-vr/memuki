/// Drift table definitions, grouped like the domain models in `lib/domain/`.
///
/// Row classes are named `*Row` and mapped to domain models by repositories.
///
/// IDs are stored as 16-byte blobs and times as UTC milliseconds. Enums are
/// stored by name, so adding or reordering values does not change stored data.
///
/// Rows that belong to a collection carry `collection_id`, and references
/// between them are composite foreign keys on `(collection_id, id)`. A
/// reference into another collection is therefore rejected by the database on
/// every write path. `collection_id` cannot change after creation (see
/// `triggers.drift`). Self-references (deck and tag parents) are deferred to
/// commit, so a subtree can be written in any order within a transaction.
library;

export 'collection_tables.dart';
export 'media_tables.dart';
export 'note_tables.dart';
export 'note_type_tables.dart';
export 'preset_tables.dart';
export 'review_tables.dart';
export 'study_card_tables.dart';
export 'sync_tables.dart';
