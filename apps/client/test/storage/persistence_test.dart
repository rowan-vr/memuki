import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/storage/database.dart';
import 'package:memuki/storage/media/io_media_store.dart';
import 'package:memuki/storage/repositories/media_repository.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_database.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('memuki_persistence_test');
    addTearDown(() => dir.delete(recursive: true));
  });

  /// A fixture database and media store in [dir]/[name].
  Future<(MemukiDatabase, MediaRepository)> open(String name) async {
    final db = openFixtureDatabase(
      NativeDatabase(File('${dir.path}/$name.sqlite')),
    );
    final store = await IoMediaStore.open(Directory('${dir.path}/$name-media'));
    return (db, MediaRepository(db, store));
  }

  Future<Map<String, List<Map<String, Object?>>>> generate(
    String name, {
    required int seed,
  }) async {
    final (db, media) = await open(name);
    await CollectionFixture.generate(seed: seed)
        .writeTo(Repositories(db), media);
    final dump = await dumpTables(db);
    await db.close();
    return dump;
  }

  test('the same seed gives the same database', () async {
    final first = await generate('first', seed: 7);
    expect(await generate('second', seed: 7), first);
    expect(await generate('other', seed: 8), isNot(first));
  });

  test('everything written survives a restart', () async {
    final fixture = CollectionFixture.generate(seed: 3);
    var (db, media) = await open('memuki');
    var repos = Repositories(db);
    await fixture.writeTo(repos, media);
    final deletedNote = fixture.notes.first;
    await repos.notes.deleteNote(deletedNote.id);
    final before = await dumpTables(db);
    await db.close();

    (db, media) = await open('memuki');
    addTearDown(db.close);
    repos = Repositories(db);
    expect(await dumpTables(db), before);

    expect(await repos.collections.collections(), [fixture.collection]);
    expect(
      await repos.collections.decks(fixture.id),
      unorderedEquals(fixture.decks),
    );
    expect(await repos.tags.tags(fixture.id), unorderedEquals(fixture.tags));
    expect(await repos.noteTypes.noteTypes(fixture.id), [fixture.noteType]);
    expect(await repos.notes.note(deletedNote.id), isNull);
    final live = fixture.notes.skip(1).toList();
    expect(await repos.notes.notes(fixture.id), live);
    for (final note in live) {
      expect(await repos.notes.tagIds(note.id), fixture.noteTags[note.id]);
      expect(
        await repos.cards.cardsOfNote(note.id),
        unorderedEquals(fixture.cards.where((c) => c.noteId == note.id)),
      );
    }
    for (final card in fixture.cards) {
      expect(
        await repos.reviews.history(card.id),
        fixture.reviews.where((e) => e.studyCardId == card.id),
      );
    }
    for (final state in fixture.states) {
      expect(await repos.cards.schedulingState(state.studyCardId), state);
    }
    for (final file in fixture.media) {
      final asset = (await media.mediaOf(fixture.id))
          .singleWhere((a) => a.originalName == file.name);
      final bytes = await media.read(fixture.id, asset.hash).toList();
      expect(bytes.expand((b) => b), file.bytes);
    }

    // The clock continues after the last timestamp written before closing.
    final last = (await db.select(db.device).getSingle()).lastHlc!;
    expect(db.clock.tick() > last, isTrue);
  });
}
