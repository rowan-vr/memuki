import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db.dart';

typedef Log = void Function(String message);
typedef BankLoader = Future<String> Function(int bank);

const _uuid = Uuid();

Uint8List newId() => Uint8List.fromList(Uuid.parse(_uuid.v7()));

/// Minimal hybrid logical clock; enough to give realistic column contents.
class Hlc {
  int _millis = 0;
  int _counter = 0;

  String next() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > _millis) {
      _millis = now;
      _counter = 0;
    } else {
      _counter++;
    }
    return '${_millis.toString().padLeft(15, '0')}:'
        '${_counter.toRadixString(16).padLeft(4, '0')}:spike';
  }
}

class _RollbackProbe implements Exception {}

Future<T> _timed<T>(
  Map<String, Object?> out,
  String key,
  Future<T> Function() body,
) async {
  final sw = Stopwatch()..start();
  final result = await body();
  out[key] = sw.elapsedMilliseconds;
  return result;
}

Future<int> _count(GeneratedDatabase db, String table) async {
  final row = await db.customSelect('SELECT count(*) AS c FROM $table').getSingle();
  return row.read<int>('c');
}

Future<int> dbBytes(GeneratedDatabase db) async {
  final pages = await db.customSelect('PRAGMA page_count').getSingle();
  final size = await db.customSelect('PRAGMA page_size').getSingle();
  return (pages.data.values.first as int) * (size.data.values.first as int);
}

Future<Map<String, Object?>> featureChecks(GeneratedDatabase db) async {
  final out = <String, Object?>{};
  final version = await db.customSelect('SELECT sqlite_version() AS v').getSingle();
  out['sqliteVersion'] = version.read<String>('v');
  try {
    await db.customStatement(
      "CREATE VIRTUAL TABLE temp.fts_probe USING fts5(x, tokenize='trigram')",
    );
    await db.customStatement('DROP TABLE temp.fts_probe');
    out['fts5Trigram'] = true;
  } catch (e) {
    out['fts5Trigram'] = false;
    out['fts5Error'] = '$e';
  }
  return out;
}

/// Writes a study-sized collection: notes, cards, review events and outbox
/// entries, in one transaction per batch.
Future<Map<String, Object?>> appWrites(
  AppDb db, {
  int notes = 10000,
  int reviewsPerCard = 3,
  int batch = 1000,
}) async {
  final out = <String, Object?>{};
  final hlc = Hlc();
  final rnd = Random(42);
  final collectionId = newId();
  final noteTypeId = newId();
  final templates = [newId(), newId()];
  final decks = <Uint8List>[];

  await db.transaction(() async {
    await db.into(db.collections).insert(
      CollectionsCompanion.insert(id: collectionId, name: 'Spike', hlc: hlc.next()),
    );
    await db.into(db.noteTypes).insert(
      NoteTypesCompanion.insert(
        id: noteTypeId,
        collectionId: collectionId,
        name: 'Vocab',
        hlc: hlc.next(),
      ),
    );
    Uint8List? parent;
    for (var i = 0; i < 10; i++) {
      final id = newId();
      await db.into(db.decks).insert(
        DecksCompanion.insert(
          id: id,
          collectionId: collectionId,
          parentId: Value(i.isEven ? null : parent),
          name: 'Deck $i',
          hlc: hlc.next(),
        ),
      );
      if (i.isEven) parent = id;
      decks.add(id);
    }
  });

  final sw = Stopwatch()..start();
  for (var start = 0; start < notes; start += batch) {
    await db.transaction(() async {
      await db.batch((b) {
        for (var n = start; n < min(start + batch, notes); n++) {
          final noteId = newId();
          final fields = jsonEncode({'front': '単語$n', 'back': 'word $n'});
          b.insert(
            db.notes,
            NotesCompanion.insert(
              id: noteId,
              collectionId: collectionId,
              noteTypeId: noteTypeId,
              fields: fields,
              hlc: hlc.next(),
            ),
          );
          b.insert(
            db.outbox,
            OutboxCompanion.insert(
              entityType: 'note',
              entityId: noteId,
              hlc: hlc.next(),
              payload: fields,
            ),
          );
          for (final template in templates) {
            final cardId = newId();
            b.insert(
              db.cards,
              CardsCompanion.insert(
                id: cardId,
                noteId: noteId,
                templateId: template,
                deckId: decks[n % decks.length],
                hlc: hlc.next(),
              ),
            );
            for (var r = 0; r < reviewsPerCard; r++) {
              b.insert(
                db.reviewEvents,
                ReviewEventsCompanion.insert(
                  id: newId(),
                  cardId: cardId,
                  grade: 1 + rnd.nextInt(4),
                  reviewedAt: DateTime.now().millisecondsSinceEpoch,
                  hlc: hlc.next(),
                ),
              );
            }
          }
        }
      });
    });
  }
  out['writeMs'] = sw.elapsedMilliseconds;
  out['notes'] = await _count(db, 'notes');
  out['cards'] = await _count(db, 'cards');
  out['reviewEvents'] = await _count(db, 'review_events');
  out['outbox'] = await _count(db, 'outbox');

  // A subtree query over nested decks, as the deck list will need.
  await _timed(out, 'deckSubtreeCountMs', () async {
    await db.customSelect(
      'WITH RECURSIVE tree(id) AS (SELECT id FROM decks WHERE parent_id IS NULL '
      'UNION ALL SELECT d.id FROM decks d JOIN tree t ON d.parent_id = t.id) '
      'SELECT count(*) FROM cards WHERE deck_id IN (SELECT id FROM tree)',
    ).get();
  });

  // A transaction that fails part-way must leave nothing behind.
  final before = await _count(db, 'notes');
  try {
    await db.transaction(() async {
      for (var i = 0; i < 100; i++) {
        await db.into(db.notes).insert(
          NotesCompanion.insert(
            id: newId(),
            collectionId: collectionId,
            noteTypeId: noteTypeId,
            fields: '{}',
            hlc: hlc.next(),
          ),
        );
      }
      throw _RollbackProbe();
    });
  } on _RollbackProbe {
    // expected
  }
  out['rollbackLeftNoRows'] = await _count(db, 'notes') == before;
  return out;
}

