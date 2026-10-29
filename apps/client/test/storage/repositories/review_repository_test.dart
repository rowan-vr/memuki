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
        grade: undoes == null ? Grade.good : null,
        responseTime: const Duration(milliseconds: 3200),
        undoneEventId: undoes,
        schedulerId: 'sm2',
        schedulerVersion: 1,
        configVersion: 1,
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
