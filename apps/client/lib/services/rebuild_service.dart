import 'package:logging/logging.dart';

import '../domain/ids.dart';
import '../domain/preset.dart';
import '../domain/review.dart';
import '../domain/review_history.dart';
import '../domain/study_card.dart';
import '../scheduler/scheduler_registry.dart';
import '../scheduler/scheduling_engine.dart';
import '../storage/database.dart';
import '../storage/repositories/collection_repository.dart';
import '../storage/repositories/preset_repository.dart';
import '../storage/repositories/repository_exceptions.dart';
import '../storage/repositories/review_repository.dart';
import '../storage/repositories/study_card_repository.dart';

final _log = Logger('memuki.scheduler');

/// What a rebuild found.
final class RebuildReport {
  RebuildReport._();

  /// The cards whose history was replayed.
  int cards = 0;

  /// Cards whose rebuilt state differs from the stored one. A rebuild that
  /// writes has replaced their state.
  final List<StudyCardId> changed = [];

  /// Events that could not be replayed as recorded, by card. They were
  /// replayed with the card's current preset and its scheduler instead.
  final Map<StudyCardId, List<String>> warnings = {};

  /// Cards whose history could not be replayed at all. Their stored state is
  /// kept.
  final Map<StudyCardId, Object> failures = {};
}

/// Rebuilds scheduling state by replaying review history.
///
/// Each action in effect is applied with the scheduler version, preset
/// version, and UTC offset recorded on it, and the collection's current study
/// day start; undone events and the undos themselves are skipped. Replay has
/// no side effects such as leech tags.
///
/// An event whose scheduler or preset version is unknown, e.g. from old test
/// data, is replayed with the current preset of the card's deck and the
/// latest version of its scheduler, and reported as a warning.
class RebuildService {
  RebuildService({
    required this._db,
    required this._collections,
    required this._presets,
    required this._cards,
    required this._reviews,
    required this._schedulers,
  }) : _engine = SchedulingEngine(_schedulers);

  final MemukiDatabase _db;
  final CollectionRepository _collections;
  final PresetRepository _presets;
  final StudyCardRepository _cards;
  final ReviewRepository _reviews;
  final SchedulerRegistry _schedulers;
  final SchedulingEngine _engine;

  /// Rebuilds one card. With [write] false, only reports what would change.
  Future<RebuildReport> rebuildCard(
    StudyCardId id, {
    bool write = true,
  }) => _db.transaction(() async {
    final card = await _cards.card(id);
    if (card == null) throw EntityNotFoundException('Card $id does not exist');
    final preset = await _presets.effectivePreset(card.deckId);
    final collection = (await _collections.collection(preset.collectionId))!;
    final report = RebuildReport._();
    await _rebuild(
      card,
      await _reviews.history(id),
      _Context(collection.dayStart),
      report,
      write,
    );
    return report;
  });

  /// The state of [card] after [history], without saving it. Throws if the
  /// history cannot be replayed.
  Future<SchedulingState> replay(
    StudyCard card,
    List<ReviewEvent> history,
  ) async {
    final preset = await _presets.effectivePreset(card.deckId);
    final collection = (await _collections.collection(preset.collectionId))!;
    return _replay(
      card,
      history,
      _Context(collection.dayStart),
      RebuildReport._(),
    );
  }

  /// Rebuilds every card in a collection. With [write] false, only reports
  /// what would change.
  Future<RebuildReport> rebuildCollection(
    CollectionId id, {
    bool write = true,
  }) => _db.transaction(() async {
    final collection = await _collections.collection(id);
    if (collection == null) {
      throw EntityNotFoundException('Collection $id does not exist');
    }
    final histories = await _reviews.histories(id);
    final context = _Context(collection.dayStart);
    final report = RebuildReport._();
    for (final root in await _collections.decks(id)) {
      if (root.parentId != null) continue;
      for (final card in await _cards.cardsInDeck(
        root.id,
        includeSubdecks: true,
      )) {
        await _rebuild(card, histories[card.id] ?? [], context, report, write);
      }
    }
    return report;
  });

  Future<void> _rebuild(
    StudyCard card,
    List<ReviewEvent> history,
    _Context context,
    RebuildReport report,
    bool write,
  ) async {
    report.cards++;
    final SchedulingState state;
    try {
      state = await _replay(card, history, context, report);
    } on UnknownSchedulerException catch (error) {
      report.failures[card.id] = error;
      return;
    } on UnimplementedError catch (error) {
      report.failures[card.id] = error;
      return;
    }
    if (state == await _cards.schedulingState(card.id)) return;
    report.changed.add(card.id);
    if (write) await _cards.saveSchedulingState(state);
  }

  Future<SchedulingState> _replay(
    StudyCard card,
    List<ReviewEvent> history,
    _Context context,
    RebuildReport report,
  ) async {
    var state = _engine.initial(card.id);
    for (var event in ReviewHistory(history).actions) {
      final recorded = await context.version(event.presetVersionId, _presets);
      var version = recorded;
      final problems = [
        if (recorded == null) 'preset version ${event.presetVersionId}',
        if (event.kind == ReviewEventKind.review && !_isKnown(event))
          'scheduler ${event.schedulerId} v${event.schedulerVersion}',
      ];
      if (problems.isNotEmpty) {
        // Replays with the current preset and its scheduler.
        version = await context.currentVersion(card.deckId, _presets);
        final scheduler = _schedulers.latest(version.schedulerId);
        event = event.copyWith(
          schedulerId: scheduler.id,
          schedulerVersion: scheduler.version,
        );
        final warning =
            'Event ${event.id}: unknown ${problems.join(' and ')}; replayed '
            'with ${scheduler.id} v${scheduler.version} and the current preset';
        _log.warning('Card ${card.id}: $warning');
        (report.warnings[card.id] ??= []).add(warning);
      }
      state = _engine.apply(
        state,
        event,
        SchedulingSettings.fromPreset(version!, dayStart: context.dayStart),
      );
    }
    return state;
  }

  bool _isKnown(ReviewEvent event) {
    try {
      _schedulers.resolve(event.schedulerId, event.schedulerVersion);
      return true;
    } on UnknownSchedulerException {
      return false;
    }
  }
}

/// Lookups shared by the cards of one rebuild.
class _Context {
  _Context(this.dayStart);

  final Duration dayStart;
  final _versions = <PresetVersionId, PresetVersion?>{};
  final _current = <DeckId, PresetVersion>{};

  Future<PresetVersion?> version(
    PresetVersionId id,
    PresetRepository presets,
  ) async => _versions.containsKey(id)
      ? _versions[id]
      : _versions[id] = await presets.version(id);

  Future<PresetVersion> currentVersion(
    DeckId deckId,
    PresetRepository presets,
  ) async =>
      _current[deckId] ??= (await presets.effectivePreset(deckId)).version;
}
