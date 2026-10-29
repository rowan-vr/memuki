import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/storage/repositories/repository_exceptions.dart';

import '../../helpers/test_database.dart';

void main() {
  late Repositories repos;
  late SeededCollection japanese;

  setUp(() async {
    repos = Repositories(openTestDatabase());
    japanese = await repos.seedCollection();
  });

  group('names', () {
    test('are unique among siblings, ignoring case', () async {
      await japanese.addTag('Grammar');
      await expectLater(
        japanese.addTag('grammar'),
        throwsA(isA<DuplicateNameException>()),
      );
    });

    test('ignore case beyond ASCII', () async {
      await japanese.addTag('Ärger');
      await expectLater(
        japanese.addTag('ärger'),
        throwsA(isA<DuplicateNameException>()),
      );
    });

    test('may repeat under different parents', () async {
      final japaneseTag = await japanese.addTag('japanese');
      final koreanTag = await japanese.addTag('korean');
      await japanese.addTag('grammar', parentId: japaneseTag.id);
      await japanese.addTag('grammar', parentId: koreanTag.id);
      expect(await repos.tags.tags(japanese.id), hasLength(4));
    });

    test('may repeat in another collection', () async {
      final korean = await repos.seedCollection(name: 'Korean');
      await japanese.addTag('grammar');
      await korean.addTag('grammar');
    });

    test('are checked when renaming and moving', () async {
      final parent = await japanese.addTag('parent');
      await japanese.addTag('grammar', parentId: parent.id);
      final loose = await japanese.addTag('Grammar');

      await expectLater(
        repos.tags.updateTag(loose.copyWith(parentId: parent.id)),
        throwsA(isA<DuplicateNameException>()),
      );
      // Renaming a tag to its own name with different case is fine.
      await repos.tags.updateTag(loose.copyWith(name: 'GRAMMAR'));
    });
  });

  test('are read and watched', () async {
    final tags = repos.tags.watchTags(japanese.id).map((ts) => ts.length);
    expect(tags, emitsInOrder([0, 1]));
    await pumpEventQueue();
    final tag = await japanese.addTag('grammar');
    expect(await repos.tags.tag(tag.id), tag);
    await repos.tags.deleteTag(tag.id);
    expect(await repos.tags.tag(tag.id), isNull);
  });

  test('cannot move below themselves', () async {
    final a = await japanese.addTag('a');
    final b = await japanese.addTag('b', parentId: a.id);
    await expectLater(
      repos.tags.updateTag(a.copyWith(parentId: b.id)),
      throwsA(isA<ParentCycleException>()),
    );
  });

  test('cannot have a parent in another collection', () async {
    final korean = await repos.seedCollection(name: 'Korean');
    final foreign = await korean.addTag('grammar');
    await expectLater(
      japanese.addTag('particles', parentId: foreign.id),
      throwsA(isA<CrossCollectionException>()),
    );
  });

  test('deleting one removes its subtree from all notes', () async {
    final grammar = await japanese.addTag('grammar');
    final particles = await japanese.addTag('particles', parentId: grammar.id);
    final vocab = await japanese.addTag('vocab');
    final (note, _) = await japanese.addNote('は');
    await repos.notes.addTag(note.id, particles.id);
    await repos.notes.addTag(note.id, vocab.id);

    await repos.tags.deleteTag(grammar.id);

    expect(await repos.tags.tags(japanese.id), [vocab]);
    expect(await repos.notes.tagIds(note.id), {vocab.id});
  });
}
