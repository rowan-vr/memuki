import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/dev/collection_generator.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/preset.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/scheduler/scheduler_registry.dart';
import 'package:memuki/scheduler/steps_sm2/steps_sm2_scheduler.dart';
import 'package:memuki/services/rebuild_service.dart';
import 'package:memuki/services/review_service.dart';
import 'package:memuki/storage/history_replay.dart';
import 'package:memuki/storage/media/io_media_store.dart';
import 'package:memuki/storage/repositories/media_repository.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;
  late ReviewService reviews;
  late RebuildService rebuild;
  // 21:00 on 29 October in UTC+9.
  var now = DateTime.utc(2026, 10, 29, 12);
  final schedulers = SchedulerRegistry([const StepsSm2Scheduler()]);

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
    now = DateTime.utc(2026, 10, 29, 12);
    reviews = ReviewService(
      db: repos.db,
      collections: repos.collections,
      presets: repos.presets,
      cards: repos.cards,
      notes: repos.notes,
      tags: repos.tags,
      reviews: repos.reviews,
      schedulers: schedulers,
      now: () => (at: now, utcOffset: const Duration(hours: 9)),
    );
    rebuild = RebuildService(
      db: repos.db,
      collections: repos.collections,
      presets: repos.presets,
      cards: repos.cards,
      reviews: repos.reviews,
      schedulers: schedulers,
    );
  });

  /// Reviews a card with each grade in turn, each when it falls due.
  Future<SchedulingState> study(StudyCardId card, List<Grade> grades) async {
    late SchedulingState state;
    for (final grade in grades) {
      state = await reviews.review(card, grade);
      now = state.due ?? now;
    }
    return state;
  }

  /// Replaces a card's stored state with a wrong one.
  Future<void> corrupt(StudyCardId card) => repos.cards.saveSchedulingState(
    SchedulingState(
      studyCardId: card,
      state: StudyCardState.relearning,
      lapses: 99,
    ),
  );

  ReviewEvent event(
    StudyCardId card,
    ReviewEventKind kind, {
    String schedulerId = 'memuki.steps-sm2',
  }) => ReviewEvent(
    id: ReviewEventId.generate(),
    studyCardId: card,
    kind: kind,
    at: now,
    utcOffset: Duration.zero,
    stateBefore: StudyCardState.newCard,
    grade: kind == ReviewEventKind.review ? Grade.good : null,
    schedulerId: schedulerId,
    schedulerVersion: 1,
    presetVersionId: japanese.preset.version.id,
  );

  test('rebuilds the state that reviewing produced', () async {
    final (_, card) = await japanese.addNote('猫');
    final live = await study(card.id, [
      Grade.good,
      Grade.again,
      Grade.good,
      Grade.easy,
      Grade.again,
      Grade.good,
      Grade.hard,
    ]);
    await corrupt(card.id);

    final report = await rebuild.rebuildCard(card.id);
    expect(report.cards, 1);
    expect(report.changed, [card.id]);
    expect(report.warnings, isEmpty);
    expect(report.failures, isEmpty);
    expect(await repos.cards.schedulingState(card.id), live);
  });

  test('changes nothing when the stored state is right', () async {
    final (_, card) = await japanese.addNote('猫');
    await study(card.id, [Grade.good, Grade.easy, Grade.good]);
    final report = await rebuild.rebuildCollection(japanese.id);
    expect(report.cards, 1);
    expect(report.changed, isEmpty);
  });

  test('replays with the preset version recorded on each event', () async {
    await repos.presets.updateSettings(
      japanese.preset.id,
      PresetVersion(
        id: PresetVersionId.generate(),
        schedulerConfig: {
          'learningSteps': [10, 60, 1440],
        },
      ),
    );
    final (_, card) = await japanese.addNote('猫');
    final live = await study(card.id, [Grade.good, Grade.good]);
    await repos.presets.updateSettings(
      japanese.preset.id,
      PresetVersion(
        id: PresetVersionId.generate(),
        schedulerConfig: {
          'learningSteps': [1],
        },
      ),
    );
    await corrupt(card.id);

    await rebuild.rebuildCard(card.id);
    expect(await repos.cards.schedulingState(card.id), live);
  });

  test('uses the collection\'s current study day start', () async {
    final (_, card) = await japanese.addNote('猫');
    final live = await study(card.id, [Grade.easy]);
    await repos.collections.updateCollection(
      japanese.collection.copyWith(dayStart: const Duration(hours: 5)),
    );

    final report = await rebuild.rebuildCollection(japanese.id);
    expect(report.changed, [card.id]);
    final rebuilt = await repos.cards.schedulingState(card.id);
    expect(rebuilt!.due, live.due!.add(const Duration(hours: 2)));
  });

  test('a check reports changes without writing them', () async {
    final (_, card) = await japanese.addNote('猫');
    await study(card.id, [Grade.good]);
    await corrupt(card.id);
    final corrupted = await repos.cards.schedulingState(card.id);

    final report = await rebuild.rebuildCollection(japanese.id, write: false);
    expect(report.changed, [card.id]);
    expect(await repos.cards.schedulingState(card.id), corrupted);
  });

  test('replays events of unknown schedulers with the current preset and '
      'warns', () async {
    final (_, card) = await japanese.addNote('猫');
    await repos.reviews.append(
      event(card.id, ReviewEventKind.review, schedulerId: 'sm2'),
    );

    final report = await rebuild.rebuildCard(card.id);
    expect(report.warnings[card.id], [contains('unknown scheduler sm2 v1')]);
    expect(report.failures, isEmpty);
    final state = await repos.cards.schedulingState(card.id);
    expect(state!.state, StudyCardState.learning);
    expect(state.reviewCount, 1);
  });

  test('keeps the state of cards whose history cannot be replayed', () async {
    final (_, broken) = await japanese.addNote('猫');
    final (_, fine) = await japanese.addNote('犬');
    final live = await study(fine.id, [Grade.good]);
    await repos.reviews.append(event(broken.id, ReviewEventKind.reschedule));
    final before = await repos.cards.schedulingState(broken.id);
    await corrupt(fine.id);

    final report = await rebuild.rebuildCollection(japanese.id);
    expect(report.failures.keys, [broken.id]);
    expect(await repos.cards.schedulingState(broken.id), before);
    expect(await repos.cards.schedulingState(fine.id), live);
  });

  test('skips undone events', () async {
    final (_, card) = await japanese.addNote('猫');
    final live = await study(card.id, [Grade.good, Grade.again]);
    await reviews.review(card.id, Grade.easy);
    await reviews.undo(card.id);
    await reviews.burn(card.id);
    await reviews.undo(card.id);
    await corrupt(card.id);

    await rebuild.rebuildCard(card.id);
    expect(await repos.cards.schedulingState(card.id), live);
  });

  test('replay adds no leech tags', () async {
    await repos.presets.updateSettings(
      japanese.preset.id,
      PresetVersion(id: PresetVersionId.generate(), leechThreshold: 1),
    );
    final (note, card) = await japanese.addNote('猫');
    await study(card.id, [Grade.easy, Grade.again]);
    final tag = (await repos.notes.tagIds(note.id)).single;
    await repos.notes.removeTag(note.id, tag);
    await corrupt(card.id);

    await rebuild.rebuildCard(card.id);
    expect(await repos.notes.tagIds(note.id), isEmpty);
  });

  test('covers cards in subdecks and skips deleted ones', () async {
    final n5 = await japanese.addDeck('N5', parentId: japanese.deck.id);
    final (_, nested) = await japanese.addNote('猫', deckId: n5.id);
    final (_, deleted) = await japanese.addNote('犬');
    await study(nested.id, [Grade.good]);
    await corrupt(nested.id);
    await repos.cards.deleteCard(deleted.id);

    final report = await rebuild.rebuildCollection(japanese.id);
    expect(report.cards, 1);
    expect(report.changed, [nested.id]);
  });

  test('rejects missing cards and collections', () async {
    await expectLater(
      rebuild.rebuildCard(
        StudyCardId.derive(NoteId.generate(), StudyCardTemplateId.generate()),
      ),
      throwsA(isA<EntityNotFoundException>()),
    );
    await expectLater(
      rebuild.rebuildCollection(CollectionId.generate()),
      throwsA(isA<EntityNotFoundException>()),
    );
  });

  test('a generated collection is already rebuilt', () async {
    final root = await Directory.systemTemp.createTemp('memuki_rebuild_test');
    addTearDown(() => root.delete(recursive: true));
    final generated = GeneratedCollection.generate(
      seed: 7,
      notes: 30,
      maxReviews: 8,
      media: 0,
    );
    await generated.writeTo(
      repos,
      MediaRepository(repos.db, await IoMediaStore.open(root)),
    );

    final report = await rebuild.rebuildCollection(generated.id, write: false);
    expect(report.cards, generated.cards.length);
    expect(report.changed, isEmpty);
    expect(report.warnings, isEmpty);
    expect(report.failures, isEmpty);
  });

  group('historyReplay', () {
    final replay = historyReplay(schedulers);
    final cardId = StudyCardId.derive(
      NoteId.generate(),
      StudyCardTemplateId.generate(),
    );
    final version = PresetVersion(id: PresetVersionId.generate());
    var minute = 0;

    ReviewEvent replayed(
      ReviewEventKind kind, {
      PresetVersionId? presetVersionId,
      ReviewEventId? undoes,
    }) => ReviewEvent(
      id: ReviewEventId.generate(),
      studyCardId: cardId,
      kind: kind,
      at: now.add(Duration(minutes: minute++)),
      utcOffset: Duration.zero,
      stateBefore: StudyCardState.newCard,
      grade: kind == ReviewEventKind.review ? Grade.easy : null,
      undoneEventId: undoes,
      schedulerId: 'memuki.steps-sm2',
      schedulerVersion: 1,
      presetVersionId: presetVersionId ?? version.id,
    );

    Map<ReviewEventId, StudyCardState> run(List<ReviewEvent> events) => replay(
      HistoryToReplay(
        events: events,
        versions: {version.id: version},
        fallback: version,
        dayStart: const Duration(hours: 3),
      ),
    );

    test('events of unknown preset versions use the fallback', () {
      final first = replayed(
        ReviewEventKind.review,
        presetVersionId: PresetVersionId.generate(),
      );
      final second = replayed(ReviewEventKind.burn);
      expect(run([first, second]), {
        first.id: StudyCardState.newCard,
        second.id: StudyCardState.review,
      });
    });

    test('events that cannot be applied leave the state unchanged', () {
      final reschedule = replayed(ReviewEventKind.reschedule);
      final review = replayed(ReviewEventKind.review);
      expect(run([reschedule, review])[review.id], StudyCardState.newCard);
    });

    test('an undo restores the state before the undone event', () {
      final review = replayed(ReviewEventKind.review);
      final undo = replayed(ReviewEventKind.undo, undoes: review.id);
      final next = replayed(ReviewEventKind.burn);
      expect(run([review, undo, next]), {
        review.id: StudyCardState.newCard,
        undo.id: StudyCardState.review,
        next.id: StudyCardState.newCard,
      });
    });
  });
}
