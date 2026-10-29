import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:drift/drift.dart';
import 'package:memuki/domain/collection.dart';
import 'package:memuki/domain/ids.dart';
import 'package:memuki/domain/note.dart';
import 'package:memuki/domain/note_type.dart';
import 'package:memuki/domain/study_card.dart';

import 'runner.dart';
import 'session.dart';

List<Command<void>> inspectCommands() => [
  ActionCommand(
    'info',
    'Show the schema version, clock, and row counts.',
    (_, s) => _info(s),
  ),
  ActionCommand(
    'collections',
    'List collections with their sizes.',
    (_, s) => _collections(s),
  ),
  ActionCommand(
    'tree',
    'Show the decks, tags, and note types of collections.',
    (c, s) async {
      final rest = c.argsFrom(0);
      final ids = rest.isEmpty
          ? [for (final c in await s.repos.collections.collections()) c.id]
          : [CollectionId.parse(await s.resolve('collections', rest.first))];
      for (final id in ids) {
        await _tree(s, id);
      }
    },
    arguments: '[collection]',
  ),
  ActionCommand(
    'notes',
    'List notes with their fields and tags.',
    _notes,
    options: (p) => p
      ..addOption('collection', abbr: 'c')
      ..addOption('deck', abbr: 'd', help: 'Notes with a card in this deck.')
      ..addOption('tag', abbr: 't', help: 'Notes with this tag or below.')
      ..addOption('limit', defaultsTo: '50'),
  ),
  ActionCommand(
    'cards',
    'List cards with their deck and scheduling state.',
    _cards,
    options: (p) => p
      ..addOption('deck', abbr: 'd', help: 'Cards in this deck and below.')
      ..addOption('note', abbr: 'n')
      ..addOption('limit', defaultsTo: '50'),
  ),
  ActionCommand(
    'show',
    'Show any entity by ID (or the end of its ID) or name.',
    (c, s) async {
      final (table, id) = await s.find(c.arg(0, 'id'));
      await _show(s, table, id);
    },
    arguments: '<id>',
  ),
  ActionCommand(
    'outbox',
    'List changes waiting to be synced, newest first.',
    _outbox,
    options: (p) => p.addOption('limit', defaultsTo: '50'),
  ),
  ActionCommand(
    'check',
    'Check database integrity and media files.',
    (_, s) => _check(s),
  ),
];

/// Synced tables and the view and key columns that decide visibility.
const _visibility = {
  'collections': ('visible_collections', ['id']),
  'decks': ('visible_decks', ['id']),
  'tags': ('visible_tags', ['id']),
  'note_types': ('visible_note_types', ['id']),
  'field_definitions': ('visible_field_definitions', ['id']),
  'study_card_templates': ('visible_study_card_templates', ['id']),
  'notes': ('visible_notes', ['id']),
  'study_cards': ('visible_study_cards', ['id']),
  'note_fields': ('visible_note_fields', ['note_id', 'field_id']),
  'note_tags': ('visible_note_tags', ['note_id', 'tag_id']),
  'media_assets': ('visible_media_assets', ['collection_id', 'hash']),
};

Future<int> _count(Session s, String sql, [List<Variable> vars = const []]) => s
    .db
    .customSelect(sql, variables: vars)
    .getSingle()
    .then((r) => r.data.values.single as int);

/// Counts per ID from a query selecting `id` (a blob) and `n`.
Future<Map<String, int>> _countsBy(Session s, String sql) async => {
  for (final row in await s.db.customSelect(sql).get())
    uuidOf(row.read<Uint8List>('id')): row.read<int>('n'),
};

Future<void> _info(Session s) async {
  final version = await _count(s, 'PRAGMA user_version');
  final device = await s.db.select(s.db.device).getSingle();
  final files = s.mediaDir.existsSync()
      ? s.mediaDir.listSync(recursive: true).whereType<File>().length
      : 0;
  s.out
    ..writeln('database  ${s.dbFile.path}')
    ..writeln('media     ${s.mediaDir.path} ($files files)')
    ..writeln('schema    v$version')
    ..writeln('node      ${device.node}')
    ..writeln('last hlc  ${device.lastHlc}')
    ..writeln();
  final rows = <List<Object?>>[];
  for (final table in s.db.allTables) {
    final name = table.actualTableName;
    final total = await _count(s, 'SELECT count(*) FROM $name');
    final visibility = _visibility[name];
    if (visibility == null) {
      rows.add([name, total, '', '']);
      continue;
    }
    final (view, keys) = visibility;
    final deleted = await _count(
      s,
      'SELECT count(*) FROM $name WHERE deleted = 1',
    );
    final match = keys.map((k) => 'v.$k = t.$k').join(' AND ');
    final hidden = await _count(
      s,
      'SELECT count(*) FROM $name t WHERE t.deleted = 0 '
      'AND NOT EXISTS (SELECT 1 FROM $view v WHERE $match)',
    );
    rows.add([name, total - deleted - hidden, deleted, hidden]);
  }
  s.table(['table', 'visible', 'deleted', 'hidden'], rows);
  s.out
    ..writeln()
    ..writeln('deleted: tombstoned rows.')
    ..writeln('hidden:  live rows under a deleted parent (see views.drift).');
}

