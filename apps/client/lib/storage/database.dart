import 'dart:io';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import '../domain/ids.dart';
import '../domain/note.dart' show SourceKind;
import '../domain/note_type.dart' show FieldType;
import '../domain/preset.dart' show NewCardMix, NewCardOrder, PresetVersion;
import '../domain/review.dart';
import 'converters.dart';
import 'database.steps.dart';
import 'database_exceptions.dart';
import 'history_replay.dart';
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
    Presets,
    PresetVersions,
    ReviewEvents,
    SchedulingStates,
    Device,
    Outbox,
  ],
  include: {'triggers.drift', 'views.drift'},
)
class MemukiDatabase extends _$MemukiDatabase {
  MemukiDatabase(
    super.e, {
    this.backupDirectory,
    this.replayHistory,
    DateTime Function()? now,
    @visibleForTesting this._node,
  }) : _now = now ?? DateTime.now;

  /// Where to write a copy of the database before upgrading it, or null to
  /// skip the copy.
  final Future<Directory> Function()? backupDirectory;

  /// Replays review history for upgrades that derive data from it. Upgrading
  /// a database that has review events from before v7 fails without it.
  final ReplayHistory? replayHistory;

  final DateTime Function() _now;

  /// The node ID for a new device row instead of a random one, so tests can
  /// produce identical timestamps.
  final String? _node;

  late HlcClock _clock;

  /// Issues timestamps for local changes. Available once the database is
  /// open, which every query and transaction ensures.
  HlcClock get clock => _clock;

