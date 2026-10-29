import 'package:drift/drift.dart';

import '../database.dart';
import 'hlc.dart';

/// For each synced table: SQL for an entity's outbox key and its collection,
/// over the table aliased as `src`. Composite keys concatenate their parts'
/// bytes.
const _syncedTables = <String, ({String key, String collection})>{
  'collections': (key: 'src.id', collection: 'src.id'),
  'decks': (key: 'src.id', collection: 'src.collection_id'),
  'tags': (key: 'src.id', collection: 'src.collection_id'),
  'note_types': (key: 'src.id', collection: 'src.collection_id'),
  'field_definitions': (
    key: 'src.id',
    collection: '(SELECT t.collection_id FROM note_types t WHERE t.id = src.note_type_id)',
  ),
  'study_card_templates': (
    key: 'src.id',
    collection: '(SELECT t.collection_id FROM note_types t WHERE t.id = src.note_type_id)',
  ),
  'notes': (key: 'src.id', collection: 'src.collection_id'),
  'note_fields': (
    key: 'unhex(hex(src.note_id) || hex(src.field_id))',
    collection:
        '(SELECT n.collection_id FROM notes n WHERE n.id = src.note_id)',
  ),
  'note_tags': (
    key: 'unhex(hex(src.note_id) || hex(src.tag_id))',
    collection: 'src.collection_id',
  ),
  'study_cards': (key: 'src.id', collection: 'src.collection_id'),
  'media_assets': (
    key: 'unhex(hex(src.collection_id) || hex(src.hash))',
    collection: 'src.collection_id',
  ),
  'review_events': (
    key: 'src.id',
    collection: '(SELECT c.collection_id FROM study_cards c WHERE c.id = src.study_card_id)',
  ),
};

/// Stamps local changes with an HLC timestamp and records them in the outbox.
///
/// Every repository write goes through [write]: the change runs in a
/// transaction with one new timestamp, which it sets as the `hlc` of every row
/// it inserts, updates, or tombstones. Afterwards, every synced row carrying
/// that timestamp is added to the outbox. Triggers reject an update that keeps
/// a row's old timestamp, so a changed row cannot be missed.
class ChangeRecorder {
  ChangeRecorder(this._db);

  final MemukiDatabase _db;

  Future<T> write<T>(Future<T> Function(Hlc hlc) change) =>
      _db.transaction(() async {
        final hlc = _db.clock.tick();
        final result = await change(hlc);
        final stamp = Variable.withString(hlc.toString());
        for (final MapEntry(key: table, value: sql) in _syncedTables.entries) {
          await _db.customInsert(
            'INSERT INTO outbox (collection_id, entity_table, entity_key, hlc) '
            "SELECT ${sql.collection}, '$table', ${sql.key}, src.hlc "
            'FROM $table src WHERE src.hlc = ?1 '
            'ON CONFLICT (entity_table, entity_key) '
            'DO UPDATE SET hlc = excluded.hlc',
            variables: [stamp],
            updates: {_db.outbox},
          );
        }
        await _db.customUpdate(
          'UPDATE device SET last_hlc = ?1 '
          'WHERE last_hlc IS NULL OR last_hlc < ?1',
          variables: [stamp],
          updates: {_db.device},
        );
        return result;
      });
}