Future<void> _collections(Session s) async {
  final decks = await _countsBy(
    s,
    'SELECT collection_id AS id, count(*) AS n FROM decks d '
    'WHERE EXISTS (SELECT 1 FROM visible_decks v WHERE v.id = d.id) '
    'GROUP BY collection_id',
  );
  final notes = await _countsBy(
    s,
    'SELECT collection_id AS id, count(*) AS n FROM notes n '
    'WHERE EXISTS (SELECT 1 FROM visible_notes v WHERE v.id = n.id) '
    'GROUP BY collection_id',
  );
  final cards = await _countsBy(
    s,
    'SELECT collection_id AS id, count(*) AS n FROM study_cards c '
    'WHERE EXISTS (SELECT 1 FROM visible_study_cards v WHERE v.id = c.id) '
    'GROUP BY collection_id',
  );
  s.table(
    ['id', 'name', 'decks', 'notes', 'cards'],
    [
      for (final c in await s.repos.collections.collections())
        [
          short(c.id),
          c.name,
          decks[c.id] ?? 0,
          notes[c.id] ?? 0,
          cards[c.id] ?? 0,
        ],
    ],
  );
}

Future<void> _tree(Session s, CollectionId id) async {
  final collection = (await s.repos.collections.collection(id))!;
  s.out.writeln('${collection.name}  (${short(id)})');

  final cardCounts = await _countsBy(
    s,
    'SELECT deck_id AS id, count(*) AS n FROM study_cards c '
    'WHERE EXISTS (SELECT 1 FROM visible_study_cards v WHERE v.id = c.id) '
    'GROUP BY deck_id',
  );
  final decks = await s.repos.collections.decks(id);
  s.out.writeln('  decks');
  _printTree<Deck>(
    s,
    decks,
    parentOf: (d) => d.parentId,
    idOf: (d) => d.id,
    label: (d) => '${d.name}  ${cardCounts[d.id] ?? 0} cards  (${short(d.id)})',
  );

  final noteCounts = await _countsBy(
    s,
    'SELECT tag_id AS id, count(*) AS n FROM visible_note_tags GROUP BY tag_id',
  );
  final tags = await s.repos.tags.tags(id);
  s.out.writeln('  tags');
  _printTree<Tag>(
    s,
    tags,
    parentOf: (t) => t.parentId,
    idOf: (t) => t.id,
    label: (t) => '${t.name}  ${noteCounts[t.id] ?? 0} notes  (${short(t.id)})',
  );

  final typeCounts = await _countsBy(
    s,
    'SELECT note_type_id AS id, count(*) AS n FROM notes n '
    'WHERE EXISTS (SELECT 1 FROM visible_notes v WHERE v.id = n.id) '
    'GROUP BY note_type_id',
  );
  s.out.writeln('  note types');
  for (final t in await s.repos.noteTypes.noteTypes(id)) {
    s.out.writeln(
      '    ${t.name}  ${typeCounts[t.id] ?? 0} notes  '
      'fields: ${t.fields.map((f) => f.name).join(', ')}  '
      'templates: ${t.templates.map((t) => t.name).join(', ')}  '
      '(${short(t.id)})',
    );
  }
  s.out.writeln();
}

void _printTree<T>(
  Session s,
  List<T> items, {
  required Object? Function(T) parentOf,
  required Object Function(T) idOf,
  required String Function(T) label,
}) {
  if (items.isEmpty) s.out.writeln('    (none)');
  void walk(Object? parent, int depth) {
    for (final item in items.where((i) => parentOf(i) == parent)) {
      s.out.writeln('${'  ' * (depth + 2)}${label(item)}');
      walk(idOf(item), depth + 1);
    }
  }

  walk(null, 0);
}

