import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/runner.dart';
import '../../tool/src/session.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('memuki_tool_test');
    addTearDown(() => dir.delete(recursive: true));
  });

  /// Runs the tool on a database in [dir] and returns what it printed.
  Future<String> memuki(List<String> args) async {
    final out = StringBuffer();
    await MemukiRunner(out: out)
        .run(['--db', '${dir.path}/memuki.sqlite', ...args]);
    return '$out';
  }

  test('generates and inspects a collection', () async {
    expect(
      await memuki(['generate', '--seed', '5', '--notes', '6']),
      contains('from seed 5: 5 decks, 6 tags, 6 notes, 12 cards'),
    );
    expect(await memuki(['info']), contains(RegExp(r'notes\s+6\s+0\s+0')));
    expect(await memuki(['collections']), contains('Collection 5'));
    final tree = await memuki(['tree', 'Collection 5']);
    expect(
      tree,
      allOf(contains('Deck 0'), contains('tag0'), contains('Basic')),
    );
    expect(await memuki(['notes', '--limit', '2']), contains('… 4 more'));
    expect(await memuki(['notes', '--tag', 'tag0']), contains('meaning'));
    expect(await memuki(['cards', '--deck', 'Deck 0']), contains('Recall'));
    expect(await memuki(['outbox', '--limit', '1']), contains('entries'));
    expect(await memuki(['check']), contains('No problems found.'));
    expect(
      await memuki(['rebuild', 'Collection 5', '--check']),
      contains('12 cards replayed; 0 would change, 0 with warnings, 0 failed.'),
    );
    expect(
      await memuki(['sql', 'SELECT name FROM decks ORDER BY name LIMIT 1']),
      contains('Deck 0'),
    );
    await expectLater(
      memuki(['generate', '--seed', '5']),
      throwsA(isA<ToolException>()),
    );
  });

  test('edits through the repositories', () async {
    await memuki(['collection', 'add', 'Japanese']);
    await memuki(['deck', 'add', 'Japanese', 'N5', '--parent', 'Default']);
    await memuki(['tag', 'add', 'Japanese', 'animals']);
    final created = await memuki([
      'note',
      'add',
      'Japanese',
      '--deck',
      'N5',
      '--tag',
      'animals',
      'Front=猫',
      'Back=cat',
    ]);
    final noteId = RegExp(r'note (\w+)').firstMatch(created)![1]!;
    await memuki(['note', 'edit', noteId, 'back=kitty']);

    final note = await memuki(['show', noteId]);
    expect(note, allOf(contains('kitty'), contains('animals')));
    final cardId = RegExp(
      r'^(\w{8})  猫',
      multiLine: true,
    ).firstMatch(note)![1]!;
    expect(
      await memuki(['review', cardId, 'good']),
      contains('Recorded review'),
    );
    expect(await memuki(['show', cardId]), contains('history (1)'));
    expect(
      await memuki(['rebuild', 'Japanese']),
      contains('1 cards replayed; 0 changed'),
    );

    await memuki(['deck', 'delete', 'Default']);
    expect(await memuki(['show', noteId]), contains('hidden'));
    expect(
      await memuki(['info']),
      contains(RegExp(r'study_cards\s+0\s+0\s+1')),
    );
  });

  test('adds, lists, and deletes media', () async {
    await memuki(['collection', 'add', 'Japanese', '--empty']);
    final file = File('${dir.path}/neko.txt')..writeAsStringSync('neko');
    final added = await memuki(['media', 'add', 'Japanese', file.path]);
    expect(added, contains('text/plain'));
    final hash = RegExp(r'Added (\w{8})').firstMatch(added)![1]!;
    expect(await memuki(['media', 'list', 'Japanese']), contains('neko.txt'));
    await memuki(['media', 'delete', 'Japanese', hash]);
    expect(
      await memuki(['media', 'list', 'Japanese']),
      isNot(contains('neko.txt')),
    );
  });

  test('reset moves the data into a backup folder', () async {
    await memuki(['collection', 'add', 'Japanese']);
    expect(await memuki(['reset']), contains('--yes'));
    expect(File('${dir.path}/memuki.sqlite').existsSync(), isTrue);
    expect(await memuki(['reset', '--yes']), contains('memuki-reset-'));
    expect(File('${dir.path}/memuki.sqlite').existsSync(), isFalse);
    expect(await memuki(['collections']), isNot(contains('Japanese')));
  });

  test('reports ambiguous and unknown references', () async {
    await memuki(['collection', 'add', 'Japanese']);
    await memuki(['collection', 'add', 'Korean']);
    await expectLater(
      memuki(['show', 'Default']),
      throwsA(
        isA<ToolException>().having(
          (e) => e.message,
          'message',
          contains('matches 2'),
        ),
      ),
    );
    await expectLater(
      memuki(['show', 'nothing']),
      throwsA(isA<ToolException>()),
    );
  });
}
