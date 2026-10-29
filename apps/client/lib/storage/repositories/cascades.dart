import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../database.dart';
import '../sync/hlc.dart';

// Deletions that span tables. They run inside the caller's change and
// tombstone rows with its timestamp.

/// SQLite limits the number of bound variables per statement.
const _chunkSize = 500;

/// Tombstones the live cards matching [filter]. Their review history stays,
/// since events are never deleted, and so does their scheduling state, which
/// is a local cache of that history.
Future<void> tombstoneCardsWhere(
  MemukiDatabase db,
  Hlc hlc,
  Expression<bool> Function($StudyCardsTable c) filter,
) =>
    (db.update(
      db.studyCards,
    )..where((c) => filter(c) & c.deleted.equals(false))).write(
      StudyCardsCompanion(deleted: const Value(true), hlc: Value(hlc)),
    );

/// The distinct notes of the live cards matching [filter].
Future<List<NoteId>> notesOfCardsWhere(
  MemukiDatabase db,
  Expression<bool> Function($StudyCardsTable c) filter,
) async {
  final noteId = db.studyCards.noteId;
  final query = db.selectOnly(db.studyCards, distinct: true)
    ..addColumns([noteId])
    ..where(filter(db.studyCards) & db.studyCards.deleted.equals(false));
  return [for (final row in await query.get()) row.readWithConverter(noteId)!];
}

/// Tombstones those of [noteIds] that have no live cards left.
Future<void> tombstoneNotesWithoutCards(
  MemukiDatabase db,
  Hlc hlc,
  List<NoteId> noteIds,
) async {
  for (var i = 0; i < noteIds.length; i += _chunkSize) {
    final chunk = noteIds.sublist(i, (i + _chunkSize).clamp(0, noteIds.length));
    await (db.update(db.notes)..where(
          (n) =>
              n.id.isInValues(chunk) &
              n.deleted.equals(false) &
              notExistsQuery(
                db.select(db.studyCards)..where(
                  (c) => c.noteId.equalsExp(n.id) & c.deleted.equals(false),
                ),
              ),
        ))
        .write(NotesCompanion(deleted: const Value(true), hlc: Value(hlc)));
  }
}
