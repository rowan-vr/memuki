import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/domain/review.dart';
import 'package:memuki/services/providers.dart';
import 'package:memuki/storage/providers.dart';

import '../helpers/test_database.dart';

void main() {
  test('the review service uses the overridden database', () async {
    final db = openTestDatabase();
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final (_, card) = await (await Repositories(
      db,
    ).seedCollection()).addNote('猫');

    await container.read(reviewServiceProvider).review(card.id, Grade.good);

    expect(await Repositories(db).reviews.history(card.id), hasLength(1));
  });
}
