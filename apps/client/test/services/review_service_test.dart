import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/preset.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/domain/study_card.dart';
import 'package:memuki/scheduler/scheduler_registry.dart';
import 'package:memuki/scheduler/steps_sm2/steps_sm2_scheduler.dart';
import 'package:memuki/services/review_service.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;
  late ReviewService service;
  // 21:00 on 29 October in UTC+9.
  var now = DateTime.utc(2026, 10, 29, 12);
  const offset = Duration(hours: 9);

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
    now = DateTime.utc(2026, 10, 29, 12);
    await repos.presets.updateSettings(
      japanese.preset.id,
      PresetVersion(
        id: PresetVersionId.generate(),
        schedulerConfig: {'fuzz': false},
      ),
    );
    service = ReviewService(
      db: repos.db,
      collections: repos.collections,
      presets: repos.presets,
      cards: repos.cards,
      notes: repos.notes,
      tags: repos.tags,
      reviews: repos.reviews,
      schedulers: SchedulerRegistry([const StepsSm2Scheduler()]),
      now: () => (at: now, utcOffset: offset),
    );
  });

  test('records a complete event and the new state', () async {
    final (_, card) = await japanese.addNote('猫');
    final state = await service.review(
      card.id,
      Grade.good,
      responseTime: const Duration(seconds: 4),
    );

    expect(state.state, StudyCardState.learning);
    expect(state.due, now.add(const Duration(hours: 4)));
    expect(await repos.cards.schedulingState(card.id), state);

    final event = (await repos.reviews.history(card.id)).single;
    expect(event.id, state.lastEventId);
    expect(event.kind, ReviewEventKind.review);
    expect(event.grade, Grade.good);
    expect(event.at, now);
    expect(event.utcOffset, offset);
    expect(event.responseTime, const Duration(seconds: 4));
    expect(event.dueBefore, isNull);
    expect(event.dueAfter, state.due);
    expect(event.schedulerId, 'memuki.steps-sm2');
    expect(event.schedulerVersion, 1);
    expect(
      event.presetVersionId,
      (await repos.presets.preset(japanese.preset.id))!.version.id,
    );
  });

  test('later reviews continue from the saved state', () async {
    final (_, card) = await japanese.addNote('猫');
    final first = await service.review(card.id, Grade.good);
    now = first.due!;
    final second = await service.review(card.id, Grade.good);

    expect(second.step, 2);
    expect(second.reviewCount, 2);
    final history = await repos.reviews.history(card.id);
    expect(history.last.dueBefore, first.due);
    expect(history.last.dueAfter, second.due);
  });

  test('study days follow the device offset', () async {
    final (_, card) = await japanese.addNote('猫');
    final state = await service.review(card.id, Grade.easy);
    // 14 days later at 03:00 in UTC+9.
    expect(state.due, DateTime.utc(2026, 11, 11, 18));
  });

  test('uses the preset of the card\'s deck and the collection\'s day '
      'start', () async {
    final preset = Preset(
      id: PresetId.generate(),
      collectionId: japanese.id,
      name: 'Short',
      version: PresetVersion(
        id: PresetVersionId.generate(),
        schedulerConfig: {
          'learningSteps': [1440],
          'graduatingInterval': 2,
        },
      ),
    );
    await repos.presets.createPreset(preset);
    await repos.collections.updateDeck(
      japanese.deck.copyWith(presetId: preset.id),
    );
    await repos.collections.updateCollection(
      japanese.collection.copyWith(dayStart: const Duration(hours: 5)),
    );
    final n5 = await japanese.addDeck('N5', parentId: japanese.deck.id);
    final (_, card) = await japanese.addNote('猫', deckId: n5.id);

    final state = await service.review(card.id, Grade.again);
    // One study day later at 05:00 in UTC+9.
    expect(state.due, DateTime.utc(2026, 10, 29, 20));
    final event = (await repos.reviews.history(card.id)).single;
    expect(event.presetVersionId, preset.version.id);
  });

  test('rejects unknown cards and schedulers without writing', () async {
    final (_, card) = await japanese.addNote('猫');
    final before = await repos.cards.schedulingState(card.id);
    final missing = StudyCardId.derive(
      NoteId.generate(),
      StudyCardTemplateId.generate(),
    );
    await expectLater(
      service.review(missing, Grade.good),
      throwsA(isA<EntityNotFoundException>()),
    );
    await repos.presets.updateSettings(
      japanese.preset.id,
      PresetVersion(id: PresetVersionId.generate(), schedulerId: 'other'),
    );
    await expectLater(
      service.review(card.id, Grade.good),
      throwsA(isA<UnknownSchedulerException>()),
    );
    expect(await repos.reviews.history(card.id), isEmpty);
    expect(await repos.cards.schedulingState(card.id), before);
  });

  group('leeches', () {
    /// A card in review that has lapsed [lapses] times.
    Future<(Note, StudyCard)> lapsedCard(String front, int lapses) async {
      final (note, card) = await japanese.addNote(front);
      await repos.cards.saveSchedulingState(
        SchedulingState(
          studyCardId: card.id,
          state: StudyCardState.review,
          due: now,
          interval: const Duration(days: 10),
          ease: 2.5,
          lapses: lapses,
        ),
      );
      return (note, card);
    }

    Future<List<String>> tagNames(Note note) async {
      final tags = await repos.tags.tags(japanese.id);
      final ids = await repos.notes.tagIds(note.id);
      return [
        for (final tag in tags)
          if (ids.contains(tag.id)) tag.name,
      ];
    }

    test('the lapse that reaches the threshold tags the note', () async {
      final (note, card) = await lapsedCard('猫', 7);
      final state = await service.review(card.id, Grade.again);
      expect(state.lapses, 8);
      expect(await tagNames(note), ['leech']);
      final tag = (await repos.tags.tags(japanese.id)).single;
      expect(tag.parentId, isNull);
    });

    test('other lapses and passes do not tag the note', () async {
      final (lapsing, lapsingCard) = await lapsedCard('猫', 8);
      final (passing, passingCard) = await lapsedCard('犬', 7);
      await service.review(lapsingCard.id, Grade.again);
      await service.review(passingCard.id, Grade.good);
      expect(await tagNames(lapsing), isEmpty);
      expect(await tagNames(passing), isEmpty);
    });

    test('a card is tagged again every half threshold', () async {
      final (note, card) = await lapsedCard('猫', 11);
      await service.review(card.id, Grade.again);
      expect(await tagNames(note), ['leech']);
    });

    test('leeches share one tag, reusing an existing one', () async {
      final existing = await japanese.addTag('Leech');
      final (first, firstCard) = await lapsedCard('猫', 7);
      final (second, secondCard) = await lapsedCard('犬', 7);
      await service.review(firstCard.id, Grade.again);
      await service.review(secondCard.id, Grade.again);
      expect(await repos.notes.tagIds(first.id), {existing.id});
      expect(await repos.notes.tagIds(second.id), {existing.id});
      expect(await repos.tags.tags(japanese.id), [existing]);
    });

    test('a nested tag named leech is not reused', () async {
      final parent = await japanese.addTag('JLPT');
      await japanese.addTag('leech', parentId: parent.id);
      final (note, card) = await lapsedCard('猫', 7);
      await service.review(card.id, Grade.again);
      final tag = (await repos.tags.tags(japanese.id))
          .singleWhere((t) => t.parentId == null && t.name == 'leech');
      expect(await repos.notes.tagIds(note.id), {tag.id});
    });

    test('nothing is tagged when leech detection is off', () async {
      final (note, card) = await lapsedCard('猫', 7);
      await repos.presets.updateSettings(
        japanese.preset.id,
        PresetVersion(id: PresetVersionId.generate(), leechThreshold: null),
      );
      await service.review(card.id, Grade.again);
      expect(await tagNames(note), isEmpty);
    });
  });

  group('burning', () {
    test('a manual burn burns the card and records the event', () async {
      final (_, card) = await japanese.addNote('猫');
      final reviewed = await service.review(card.id, Grade.good);
      final state = await service.burn(card.id);

      expect(state.state, StudyCardState.burned);
      expect(state.due, isNull);
      expect(await repos.cards.schedulingState(card.id), state);
      final event = (await repos.reviews.history(card.id)).last;
      expect(event.kind, ReviewEventKind.burn);
      expect(event.id, state.lastEventId);
      expect(event.dueBefore, reviewed.due);
      expect(event.dueAfter, isNull);
    });

    test('an unburned card is due at the start of today', () async {
      final (_, card) = await japanese.addNote('猫');
      await service.review(card.id, Grade.easy);
      await service.burn(card.id);
      final state = await service.unburn(card.id);

      expect(state.state, StudyCardState.review);
      // 03:00 on 29 October in UTC+9.
      expect(state.due, DateTime.utc(2026, 10, 28, 18));
      expect(state.interval, const Duration(days: 14));
      final event = (await repos.reviews.history(card.id)).last;
      expect(event.kind, ReviewEventKind.unburn);
      expect(event.dueAfter, state.due);
    });

    test(
      'rejects burning a burned card and unburning an unburned one',
      () async {
        final (_, card) = await japanese.addNote('猫');
        await expectLater(
          service.unburn(card.id),
          throwsA(isA<InvalidReviewEventException>()),
        );
        await service.burn(card.id);
        await expectLater(
          service.burn(card.id),
          throwsA(isA<InvalidReviewEventException>()),
        );
        expect(await repos.reviews.history(card.id), hasLength(1));
      },
    );
  });

  group('undo', () {
    test('undoing a review restores the state before it', () async {
      final (_, card) = await japanese.addNote('猫');
      final first = await service.review(card.id, Grade.good);
      now = first.due!;
      final second = await service.review(card.id, Grade.good);
      now = now.add(const Duration(minutes: 1));
      final undone = await service.undo(card.id);

      expect(undone, first);
      expect(await repos.cards.schedulingState(card.id), first);
      final history = await repos.reviews.history(card.id);
      expect(history, hasLength(3));
      expect(history.last.kind, ReviewEventKind.undo);
      expect(history.last.undoneEventId, second.lastEventId);
      expect(history.last.dueBefore, second.due);
      expect(history.last.dueAfter, first.due);
    });

    test('undo and redo walk back and forth', () async {
      final (_, card) = await japanese.addNote('猫');
      final first = await service.review(card.id, Grade.good);
      now = first.due!;
      final second = await service.review(card.id, Grade.easy);

      expect(await service.undo(card.id), first);
      final none = await service.undo(card.id);
      expect(none.state, StudyCardState.newCard);
      expect(none.lastEventId, isNull);
      expect(await service.redo(card.id), first);
      expect(await service.redo(card.id), second);
      expect(await service.undo(card.id), first);
    });

    test('undoes burns and unburns', () async {
      final (_, card) = await japanese.addNote('猫');
      final reviewed = await service.review(card.id, Grade.easy);
      final burned = await service.burn(card.id);
      await service.unburn(card.id);
      expect(await service.undo(card.id), burned);
      expect(await service.undo(card.id), reviewed);
    });

    test(
      'rejects undo and redo when there is nothing to undo or redo',
      () async {
        final (_, card) = await japanese.addNote('猫');
        await expectLater(
          service.undo(card.id),
          throwsA(isA<InvalidReviewEventException>()),
        );
        await service.review(card.id, Grade.good);
        await expectLater(
          service.redo(card.id),
          throwsA(isA<InvalidReviewEventException>()),
        );
        await service.undo(card.id);
        await service.review(card.id, Grade.easy);
        await expectLater(
          service.redo(card.id),
          throwsA(isA<InvalidReviewEventException>()),
        );
      },
    );

    group('leeches', () {
      setUp(() async {
        await repos.presets.updateSettings(
          japanese.preset.id,
          PresetVersion(
            id: PresetVersionId.generate(),
            schedulerConfig: {'fuzz': false},
            leechThreshold: 1,
          ),
        );
      });

      /// Graduates the card and fails it once, making it a leech.
      Future<void> lapse(StudyCardId card) async {
        await service.review(card, Grade.easy);
        await service.review(card, Grade.again);
      }

      test('undoing the lapse that made a leech removes the tag', () async {
        final (note, card) = await japanese.addNote('猫');
        await lapse(card.id);
        final tag = (await repos.notes.tagIds(note.id)).single;

        await service.undo(card.id);
        expect(await repos.notes.tagIds(note.id), isEmpty);
        expect(await repos.tags.tags(japanese.id), hasLength(1));

        await service.redo(card.id);
        expect(await repos.notes.tagIds(note.id), {tag});
      });

      test('keeps the tag while another card of the note is a leech', () async {
        final template = StudyCardTemplate(
          id: StudyCardTemplateId.generate(),
          name: 'Card 2',
        );
        await repos.noteTypes.updateNoteType(
          japanese.noteType.copyWith(
            templates: [...japanese.noteType.templates, template],
          ),
        );
        final (note, card) = await japanese.addNote('猫');
        final sibling = StudyCard(
          noteId: note.id,
          templateId: template.id,
          deckId: japanese.deck.id,
        );
        await repos.cards.createCard(sibling);
        await lapse(card.id);
        await lapse(sibling.id);

        await service.undo(card.id);
        expect(await repos.notes.tagIds(note.id), hasLength(1));
        await service.undo(sibling.id);
        expect(await repos.notes.tagIds(note.id), isEmpty);
      });

      test('undoing other events leaves the tag alone', () async {
        final (note, card) = await japanese.addNote('猫');
        final tag = await japanese.addTag('leech');
        await repos.notes.addTag(note.id, tag.id);
        await service.review(card.id, Grade.good);
        await service.undo(card.id);
        expect(await repos.notes.tagIds(note.id), {tag.id});
      });
    });
  });
}