/// Note types by ID, for field names and order.
Future<Map<NoteTypeId, NoteType>> _noteTypes(
  Session s,
  CollectionId collection,
) async => {
  for (final t in await s.repos.noteTypes.noteTypes(collection)) t.id: t,
};

/// A note's field values in field order.
String _fields(Note note, NoteType? type) =>
    (type?.fields.map((f) => note.fields[f.id] ?? '') ?? note.fields.values)
        .join(' · ');

Future<void> _notes(ActionCommand c, Session s) async {
  final limit = int.parse(c.option('limit')!);
  List<Note> notes;
  if (c.option('deck') case final deck?) {
    final deckId = DeckId.parse(await s.resolve('decks', deck));
    final cards = await s.repos.cards.cardsInDeck(
      deckId,
      includeSubdecks: true,
    );
    final ids = {for (final card in cards) card.noteId};
    notes = [for (final id in ids) ?await s.repos.notes.note(id)];
  } else if (c.option('tag') case final tag?) {
    notes = await s.repos.notes.notesWithTag(
      TagId.parse(await s.resolve('tags', tag)),
    );
  } else {
    final collections = c.option('collection') == null
        ? [for (final c in await s.repos.collections.collections()) c.id]
        : [
            CollectionId.parse(
              await s.resolve('collections', c.option('collection')!),
            ),
          ];
    notes = [for (final id in collections) ...await s.repos.notes.notes(id)];
  }

  final types = <NoteTypeId, NoteType>{};
  final tagNames = <TagId, String>{};
  for (final collection in {for (final n in notes) n.collectionId}) {
    types.addAll(await _noteTypes(s, collection));
    for (final t in await s.repos.tags.tags(collection)) {
      tagNames[t.id] = t.name;
    }
  }
  final rows = <List<Object?>>[];
  for (final note in notes.take(limit)) {
    final tags = await s.repos.notes.tagIds(note.id);
    rows.add([
      short(note.id),
      _fields(note, types[note.noteTypeId]),
      tags.map((t) => tagNames[t] ?? short(t)).join(', '),
    ]);
  }
  s.table(['id', 'fields', 'tags'], rows);
  if (notes.length > limit) {
    s.out.writeln('… ${notes.length - limit} more (use --limit)');
  }
}

Future<void> _cards(ActionCommand c, Session s) async {
  final limit = int.parse(c.option('limit')!);
  final List<StudyCard> cards;
  if (c.option('note') case final note?) {
    cards = await s.repos.cards.cardsOfNote(
      NoteId.parse(await s.resolve('notes', note)),
    );
  } else if (c.option('deck') case final deck?) {
    cards = await s.repos.cards.cardsInDeck(
      DeckId.parse(await s.resolve('decks', deck)),
      includeSubdecks: true,
    );
  } else {
    throw UsageException('Pass --deck or --note.', c.usage);
  }
  final rows = <List<Object?>>[];
  for (final card in cards.take(limit)) {
    rows.add(await _cardRow(s, card.id));
  }
  s.table(_cardHeaders, rows);
  if (cards.length > limit) {
    s.out.writeln('… ${cards.length - limit} more (use --limit)');
  }
}

/// A row for the card tables, read straight from the database so hidden and
/// deleted cards show too.
Future<List<Object?>> _cardRow(Session s, StudyCardId id) async {
  final row = await s.db
      .customSelect(
        'SELECT c.deleted, '
        'EXISTS (SELECT 1 FROM visible_study_cards v WHERE v.id = c.id) '
        '  AS visible, '
        '(SELECT v.value FROM note_fields v '
        '  JOIN field_definitions f ON f.id = v.field_id '
        '  WHERE v.note_id = c.note_id AND v.deleted = 0 '
        '  ORDER BY f.position LIMIT 1) AS front, '
        '(SELECT name FROM study_card_templates t WHERE t.id = c.template_id) '
        '  AS template, '
        '(SELECT name FROM decks d WHERE d.id = c.deck_id) AS deck, '
        's.state, s.due, '
        '(SELECT count(*) FROM review_events e WHERE e.study_card_id = c.id) '
        '  AS reviews '
        'FROM study_cards c '
        'LEFT JOIN scheduling_states s ON s.study_card_id = c.id '
        'WHERE c.id = ?',
        variables: [Variable.withBlob(bytesOf(id.value))],
      )
      .getSingle();
  final due = row.data['due'] as int?;
  return [
    short(id),
    row.data['front'],
    row.data['template'],
    row.data['deck'],
    row.data['state'],
    due == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            due,
            isUtc: true,
          ).toIso8601String(),
    row.data['reviews'],
    row.read<bool>('deleted')
        ? 'deleted'
        : row.read<bool>('visible')
        ? ''
        : 'hidden',
  ];
}