/// Collects the plain-text glossary strings from Yomitan structured content.
void _collectGloss(Object? node, List<String> into, {bool inGlossary = false}) {
  if (node is String) {
    if (inGlossary) into.add(node);
  } else if (node is List) {
    for (final child in node) {
      _collectGloss(child, into, inGlossary: inGlossary);
    }
  } else if (node is Map) {
    final data = node['data'];
    final glossary =
        inGlossary || (data is Map && data['content'] == 'glossary');
    _collectGloss(node['content'], into, inGlossary: glossary);
  }
}

String glossText(List<Object?> definitions) {
  final parts = <String>[];
  for (final d in definitions) {
    if (d is String) {
      parts.add(d);
    } else {
      _collectGloss(d, parts);
    }
  }
  return parts.join('; ');
}

/// Imports Jitendex term banks, then builds the trigram index.
Future<Map<String, Object?>> dictImport(
  DictDb db,
  BankLoader load,
  int bankCount, {
  required bool storeContent,
  Log? log,
}) async {
  final out = <String, Object?>{};
  var fetchMs = 0;
  var parseMs = 0;
  var insertMs = 0;
  final sw = Stopwatch();
  for (var bank = 1; bank <= bankCount; bank++) {
    sw
      ..reset()
      ..start();
    final text = await load(bank);
    fetchMs += sw.elapsedMilliseconds;

    sw
      ..reset()
      ..start();
    final rows = (jsonDecode(text) as List).cast<List<Object?>>();
    final companions = [
      for (final e in rows)
        DictEntriesCompanion.insert(
          expression: e[0] as String,
          reading: e[1] as String,
          score: e[4] as int,
          gloss: glossText(e[5] as List<Object?>),
          content: Value(storeContent ? jsonEncode(e[5]) : null),
          sequence: e[6] as int,
        ),
    ];
    parseMs += sw.elapsedMilliseconds;

    sw
      ..reset()
      ..start();
    await db.batch((b) => b.insertAll(db.dictEntries, companions));
    insertMs += sw.elapsedMilliseconds;
    if (bank % 20 == 0) log?.call('dict bank $bank/$bankCount');
  }
  out['fetchMs'] = fetchMs;
  out['parseMs'] = parseMs;
  out['insertMs'] = insertMs;
  await _timed(out, 'ftsRebuildMs', () async {
    await db.customStatement("INSERT INTO dict_fts(dict_fts) VALUES('rebuild')");
  });
  out['entries'] = await _count(db, 'dict_entries');
  return out;
}

Future<double> _medianMs(Future<void> Function() body, {int runs = 5}) async {
  final times = <int>[];
  for (var i = 0; i < runs; i++) {
    final sw = Stopwatch()..start();
    await body();
    times.add(sw.elapsedMicroseconds);
  }
  times.sort();
  return times[runs ~/ 2] / 1000;
}

Future<Map<String, Object?>> dictQueries(DictDb db) async {
  final out = <String, Object?>{};
  Future<void> run(String key, String sql, List<Object> args) async {
    var hits = 0;
    final ms = await _medianMs(() async {
      final rows = await db
          .customSelect(sql, variables: [for (final a in args) Variable(a)])
          .get();
      hits = rows.length;
    });
    out[key] = {'ms': ms, 'hits': hits};
  }

  const limit = 'LIMIT 50';
  for (final term in ['食べる', '日本', '猫', '勉強']) {
    await run(
      'exact $term',
      'SELECT id FROM dict_entries WHERE expression = ? OR reading = ? $limit',
      [term, term],
    );
  }
  for (final prefix in ['食べ', '日本', 'たべ']) {
    // Range scan on the expression/reading indexes; LIKE does not use them
    // for non-ASCII text.
    await run(
      'prefix $prefix',
      'SELECT id FROM dict_entries WHERE (expression >= ?1 AND expression < ?1 || char(1114111)) '
          'OR (reading >= ?1 AND reading < ?1 || char(1114111)) $limit',
      [prefix],
    );
  }
  for (final term in ['日本語', '勉強会', 'たべも']) {
    await run(
      'fts substring $term',
      'SELECT rowid FROM dict_fts WHERE dict_fts MATCH ? $limit',
      ['{expression reading}: "$term"'],
    );
  }
  for (final term in ['study', 'cat food']) {
    await run(
      'fts gloss $term',
      'SELECT rowid FROM dict_fts WHERE dict_fts MATCH ? $limit',
      ['gloss: "$term"'],
    );
  }
  // Two-character substrings are below the trigram minimum; this is the
  // full-scan fallback.
  for (final term in ['本語', '強会']) {
    await run(
      'scan substring $term',
      "SELECT id FROM dict_entries WHERE expression LIKE '%' || ? || '%' $limit",
      [term],
    );
  }
  return out;
}

Future<Map<String, Object?>> counts(AppDb app, DictDb dict) async => {
  'notes': await _count(app, 'notes'),
  'cards': await _count(app, 'cards'),
  'reviewEvents': await _count(app, 'review_events'),
  'dictEntries': await _count(dict, 'dict_entries'),
};
