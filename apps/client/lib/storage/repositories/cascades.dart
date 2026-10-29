import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../database.dart';

// Deletions that span tables. They run inside the caller's transaction.

/// SQLite limits the number of bound variables per statement.
const _chunkSize = 500;

/// Deletes the cards matching [filter] with their scheduling state and review
/// history.
Future<void> deleteCardsWhere(
  MemukiDatabase db,
  Expression<bool> Function($StudyCardsTable c) filter,
) async {
  JoinedSelectStatement<$StudyCardsTable, StudyCardRow> matching() =>
      db.selectOnly(db.studyCards)
        ..addColumns([db.studyCards.id])
        ..where(filter(db.studyCards));

  // Scheduling states reference review events, so they go first.
  await (db.delete(
    db.schedulingStates,
  )..where((s) => s.studyCardId.isInQuery(matching()))).go();
  await (db.delete(
    db.reviewEvents,
  )..where((e) => e.studyCardId.isInQuery(matching()))).go();
  await (db.delete(db.studyCards)..where(filter)).go();
}

/// The distinct notes of the cards matching [filter].
Future<List<NoteId>> notesOfCardsWhere(
  MemukiDatabase db,
  Expression<bool> Function($StudyCardsTable c) filter,
) async {
  final noteId = db.studyCards.noteId;
  final query = db.selectOnly(db.studyCards, distinct: true)
    ..addColumns([noteId])
    ..where(filter(db.studyCards));
  return [for (final row in await query.get()) row.readWithConverter(noteId)!];
}

/// Deletes those of [noteIds] that have no cards left.
Future<void> deleteNotesWithoutCards(
  MemukiDatabase db,
  List<NoteId> noteIds,
) async {
  for (var i = 0; i < noteIds.length; i += _chunkSize) {
    final chunk = noteIds.sublist(i, (i + _chunkSize).clamp(0, noteIds.length));
    await (db.delete(db.notes)..where(
          (n) =>
              n.id.isInValues(chunk) &
              notExistsQuery(
                db.select(db.studyCards)
                  ..where((c) => c.noteId.equalsExp(n.id)),
              ),
        ))
        .go();
  }
}
