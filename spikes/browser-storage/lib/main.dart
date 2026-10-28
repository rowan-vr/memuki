// Web entry point. Query parameters:
//   phase=full      app writes, dictionary import, queries (default)
//   phase=verify    counts only, to check persistence after a reload
//   phase=tabwrite  repeated small write transactions, for the multi-tab test
//   banks=N         number of Jitendex term banks to import (default: all)
//   content=1       also store the structured glossary JSON
// Results are printed to the console as `SPIKE_RESULT <json>`.

import 'dart:convert';
import 'dart:js_interop';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import 'bench.dart';
import 'db.dart';

final _status = ValueNotifier<List<String>>([]);

void _log(String message) {
  _status.value = [..._status.value, message];
  // ignore: avoid_print
  print('SPIKE_LOG $message');
}

void main() {
  runApp(const SpikeApp());
  _run();
}

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: ValueListenableBuilder(
        valueListenable: _status,
        builder: (context, lines, _) =>
            ListView(children: [for (final l in lines) Text(l)]),
      ),
    ),
  );
}

QueryExecutor _open(String name, Map<String, Object?> into) => driftDatabase(
  name: name,
  web: DriftWebOptions(
    sqlite3Wasm: Uri.parse('sqlite3.wasm'),
    driftWorker: Uri.parse('drift_worker.js'),
    onResult: (WasmDatabaseResult r) {
      into[name] = {
        'implementation': r.chosenImplementation.name,
        'missingFeatures': [for (final f in r.missingFeatures) f.name],
      };
    },
  ),
);

Future<String> _fetch(String url) async {
  final response = await web.window.fetch(url.toJS).toDart;
  if (!response.ok) throw StateError('GET $url: ${response.status}');
  return (await response.text().toDart).toDart;
}

Future<Map<String, Object?>> _storage() async {
  final storage = web.window.navigator.storage;
  final estimate = await storage.estimate().toDart;
  return {
    'usage': estimate.usage,
    'quota': estimate.quota,
    'persisted': (await storage.persisted().toDart).toDart,
    'crossOriginIsolated': web.window.crossOriginIsolated,
  };
}

Future<void> _run() async {
  final params = Uri.base.queryParameters;
  final phase = params['phase'] ?? 'full';
  final storeContent = params['content'] == '1';
  final opened = <String, Object?>{};
  final app = AppDb(_open('app', opened));
  final dict = DictDb(_open('dict', opened));
  final result = <String, Object?>{
    'platform': 'web',
    'phase': phase,
    'userAgent': web.window.navigator.userAgent,
  };
  try {
    if (phase == 'verify') {
      result['counts'] = await counts(app, dict);
    } else if (phase == 'tabwrite') {
      result['tabwrite'] = await _tabWrite(app);
    } else {
      final index = jsonDecode(await _fetch('dict/index.json')) as Map;
      _log('dictionary: ${index['title']}');
      final banks = int.tryParse(params['banks'] ?? '') ?? 219;
      result['storeContent'] = storeContent;
      result['features'] = await featureChecks(app);
      result['opened'] = opened;
      _log('opened: $opened');
      result['app'] = await appWrites(app);
      _log('app writes done');
      result['dict'] = await dictImport(
        dict,
        (bank) => _fetch('dict/term_bank_$bank.json'),
        banks,
        storeContent: storeContent,
        log: _log,
      );
      result['queries'] = await dictQueries(dict);
      result['appBytes'] = await dbBytes(app);
      result['dictBytes'] = await dbBytes(dict);
    }
    result['opened'] = opened;
    result['storage'] = await _storage();
  } catch (e, st) {
    result['error'] = '$e';
    result['stack'] = '$st';
  }
  _log('done');
  // ignore: avoid_print
  print('SPIKE_RESULT ${jsonEncode(result)}');
}

/// Small write transactions in a loop; run in two tabs at once to check that
/// concurrent tabs share one database without errors or lost writes.
Future<Map<String, Object?>> _tabWrite(AppDb db) async {
  final hlc = Hlc();
  final collectionId = newId();
  final noteTypeId = newId();
  await db.transaction(() async {
    await db.into(db.collections).insert(
      CollectionsCompanion.insert(id: collectionId, name: 'Tab', hlc: hlc.next()),
    );
    await db.into(db.noteTypes).insert(
      NoteTypesCompanion.insert(
        id: noteTypeId,
        collectionId: collectionId,
        name: 'Tab',
        hlc: hlc.next(),
      ),
    );
  });
  var errors = 0;
  final sw = Stopwatch()..start();
  for (var i = 0; i < 500; i++) {
    try {
      await db.transaction(() async {
        final id = newId();
        await db.into(db.notes).insert(
          NotesCompanion.insert(
            id: id,
            collectionId: collectionId,
            noteTypeId: noteTypeId,
            fields: '{}',
            hlc: hlc.next(),
          ),
        );
        await db.into(db.outbox).insert(
          OutboxCompanion.insert(
            entityType: 'note',
            entityId: id,
            hlc: hlc.next(),
            payload: '{}',
          ),
        );
      });
    } catch (_) {
      errors++;
    }
  }
  final mine = await (db.select(db.notes)
        ..where((n) => n.collectionId.equals(collectionId)))
      .get();
  return {
    'ms': sw.elapsedMilliseconds,
    'errors': errors,
    'committedByThisTab': mine.length,
    'totalNotes': (await db.customSelect('SELECT count(*) AS c FROM notes').getSingle())
        .read<int>('c'),
  };
}
