import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../../domain/review.dart';
import '../database.dart';
import 'repository_exceptions.dart';

/// The append-only review history. Events are never changed or removed;
/// an undo is a new event.
class ReviewRepository {
  ReviewRepository(this._db);

  final MemukiDatabase _db;

  /// A card's events in the order they happened.
  Future<List<ReviewEvent>> history(StudyCardId studyCardId) =>
      (_db.select(_db.reviewEvents)
            ..where((e) => e.studyCardId.equalsValue(studyCardId))
            ..orderBy([
              (e) => OrderingTerm(expression: e.at),
              (e) => OrderingTerm(expression: e.id),
            ]))
          .map(_event)
          .get();

  /// Appends an event. An undo event must undo an event of the same card.
  Future<void> append(ReviewEvent event) => _db.transaction(() async {
    final card = await (_db.select(
      _db.studyCards,
    )..where((c) => c.id.equalsValue(event.studyCardId))).getSingleOrNull();
    if (card == null) {
      throw EntityNotFoundException('Card ${event.studyCardId} does not exist');
    }
    if (event.undoneEventId case final undoneId?) {
      final undone = await (_db.select(
        _db.reviewEvents,
      )..where((e) => e.id.equalsValue(undoneId))).getSingleOrNull();
      if (undone == null || undone.studyCardId != event.studyCardId) {
        throw EntityNotFoundException(
          'Card ${event.studyCardId} has no event $undoneId to undo',
        );
      }
    }
    await _db
        .into(_db.reviewEvents)
        .insert(
          ReviewEventsCompanion.insert(
            id: event.id,
            studyCardId: event.studyCardId,
            kind: event.kind,
            at: event.at,
            grade: Value(event.grade),
            responseTime: Value(event.responseTime),
            dueBefore: Value(event.dueBefore),
            dueAfter: Value(event.dueAfter),
            undoneEventId: Value(event.undoneEventId),
            schedulerId: event.schedulerId,
            schedulerVersion: event.schedulerVersion,
            configVersion: event.configVersion,
          ),
        );
  });
}

ReviewEvent _event(ReviewEventRow row) => ReviewEvent(
  id: row.id,
  studyCardId: row.studyCardId,
  kind: row.kind,
  at: row.at,
  grade: row.grade,
  responseTime: row.responseTime,
  dueBefore: row.dueBefore,
  dueAfter: row.dueAfter,
  undoneEventId: row.undoneEventId,
  schedulerId: row.schedulerId,
  schedulerVersion: row.schedulerVersion,
  configVersion: row.configVersion,
);