/// Rows for every card matching [where], hidden and deleted ones included.
Future<List<List<Object?>>> _rawCards(
  Session s,
  String where,
  String id,
) async => [
  for (final r
      in await s.db
          .customSelect(
            'SELECT id FROM study_cards WHERE $where = ? ORDER BY id',
            variables: [Variable.withBlob(bytesOf(id))],
          )
          .get())
    await _cardRow(s, StudyCardId.parse(uuidOf(r.read<Uint8List>('id')))),
];

/// Whether a row is live, tombstoned, or hidden by a deleted parent.
Future<String> _status(Session s, String table, String id) async {
  final key = Variable.withBlob(bytesOf(id));
  final row = await s.db
      .customSelect('SELECT * FROM $table WHERE id = ?', variables: [key])
      .getSingle();
  final hlc = row.data['hlc'];
  if (!row.data.containsKey('deleted')) return 'kept  hlc $hlc';
  if (row.read<bool>('deleted')) return 'deleted  hlc $hlc';
  final (view, _) = _visibility[table]!;
  final visible = await _count(s, 'SELECT count(*) FROM $view WHERE id = ?', [
    key,
  ]);
  return visible == 1
      ? 'live  hlc $hlc'
      : 'hidden (a parent is deleted)  hlc $hlc';
}

Future<void> _show(Session s, String table, String id) async {
  final out = s.out
    ..writeln('$table  $id')
    ..writeln('status  ${await _status(s, table, id)}');
  final key = Variable.withBlob(bytesOf(id));
  switch (table) {
    case 'collections':
      await _tree(s, CollectionId.parse(id));
    case 'decks' || 'tags':
      final row = await s.db
          .customSelect('SELECT * FROM $table WHERE id = ?', variables: [key])
          .getSingle();
      final parent = row.data['parent_id'] as Uint8List?;
      out
        ..writeln('name    ${row.read<String>('name')}')
        ..writeln('parent  ${parent == null ? '(none)' : uuidOf(parent)}');
      if (table == 'decks') {
        _printCards(s, await _rawCards(s, 'deck_id', id));
      }
    case 'note_types':
      final type = await s.repos.noteTypes.noteType(NoteTypeId.parse(id));
      if (type != null) {
        out
          ..writeln('name       ${type.name}')
          ..writeln('fields     ${type.fields.map((f) => f.name).join(', ')}')
          ..writeln(
            'templates  ${type.templates.map((t) => t.name).join(', ')}',
          );
      }
    case 'notes':
      await _showNote(s, NoteId.parse(id), key);
    case 'study_cards':
      await _showCard(s, id, key);
    default:
      final row = await s.db
          .customSelect('SELECT * FROM $table WHERE id = ?', variables: [key])
          .getSingle();
      for (final MapEntry(:key, :value) in row.data.entries) {
        out.writeln(
          '$key  ${value is Uint8List && value.length == 16 ? uuidOf(value) : value}',
        );
      }
  }
}

void _printCards(Session s, List<List<Object?>> rows) {
  s.out.writeln('cards (${rows.length})');
  s.table(_cardHeaders, rows);
}

const _cardHeaders = [
  'id',
  'note',
  'template',
  'deck',
  'state',
  'due',
  'reviews',
  'status',
];

Future<void> _showNote(Session s, NoteId id, Variable key) async {
  final row = await s.db
      .customSelect('SELECT * FROM notes WHERE id = ?', variables: [key])
      .getSingle();
  final type = await s.repos.noteTypes.noteType(
    NoteTypeId.parse(uuidOf(row.read<Uint8List>('note_type_id'))),
  );
  s.out.writeln('type    ${type?.name ?? '(hidden)'}');
  if (row.data['source_kind'] case final kind?) {
    s.out.writeln('source  $kind ${row.data['source_reference'] ?? ''}');
  }
  final fields = await s.db
      .customSelect(
        'SELECT f.name, v.value, v.deleted, v.hlc FROM note_fields v '
        'JOIN field_definitions f ON f.id = v.field_id '
        'WHERE v.note_id = ? ORDER BY f.position',
        variables: [key],
      )
      .get();
  s.out.writeln('fields');
  s.table(
    ['', 'name', 'value', 'hlc'],
    [
      for (final f in fields)
        [
          f.read<bool>('deleted') ? '  x' : '   ',
          f.read<String>('name'),
          f.read<String>('value'),
          f.read<String>('hlc'),
        ],
    ],
  );
  final tags = await s.db
      .customSelect(
        'SELECT t.name FROM visible_note_tags l JOIN tags t ON t.id = l.tag_id '
        'WHERE l.note_id = ? ORDER BY t.name',
        variables: [key],
      )
      .get();
  s.out.writeln(
    'tags    ${tags.map((t) => t.read<String>('name')).join(', ')}',
  );
  _printCards(s, await _rawCards(s, 'note_id', '$id'));
}

