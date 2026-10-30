import 'package:drift/drift.dart';

import '../../domain/ids.dart';
import '../../domain/review.dart';
import '../../domain/review_history.dart';
import '../converters.dart';
import '../database.dart';
import '../sync/change_recorder.dart';
import 'repository_exceptions.dart';
import 'visibility.dart';

/// The append-only review history. Events are never changed or removed;
/// an undo is a new event.
class ReviewRepository {
  ReviewRepository(this._db) : _changes = ChangeRecorder(_db);

  final MemukiDatabase _db;
  final ChangeRecorder _changes;

  /// A card's events in the order they happened, including events of a
  /// deleted card.
  Future<List<ReviewEvent>> history(StudyCardId studyCardId) =>
      (_db.select(_db.reviewEvents)
            ..where((e) => e.studyCardId.equalsValue(studyCardId))
            ..orderBy([
              (e) => OrderingTerm(expression: e.at),
              (e) => OrderingTerm(expression: e.id),
            ]))
          .map(_event)
          .get();

  /// The events of every card in a collection, by card, each in the order
  /// they happened. Includes the events of deleted cards.
  Future<Map<StudyCardId, List<ReviewEvent>>> histories(
    CollectionId collectionId,
  ) => _histories(collectionId);

  /// The events at or after [since] of every card in a collection, by card,
  /// each in the order they happened.
  Future<Map<StudyCardId, List<ReviewEvent>>> eventsSince(
    CollectionId collectionId,
    DateTime since,
  ) => _histories(
    collectionId,
    where: _db.reviewEvents.at.isBiggerOrEqualValue(
      const UtcMillisConverter().toSql(since),
    ),
  );

  Future<Map<StudyCardId, List<ReviewEvent>>> _histories(
    CollectionId collectionId, {
    Expression<bool>? where,
  }) async {
    final query =
        _db.select(_db.reviewEvents).join([
            innerJoin(
              _db.studyCards,
              _db.studyCards.id.equalsExp(_db.reviewEvents.studyCardId),
            ),
          ])
          ..where(
            _db.studyCards.collectionId.equalsValue(collectionId) &
                (where ?? const Constant(true)),
          )
          ..orderBy([
            OrderingTerm(expression: _db.reviewEvents.studyCardId),
            OrderingTerm(expression: _db.reviewEvents.at),
            OrderingTerm(expression: _db.reviewEvents.id),
          ]);
    final histories = <StudyCardId, List<ReviewEvent>>{};
    for (final row in await query.get()) {
      final event = _event(row.readTable(_db.reviewEvents));
      (histories[event.studyCardId] ??= []).add(event);
    }
    return histories;
  }

  /// Appends an event. An undo event must undo an event of the same card:
  /// either its latest action in effect, or, as a redo, its latest undo that
  /// can be redone (see [ReviewHistory]).
  Future<void> append(ReviewEvent event) => _changes.write((hlc) async {
    final card =
        await (_db.select(_db.studyCards)..where(
              (c) =>
                  c.id.equalsValue(event.studyCardId) & _db.isVisibleCard(c.id),
            ))
            .getSingleOrNull();
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
      final history = ReviewHistory(await this.history(event.studyCardId));
      if (undoneId != history.undoable?.id &&
          undoneId != history.redoable?.id) {
        throw InvalidReviewEventException(
          'Event $undoneId of card ${event.studyCardId} is neither the latest '
          'action nor the latest undo in effect',
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
            utcOffset: event.utcOffset,
            stateBefore: event.stateBefore,
            grade: Value(event.grade),
            responseTime: Value(event.responseTime),
            dueBefore: Value(event.dueBefore),
            dueAfter: Value(event.dueAfter),
            undoneEventId: Value(event.undoneEventId),
            schedulerId: event.schedulerId,
            schedulerVersion: event.schedulerVersion,
            presetVersionId: event.presetVersionId,
            hlc: hlc,
          ),
        );
  });
}

ReviewEvent _event(ReviewEventRow row) => ReviewEvent(
  id: row.id,
  studyCardId: row.studyCardId,
  kind: row.kind,
  at: row.at,
  utcOffset: row.utcOffset,
  stateBefore: row.stateBefore,
  grade: row.grade,
  responseTime: row.responseTime,
  dueBefore: row.dueBefore,
  dueAfter: row.dueAfter,
  undoneEventId: row.undoneEventId,
  schedulerId: row.schedulerId,
  schedulerVersion: row.schedulerVersion,
  presetVersionId: row.presetVersionId,
);
