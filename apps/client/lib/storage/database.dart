import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/ids.dart';
import '../domain/note.dart' show SourceKind;
import '../domain/note_type.dart' show FieldType;
import '../domain/review.dart' show Grade, ReviewEventKind, StudyCardState;
import 'converters.dart';
import 'database.steps.dart';
import 'database_exceptions.dart';
import 'sync/hlc.dart';
import 'tables/tables.dart';

part 'database.g.dart';

final _log = Logger('memuki.storage');

/// The local database holding all collections.
///
/// Schema changes increase [schemaVersion] and add a step to [upgradeSchema]
/// (see "Changing the database schema" in docs/DEVELOPMENT.md).
/// Upgrades run in one transaction and fail if they leave foreign key
/// violations, so a failed upgrade leaves the database as it was. Before
/// upgrading, a copy of the database is written to [backupDirectory].
@DriftDatabase(
  tables: [
    Collections,
    Decks,
    Tags,
    NoteTypes,
    FieldDefinitions,
    StudyCardTemplates,
    Notes,
    NoteFields,
    NoteTags,
    StudyCards,
    MediaAssets,
    ReviewEvents,
    SchedulingStates,
    Device,
    Outbox,
  ],
  include: {'triggers.drift'},
)
class MemukiDatabase extends _$MemukiDatabase {
  MemukiDatabase(super.e, {this.backupDirectory, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// Opens the app's database in the application support directory.
  factory MemukiDatabase.open() => MemukiDatabase(
    driftDatabase(
      name: 'memuki',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
    // Web storage is set up in Phase 12.
    backupDirectory: kIsWeb ? null : getApplicationSupportDirectory,
  );

  /// Where to write a copy of the database before upgrading it, or null to
  /// skip the copy.
  final Future<Directory> Function()? backupDirectory;

  final DateTime Function() _now;
  late HlcClock _clock;

  /// Issues timestamps for local changes. Available once the database is
  /// open, which every query and transaction ensures.
  HlcClock get clock => _clock;

  @override
  int get schemaVersion => 2;

  /// Opens the database now rather than on the first query, creating or
  /// upgrading the schema. Throws [DatabaseTooNewException] or
  /// [DatabaseMigrationException] if the database cannot be used.
  Future<void> ensureOpen() => customSelect('SELECT 1').get();

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: _upgrade,
    // Foreign keys stay off during upgrades so tables can be rebuilt;
    // violations are checked before the upgrade commits instead.
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      _clock = await _loadClock();
    },
  );

  /// Restores this device's clock, creating the device's node ID on first
  /// open.
  Future<HlcClock> _loadClock() async {
    var row = await select(device).getSingleOrNull();
    if (row == null) {
      await into(device).insert(
        DeviceCompanion.insert(id: const Value(1), node: Hlc.generateNode()),
      );
      row = await select(device).getSingle();
    }
    return HlcClock(row.node, last: row.lastHlc, now: _now);
  }

  Future<void> _upgrade(Migrator m, int from, int to) async {
    if (from > to) {
      throw DatabaseTooNewException(found: from, supported: to);
    }
    _log.info('Upgrading database schema from v$from to v$to');
    try {
      if (await backupDirectory?.call() case final directory?) {
        final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;
        final path = p.join(directory.path, 'memuki-v$from-$stamp.sqlite');
        await customStatement('VACUUM INTO ?', [path]);
        _log.info('Backed up database to $path');
      }
      await transaction(() async {
        await upgradeSchema(m, from, to);
        final violations = await customSelect('PRAGMA foreign_key_check').get();
        if (violations.isNotEmpty) {
          throw StateError(
            'Upgrade left ${violations.length} foreign key violations, '
            'first: ${violations.first.data}',
          );
        }
      });
    } catch (error, stackTrace) {
      _log.severe('Database upgrade failed', error, stackTrace);
      throw DatabaseMigrationException(from: from, to: to, cause: error);
    }
  }

  /// Applies the schema changes from version [from] to [to].
  @protected
  @visibleForTesting
  Future<void> upgradeSchema(Migrator m, int from, int to) =>
      m.runMigrationSteps(
        from: from,
        to: to,
        steps: migrationSteps(from1To2: _from1To2),
      );

  /// Adds HLC timestamps and tombstones, the device table, and the outbox.
  /// Existing rows get one initial timestamp. They are not added to the
  /// outbox; the first sync uploads the whole collection.
  Future<void> _from1To2(Migrator m, Schema2 schema) async {
    final node = Hlc.generateNode();
    final initial = Hlc(_now().millisecondsSinceEpoch, 0, node).toString();
    await m.createTable(schema.device);
    await m.createTable(schema.outbox);
    await m.createIndex(schema.outboxHlc);
    await customInsert(
      'INSERT INTO device (id, node, last_hlc) VALUES (1, ?, ?)',
      variables: [Variable.withString(node), Variable.withString(initial)],
    );

    Future<void> addColumns(
      TableInfo<Table, dynamic> table,
      Index hlcIndex, {
      bool tombstones = true,
    }) async {
      final hlc = table.columnsByName['hlc']!;
      await m.alterTable(
        TableMigration(
          table,
          columnTransformer: {hlc: Constant(initial)},
          newColumns: [hlc, if (tombstones) table.columnsByName['deleted']!],
        ),
      );
      await m.createIndex(hlcIndex);
    }

    await addColumns(schema.collections, schema.collectionsHlc);
    await addColumns(schema.decks, schema.decksHlc);
    await addColumns(schema.tags, schema.tagsHlc);
    await addColumns(schema.noteTypes, schema.noteTypesHlc);
    await addColumns(schema.fieldDefinitions, schema.fieldDefinitionsHlc);
    await addColumns(schema.studyCardTemplates, schema.studyCardTemplatesHlc);
    await addColumns(schema.notes, schema.notesHlc);
    await addColumns(schema.noteFields, schema.noteFieldsHlc);
    await addColumns(schema.noteTags, schema.noteTagsHlc);
    await addColumns(schema.studyCards, schema.studyCardsHlc);
    await addColumns(schema.mediaAssets, schema.mediaAssetsHlc);
    await addColumns(
      schema.reviewEvents,
      schema.reviewEventsHlc,
      tombstones: false,
    );
  }
}
