import '../domain/ids.dart';
import '../domain/preset.dart';
import '../domain/review.dart';

/// A card's review history as a schema upgrade reads it, to be replayed by a
/// [ReplayHistory].
final class HistoryToReplay {
  const HistoryToReplay({
    required this.events,
    required this.versions,
    required this.fallback,
    required this.dayStart,
  });

  /// The card's events in the order they happened. Their
  /// [ReviewEvent.stateBefore] is a placeholder and is not read.
  final List<ReviewEvent> events;

  /// The preset versions the events were recorded with, by ID.
  final Map<PresetVersionId, PresetVersion> versions;

  /// The settings for events whose preset version is unknown: the current
  /// version of the collection's default preset.
  final PresetVersion fallback;

  /// The collection's study day start.
  final Duration dayStart;
}

/// Computes the state the card was in before each event of [history] by
/// replaying it, by event ID.
///
/// Upgrades that derive data from review history need the scheduler, which
/// storage does not depend on, so the services layer supplies this when
/// opening the database.
typedef ReplayHistory = Map<ReviewEventId, StudyCardState> Function(
  HistoryToReplay history,
);