  @override
  int get schemaVersion => 8;

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
        DeviceCompanion.insert(
          id: const Value(1),
          node: _node ?? Hlc.generateNode(),
        ),
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
        steps: migrationSteps(
          from1To2: _from1To2,
          from2To3: _from2To3,
          from3To4: _from3To4,
          from4To5: _from4To5,
          from5To6: _from5To6,
          from6To7: _from6To7,
          from7To8: _from7To8,
        ),
      );

  /// Adds HLC timestamps and tombstones, the device table, the outbox, the
  /// triggers that guard them, and the views that hide tombstoned rows.
  /// Existing rows get one initial timestamp. They are not added to the
  /// outbox; the first sync uploads the whole collection.
  Future<void> _from1To2(Migrator m, Schema2 schema) async {
    final node = _node ?? Hlc.generateNode();
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

    for (final trigger in [
      schema.collectionsHlcChanges,
      schema.decksHlcChanges,
      schema.tagsHlcChanges,
      schema.noteTypesHlcChanges,
      schema.fieldDefinitionsHlcChanges,
      schema.studyCardTemplatesHlcChanges,
      schema.notesHlcChanges,
      schema.noteFieldsHlcChanges,
      schema.noteTagsHlcChanges,
      schema.studyCardsHlcChanges,
      schema.mediaAssetsHlcChanges,
      schema.reviewEventsAppendOnly,
    ]) {
      await m.createTrigger(trigger);
    }
    // Views that read other views come after them.
    for (final view in [
      schema.visibleCollections,
      schema.visibleDecks,
      schema.visibleTags,
      schema.visibleNoteTypes,
      schema.visibleFieldDefinitions,
      schema.visibleStudyCardTemplates,
      schema.visibleStudyCards,
      schema.visibleNotes,
      schema.visibleNoteFields,
      schema.visibleNoteTags,
    ]) {
      await m.createView(view);
    }
  }

  /// Adds the view that hides tombstoned media.
  Future<void> _from2To3(Migrator m, Schema3 schema) =>
      m.createView(schema.visibleMediaAssets);

  /// Records each review's UTC offset. Existing events predate the column
  /// and get an offset of zero.
  Future<void> _from3To4(Migrator m, Schema4 schema) async {
    final utcOffset = schema.reviewEvents.columnsByName['utc_offset']!;
    await m.alterTable(
      TableMigration(
        schema.reviewEvents,
        columnTransformer: {utcOffset: const Constant(0)},
        newColumns: [utcOffset],
      ),
    );
  }

  /// Adds presets. Each collection gets a "Default" preset with the default
  /// settings, used by all its decks, and existing review events refer to
  /// its version. Study days start at 03:00.
  Future<void> _from4To5(Migrator m, Schema5 schema) async {
    await m.createTable(schema.presets);
    await m.createTable(schema.presetVersions);
    for (final index in [
      schema.presetsCollection,
      schema.presetsHlc,
      schema.presetVersionsHlc,
    ]) {
      await m.createIndex(index);
    }
    for (final trigger in [
      schema.presetsCollectionImmutable,
      schema.presetsHlcChanges,
      schema.presetVersionsAppendOnly,
    ]) {
      await m.createTrigger(trigger);
    }

    // The device row exists unless the database was created without being
    // opened, as in migration tests; it is then created after the upgrade.
    final device = await customSelect('SELECT node, last_hlc FROM device')
        .getSingleOrNull();
    final last = device?.read<String?>('last_hlc');
    final hlc = HlcClock(
      device?.read<String>('node') ?? _node ?? Hlc.generateNode(),
      last: last == null ? null : Hlc.parse(last),
      now: _now,
    ).tick();
    if (device != null) {
      await customUpdate(
        'UPDATE device SET last_hlc = ?',
        variables: [Variable.withString(hlc.toString())],
      );
    }
    // Written as SQL against the v5 schema, so later changes to the tables
    // do not change this step.
    final defaults = PresetVersion(id: PresetVersionId.generate());
    final collections = await customSelect('SELECT id FROM collections').get();
    for (final collection in collections) {
      final id = collection.read<Uint8List>('id');
      final preset = presetIdConverter.toSql(PresetId.generate());
      final version = presetVersionIdConverter.toSql(
        PresetVersionId.generate(),
      );
      await customInsert(
        'INSERT INTO presets (id, collection_id, name, current_version_id, hlc) '
        "VALUES (?, ?, 'Default', ?, ?)",
        variables: [
          Variable.withBlob(preset),
          Variable.withBlob(id),
          Variable.withBlob(version),
          Variable.withString(hlc.toString()),
        ],
      );
      await customInsert(
        'INSERT INTO preset_versions (id, preset_id, scheduler_id, '
        'scheduler_config, burn_threshold_days, leech_threshold, '
        'new_cards_per_day, reviews_per_day, hlc) '
        "VALUES (?, ?, ?, '{}', ?, ?, ?, ?, ?)",
        variables: [
          Variable.withBlob(version),
          Variable.withBlob(preset),
          Variable.withString(defaults.schedulerId),
          Variable.withInt(defaults.burnThreshold!.inDays),
          Variable.withInt(defaults.leechThreshold!),
          Variable.withInt(defaults.newCardsPerDay),
          Variable.withInt(defaults.reviewsPerDay),
          Variable.withString(hlc.toString()),
        ],
      );
    }

    final collectionsTable = schema.collections;
    await m.alterTable(
      TableMigration(
        collectionsTable,
        columnTransformer: {
          collectionsTable.columnsByName['default_preset_id']!:
              const CustomExpression<Uint8List>(
                '(SELECT p.id FROM presets p '
                'WHERE p.collection_id = collections.id)',
              ),
          collectionsTable.columnsByName['day_start']!: const Constant(180),
        },
        newColumns: [
          collectionsTable.columnsByName['default_preset_id']!,
          collectionsTable.columnsByName['day_start']!,
        ],
      ),
    );
    await m.alterTable(
      TableMigration(
        schema.decks,
        newColumns: [schema.decks.columnsByName['preset_id']!],
      ),
    );
    final events = schema.reviewEvents;
    await m.alterTable(
      TableMigration(
        events,
        columnTransformer: {
          events.columnsByName['preset_version_id']!:
              const CustomExpression<Uint8List>(
                '(SELECT p.current_version_id FROM presets p '
                'JOIN study_cards c ON c.collection_id = p.collection_id '
                'WHERE c.id = review_events.study_card_id)',
              ),
        },
        newColumns: [events.columnsByName['preset_version_id']!],
      ),
    );
    await m.createView(schema.visiblePresets);
  }

  /// Adds the new-card order settings to presets. Existing versions mix new
  /// cards among reviews and introduce them in creation order.
  Future<void> _from5To6(Migrator m, Schema6 schema) async {
    final versions = schema.presetVersions;
    final mix = versions.columnsByName['new_card_mix']!;
    final order = versions.columnsByName['new_card_order']!;
    await m.alterTable(
      TableMigration(
        versions,
        columnTransformer: {
          mix: const Constant('mixed'),
          order: const Constant('created'),
        },
        newColumns: [mix, order],
      ),
    );
  }

  /// Records the state each review event found its card in, computed by
  /// replaying every card's history with [replayHistory]. Events whose
  /// preset version is unknown are replayed with the collection's default
  /// preset.
  Future<void> _from6To7(Migrator m, Schema7 schema) async {
    final states = await _statesBefore();
    await customStatement(
      'CREATE TEMP TABLE state_before '
      '(event_id BLOB PRIMARY KEY, state TEXT NOT NULL)',
    );
    for (final MapEntry(key: id, value: state) in states.entries) {
      await customInsert(
        'INSERT INTO state_before (event_id, state) VALUES (?, ?)',
        variables: [
          Variable.withBlob(reviewEventIdConverter.toSql(id)),
          Variable.withString(state.name),
        ],
      );
    }
    final events = schema.reviewEvents;
    final stateBefore = events.columnsByName['state_before']!;
    // An event without a computed state fails the NOT NULL constraint, so
    // the upgrade rolls back.
    await m.alterTable(
      TableMigration(
        events,
        columnTransformer: {
          stateBefore: const CustomExpression<String>(
            '(SELECT s.state FROM state_before s '
            'WHERE s.event_id = review_events.id)',
          ),
        },
        newColumns: [stateBefore],
      ),
    );
    await customStatement('DROP TABLE state_before');
  }

  /// Adds suspending and burying of cards, and the sibling burying settings
  /// of presets. No card is suspended or buried, and existing preset
  /// versions bury both new and review siblings.
  Future<void> _from7To8(Migrator m, Schema8 schema) async {
    await m.addColumn(schema.studyCards, schema.studyCards.suspended);
    await m.addColumn(schema.studyCards, schema.studyCards.buriedUntil);
    await m.addColumn(
      schema.presetVersions,
      schema.presetVersions.buryNewSiblings,
    );
    await m.addColumn(
      schema.presetVersions,
      schema.presetVersions.buryReviewSiblings,
    );
  }

  /// The state before each review event, by replaying each card's history.
  /// Read as SQL against the v6 schema, so later changes to the tables do
  /// not change this step.
  Future<Map<ReviewEventId, StudyCardState>> _statesBefore() async {
    final rows = await customSelect(
      'SELECT e.*, c.collection_id FROM review_events e '
      'JOIN study_cards c ON c.id = e.study_card_id '
      'ORDER BY e.study_card_id, e.at, e.id',
    ).get();
    if (rows.isEmpty) return const {};
    final replay = replayHistory;
    if (replay == null) {
      throw StateError('Upgrading review history needs a replay function');
    }

    final versions = <PresetVersionId, PresetVersion>{
      for (final row in await customSelect(
        'SELECT * FROM preset_versions',
      ).get())
        presetVersionIdConverter.fromSql(row.read('id')): PresetVersion(
          id: presetVersionIdConverter.fromSql(row.read('id')),
          schedulerId: row.read('scheduler_id'),
          schedulerConfig: const JsonMapConverter().fromSql(
            row.read('scheduler_config'),
          ),
          burnThreshold: switch (row.read<int?>('burn_threshold_days')) {
            final days? => Duration(days: days),
            null => null,
          },
          leechThreshold: row.read('leech_threshold'),
          newCardsPerDay: row.read('new_cards_per_day'),
          reviewsPerDay: row.read('reviews_per_day'),
          newCardMix: NewCardMix.values.byName(row.read('new_card_mix')),
          newCardOrder: NewCardOrder.values.byName(row.read('new_card_order')),
        ),
    };
    final collections = {
      for (final row in await customSelect(
        'SELECT c.id, c.day_start, p.current_version_id FROM collections c '
        'JOIN presets p ON p.id = c.default_preset_id',
      ).get())
        collectionIdConverter.fromSql(row.read('id')): (
          dayStart: Duration(minutes: row.read('day_start')),
          fallback:
              versions[presetVersionIdConverter.fromSql(
                row.read('current_version_id'),
              )]!,
        ),
    };

    final histories = <StudyCardId, (CollectionId, List<ReviewEvent>)>{};
    for (final row in rows) {
      final cardId = studyCardIdConverter.fromSql(row.read('study_card_id'));
      DateTime? time(String column) => switch (row.read<int?>(column)) {
        final millis? => const UtcMillisConverter().fromSql(millis),
        null => null,
      };
      final event = ReviewEvent(
        id: reviewEventIdConverter.fromSql(row.read('id')),
        studyCardId: cardId,
        kind: ReviewEventKind.values.byName(row.read('kind')),
        at: time('at')!,
        utcOffset: const DurationMinutesConverter().fromSql(
          row.read('utc_offset'),
        ),
        // Not read by the replay.
        stateBefore: StudyCardState.newCard,
        grade: switch (row.read<String?>('grade')) {
          final grade? => Grade.values.byName(grade),
          null => null,
        },
        responseTime: switch (row.read<int?>('response_time')) {
          final millis? => const DurationMillisConverter().fromSql(millis),
          null => null,
        },
        dueBefore: time('due_before'),
        dueAfter: time('due_after'),
        undoneEventId: switch (row.read<Uint8List?>('undone_event_id')) {
          final id? => reviewEventIdConverter.fromSql(id),
          null => null,
        },
        schedulerId: row.read('scheduler_id'),
        schedulerVersion: row.read('scheduler_version'),
        presetVersionId: presetVersionIdConverter.fromSql(
          row.read('preset_version_id'),
        ),
      );
      final collectionId = collectionIdConverter.fromSql(
        row.read('collection_id'),
      );
      (histories[cardId] ??= (collectionId, [])).$2.add(event);
    }

    final states = <ReviewEventId, StudyCardState>{};
    for (final (collectionId, events) in histories.values) {
      final collection = collections[collectionId]!;
      states.addAll(
        replay(
          HistoryToReplay(
            events: events,
            versions: versions,
            fallback: collection.fallback,
            dayStart: collection.dayStart,
          ),
        ),
      );
    }
    return states;
  }
}
