import 'dart:io';
import 'dart:math';

import 'package:args/command_runner.dart';
import 'package:drift/drift.dart';
import 'package:memuki/dev/collection_generator.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/scheduler/scheduler_registry.dart';
import 'package:memuki/scheduler/steps_sm2/steps_sm2_scheduler.dart';
import 'package:memuki/services/rebuild_service.dart';
import 'package:path/path.dart' as p;

import 'runner.dart';
import 'session.dart';

List<Command<void>> maintenanceCommands() => [
  ActionCommand(
    'generate',
    'Write a generated collection: random deck and tag trees, notes with '
        'tags and cards, review history, and media. The same seed gives the '
        'same collection.',
    _generate,
    options: (p) => p
      ..addOption('seed', help: 'Default: random. Printed after generating.')
      ..addOption('notes', defaultsTo: '40')
      ..addOption('decks', defaultsTo: '5')
      ..addOption('tags', defaultsTo: '6')
      ..addOption('reviews', defaultsTo: '4', help: 'Most reviews per card.')
      ..addOption('media', defaultsTo: '3'),
  ),
  ActionCommand(
    'rebuild',
    'Rebuild the scheduling state of every card in a collection by '
        'replaying its review history.',
    _rebuild,
    arguments: '<collection>',
    options: (p) => p.addFlag(
      'check',
      negatable: false,
      help: 'Only report the cards whose state would change.',
    ),
  ),
  ActionCommand(
    'sql',
    'Run a read-only SQL query. 16-byte blobs are shown as IDs.',
    (c, s) async {
      await s.db.customStatement('PRAGMA query_only = ON');
      try {
        final rows = await s.db.customSelect(c.arg(0, 'query')).get();
        if (rows.isEmpty) {
          s.out.writeln('(no rows)');
          return;
        }
        s.table(rows.first.data.keys.toList(), [
          for (final row in rows) [for (final v in row.data.values) _cell(v)],
        ]);
      } finally {
        await s.db.customStatement('PRAGMA query_only = OFF');
      }
    },
    arguments: '"<query>"',
  ),
  _ResetCommand(),
];

Object? _cell(Object? value) => switch (value) {
  Uint8List(length: 16) => uuidOf(value),
  final Uint8List bytes =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
  _ => value,
};

Future<void> _generate(ActionCommand c, Session s) async {
  int count(String name) => int.parse(c.option(name)!);
  final seed =
      int.tryParse(c.option('seed') ?? '') ?? Random().nextInt(1 << 31);
  final collection = GeneratedCollection.generate(
    seed: seed,
    notes: count('notes'),
    decks: count('decks'),
    tags: count('tags'),
    maxReviews: count('reviews'),
    media: count('media'),
  );
  if (await s.repos.collections.collection(collection.id) != null) {
    throw ToolException('Seed $seed was generated already; pick another.');
  }
  await collection.writeTo(s.repos, s.media);
  s.out.writeln(
    'Generated "${collection.collection.name}" (${short(collection.id)}) '
    'from seed $seed: ${collection.decks.length} decks, '
    '${collection.tags.length} tags, ${collection.notes.length} notes, '
    '${collection.cards.length} cards, ${collection.reviews.length} reviews, '
    '${collection.media.length} media files.',
  );
}

class _ResetCommand extends Command<void> {
  _ResetCommand() {
    argParser.addFlag('yes', negatable: false, help: 'Confirm.');
  }

  @override
  String get name => 'reset';

  @override
  String get description =>
      'Move the database and media folder into a backup folder next to them, '
      'so the next start begins empty.';

  @override
  Future<void> run() async {
    final options = globalResults!;
    final db = File(options['db'] as String);
    final media = Directory(
      options['media'] as String? ?? p.join(db.parent.path, 'media'),
    );
    final out = (runner! as MemukiRunner).out;
    if (!(argResults!['yes'] as bool)) {
      out.writeln(
        'This moves ${db.path} and ${media.path} into a backup folder. '
        'Run again with --yes.',
      );
      return;
    }
    final backup = Directory(
      p.join(
        db.parent.path,
        'memuki-reset-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    await backup.create(recursive: true);
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final file = File('${db.path}$suffix');
      if (file.existsSync()) {
        await file.rename(p.join(backup.path, p.basename(file.path)));
      }
    }
    if (media.existsSync()) {
      await media.rename(p.join(backup.path, p.basename(media.path)));
    }
    out.writeln('Moved to ${backup.path}.');
  }
}

Future<void> _rebuild(ActionCommand c, Session s) async {
  final collection = CollectionId.parse(
    await s.resolve('collections', c.arg(0, 'collection'), label: 'collection'),
  );
  final check = c.flag('check');
  final report = await RebuildService(
    db: s.db,
    collections: s.repos.collections,
    presets: s.repos.presets,
    cards: s.repos.cards,
    reviews: s.repos.reviews,
    schedulers: SchedulerRegistry([const StepsSm2Scheduler()]),
  ).rebuildCollection(collection, write: !check);
  for (final MapEntry(key: card, value: warnings) in report.warnings.entries) {
    for (final warning in warnings) {
      s.out.writeln('Warning: card ${short(card)}: $warning');
    }
  }
  for (final MapEntry(key: card, value: error) in report.failures.entries) {
    s.out.writeln('Failed: card ${short(card)} kept its state: $error');
  }
  s.out.writeln(
    '${report.cards} cards replayed; ${report.changed.length} '
    '${check ? 'would change' : 'changed'}, ${report.warnings.length} with '
    'warnings, ${report.failures.length} failed.',
  );
}
