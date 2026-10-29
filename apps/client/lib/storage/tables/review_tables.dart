import 'package:drift/drift.dart';

import '../../domain/review.dart' show Grade, ReviewEventKind, StudyCardState;
import '../converters.dart';
import 'study_card_tables.dart';

/// The append-only review history. Events are synced but never deleted, so
/// they have an [hlc] but no tombstone flag.
@TableIndex(name: 'review_events_card', columns: {#studyCardId, #at})
@TableIndex(name: 'review_events_at', columns: {#at})
@TableIndex(name: 'review_events_hlc', columns: {#hlc})
@DataClassName('ReviewEventRow')
class ReviewEvents extends Table {
  BlobColumn get id => blob().map(reviewEventIdConverter)();
  BlobColumn get studyCardId =>
      blob().map(studyCardIdConverter).references(StudyCards, #id)();
  TextColumn get kind => textEnum<ReviewEventKind>()();
  IntColumn get at => integer().map(const UtcMillisConverter())();
  TextColumn get grade => textEnum<Grade>().nullable()();
  IntColumn get responseTime =>
      integer().map(const DurationMillisConverter()).nullable()();
  IntColumn get dueBefore =>
      integer().map(const UtcMillisConverter()).nullable()();
  IntColumn get dueAfter =>
      integer().map(const UtcMillisConverter()).nullable()();
  BlobColumn get undoneEventId => blob()
      .map(reviewEventIdConverter)
      .nullable()
      .references(ReviewEvents, #id)();
  TextColumn get schedulerId => text()();
  IntColumn get schedulerVersion => integer()();
  IntColumn get configVersion => integer()();
  TextColumn get hlc => text().map(const HlcConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

/// The materialized scheduling state of each card, rebuildable from
/// [ReviewEvents]. Not synced; each device rebuilds it from the events.
@TableIndex(name: 'scheduling_states_due', columns: {#state, #due})
@DataClassName('SchedulingStateRow')
class SchedulingStates extends Table {
  BlobColumn get studyCardId => blob()
      .map(studyCardIdConverter)
      .references(StudyCards, #id, onDelete: KeyAction.cascade)();
  TextColumn get state => textEnum<StudyCardState>()();
  IntColumn get due => integer().map(const UtcMillisConverter()).nullable()();
  IntColumn get interval => integer().map(const DurationMillisConverter())();
  RealColumn get ease => real().nullable()();
  IntColumn get step => integer()();
  IntColumn get lapses => integer()();
  IntColumn get reviewCount => integer()();
  BlobColumn get lastEventId => blob()
      .map(reviewEventIdConverter)
      .nullable()
      .references(ReviewEvents, #id)();

  @override
  Set<Column> get primaryKey => {studyCardId};
}