Future<void> _showCard(Session s, String id, Variable key) async {
  final row = await s.db
      .customSelect('SELECT * FROM study_cards WHERE id = ?', variables: [key])
      .getSingle();
  final cardId = StudyCardId.parse(id);
  s.out
    ..writeln('note    ${uuidOf(row.read<Uint8List>('note_id'))}')
    ..writeln('deck    ${uuidOf(row.read<Uint8List>('deck_id'))}');
  if (await s.repos.cards.schedulingState(cardId) case final state?) {
    s.out.writeln(
      'state   ${state.state.name}  due ${state.due?.toIso8601String() ?? '-'}'
      '  interval ${state.interval.inDays}d  ease ${state.ease ?? '-'}'
      '  reviews ${state.reviewCount}  lapses ${state.lapses}',
    );
  }
  final history = await s.repos.reviews.history(cardId);
  s.out.writeln('history (${history.length})');
  s.table(
    ['at', 'kind', 'grade', 'time', 'id'],
    [
      for (final e in history)
        [
          e.at.toIso8601String(),
          e.kind.name,
          e.grade?.name ?? '',
          e.responseTime == null ? '' : '${e.responseTime!.inMilliseconds}ms',
          short(e.id),
        ],
    ],
  );
}

Future<void> _outbox(ActionCommand c, Session s) async {
  final rows = await s.db
      .customSelect(
        'SELECT * FROM outbox ORDER BY hlc DESC LIMIT ?',
        variables: [Variable.withInt(int.parse(c.option('limit')!))],
      )
      .get();
  final total = await _count(s, 'SELECT count(*) FROM outbox');
  s.table(
    ['hlc', 'table', 'key', 'collection'],
    [
      for (final r in rows)
        [
          r.read<String>('hlc'),
          r.read<String>('entity_table'),
          switch (r.read<Uint8List>('entity_key')) {
            final key when key.length == 16 => uuidOf(key),
            final key =>
              key.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
          },
          short(uuidOf(r.read<Uint8List>('collection_id'))),
        ],
    ],
  );
  s.out.writeln('$total entries');
}

Future<void> _check(Session s) async {
  var problems = 0;
  void report(String message) {
    problems++;
    s.out.writeln('✗ $message');
  }

  final integrity = await s.db.customSelect('PRAGMA integrity_check').get();
  final result = integrity.map((r) => r.data.values.single).join('; ');
  result == 'ok'
      ? s.out.writeln('✓ integrity_check')
      : report('integrity_check: $result');

  final fk = await s.db.customSelect('PRAGMA foreign_key_check').get();
  fk.isEmpty
      ? s.out.writeln('✓ foreign keys')
      : report('${fk.length} foreign key violations, e.g. ${fk.first.data}');

  final assets = await s.db
      .customSelect('SELECT collection_id, hash FROM media_assets')
      .get();
  var missing = 0;
  final known = <String>{};
  for (final a in assets) {
    final collection = CollectionId.parse(
      uuidOf(a.read<Uint8List>('collection_id')),
    );
    final hash = ContentHash.parse(
      a
          .read<Uint8List>('hash')
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(),
    );
    final file = s.store.file(collection, hash);
    known.add(file.path);
    if (!file.existsSync()) missing++;
  }
  missing == 0
      ? s.out.writeln('✓ media rows have files (${assets.length})')
      : report('$missing media rows have no file');

  final orphans = s.mediaDir.existsSync()
      ? s.mediaDir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => !f.path.contains('/.tmp/'))
            .where((f) => !known.contains(f.path))
            .length
      : 0;
  // Files without rows are expected after an interrupted add; they are
  // cleaned up with tombstones in Phase 8.
  s.out.writeln(
    orphans == 0
        ? '✓ no media files without rows'
        : '• $orphans media files without rows (harmless)',
  );

  s.out.writeln(
    problems == 0 ? '\nNo problems found.' : '\n$problems problems.',
  );
}
