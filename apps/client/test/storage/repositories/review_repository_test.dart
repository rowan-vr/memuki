import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
  });

  ReviewEvent event(StudyCardId cardId, DateTime at, {ReviewEventId? undoes}) =>
      ReviewEvent(
        id: ReviewEventId.generate(),
        studyCardId: cardId,
        kind: undoes == null ? ReviewEventKind.review : ReviewEventKind.undo,
        at: at,
        utcOffset: Duration.zero,
        grade: undoes == null ? Grade.good : null,
        responseTime: const Duration(milliseconds: 3200),
        undoneEventId: undoes,
        schedulerId: 'sm2',
        schedulerVersion: 1,
        presetVersionId: japanese.preset.version.id,
      );

  test('history is in order of time', () async {
    final (_, card) = await japanese.addNote('猫');
    final later = event(card.id, DateTime.utc(2026, 10, 30));
    final earlier = event(card.id, DateTime.utc(2026, 10, 29));
    await repos.reviews.append(later);
    await repos.reviews.append(earlier);
    expect(await repos.reviews.history(card.id), [earlier, later]);
  });

  test('an undo must refer to an event of the same card', () async {
    final (_, card) = await japanese.addNote('猫');
    final (_, other) = await japanese.addNote('犬');
    final review = event(other.id, DateTime.utc(2026, 10, 29));
    await repos.reviews.append(review);

    await expectLater(
      repos.reviews.append(
        event(card.id, DateTime.utc(2026, 10, 30), undoes: review.id),
      ),
      throwsA(isA<EntityNotFoundException>()),
    );
    await repos.reviews.append(
      event(other.id, DateTime.utc(2026, 10, 30), undoes: review.id),
    );
  });

  group('undo', () {
    late StudyCardId cardId;
    late ReviewEvent r1;
    late ReviewEvent r2;
    var minute = 0;

    DateTime next() => DateTime.utc(2026, 10, 29, 12, minute++);

    Future<ReviewEvent> undo(ReviewEvent target) async {
      final undo = event(cardId, next(), undoes: target.id);
      await repos.reviews.append(undo);
      return undo;
    }

    Matcher rejects() => throwsA(isA<InvalidReviewEventException>());

    setUp(() async {
      final (_, card) = await japanese.addNote('猫');
      cardId = card.id;
      r1 = event(cardId, next());
      r2 = event(cardId, next());
      await repos.reviews.append(r1);
      await repos.reviews.append(r2);
    });

    test('only the latest action in effect can be undone', () async {
      await expectLater(undo(r1), rejects());
      await undo(r2);
      await expectLater(undo(r2), rejects());
      await undo(r1);
    });

    test('only the latest undo can be redone', () async {
      final u1 = await undo(r2);
      final u2 = await undo(r1);
      await expectLater(undo(u1), rejects());
      await undo(u2);
      await undo(u1);
    });

    test('a redo cannot be undone; the action is undone again', () async {
      final u1 = await undo(r2);
      final redo = await undo(u1);
      await expectLater(undo(redo), rejects());
      await undo(r2);
    });

    test('a new action ends what can be redone', () async {
      final u1 = await undo(r2);
      await repos.reviews.append(event(cardId, next()));
      await expectLater(undo(u1), rejects());
    });
  });

  test('events need an existing card', () async {
    await expectLater(
      repos.reviews.append(
        event(
          StudyCardId.derive(NoteId.generate(), StudyCardTemplateId.generate()),
          DateTime.utc(2026, 10, 29),
        ),
      ),
      throwsA(isA<EntityNotFoundException>()),
    );
  });
}
