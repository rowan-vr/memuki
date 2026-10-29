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
import 'database_exceptions.dart';
import 'tables.dart';

part 'database.g.dart';

final _log = Logger('memuki.storage');

/// The local database holding all collections.
///
/// Schema changes increase [schemaVersion] and add a step to [upgradeSchema].
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
  ],
  include: {'triggers.drift'},
)
class MemukiDatabase extends _$MemukiDatabase {
  MemukiDatabase(super.e, {this.backupDirectory});

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

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: _upgrade,
    // Foreign keys stay off during upgrades so tables can be rebuilt;
    // violations are checked before the upgrade commits instead.
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );

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
  Future<void> upgradeSchema(Migrator m, int from, int to) async {
    // v1 is the first schema; there is nothing to upgrade from yet.
    throw StateError('No upgrade from v$from to v$to');
  }
}
