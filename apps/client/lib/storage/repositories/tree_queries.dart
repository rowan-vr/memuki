import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../converters.dart';
import '../database.dart';

final _log = Logger('memuki.storage');

/// Deepest level a hierarchy walk follows. Real hierarchies are far
/// shallower; reaching it means a cycle or a corrupt import.
const maxTreeDepth = 64;

/// Recursive queries over a table with `id` and `parent_id` columns (decks and
/// tags).
///
/// Walks use `UNION` and stop at [maxTreeDepth], so a cycle that got into the
/// data (through a bug or a corrupt import) ends the walk and is logged
/// instead of hanging the app.
class TreeQueries<I extends Object> {
  const TreeQueries(this._db, this._table, this._ids);

  final MemukiDatabase _db;
  final TableInfo<Table, Object?> _table;
  final IdConverter<I> _ids;

  /// [id] and everything below it.
  Future<Set<I>> subtree(I id) => _walk(id, down: true);

  /// [id] and everything above it.
  Future<Set<I>> ancestors(I id) => _walk(id, down: false);

  Future<Set<I>> _walk(I id, {required bool down}) async {
    final table = _table.actualTableName;
    final join = down ? 't.parent_id = w.id' : 't.id = w.parent_id';
    final rows = await _db
        .customSelect(
          'WITH RECURSIVE walk(id, parent_id, depth) AS ('
          ' SELECT id, parent_id, 0 FROM $table WHERE id = ?1'
          ' UNION'
          ' SELECT t.id, t.parent_id, w.depth + 1'
          ' FROM $table t JOIN walk w ON $join'
          ' WHERE w.depth < $maxTreeDepth'
          ') SELECT id, max(depth) AS depth FROM walk GROUP BY id',
          variables: [Variable.withBlob(_ids.toSql(id))],
          readsFrom: {_table},
        )
        .get();
    if (rows.any((r) => r.read<int>('depth') >= maxTreeDepth)) {
      _log.warning(
        'Hierarchy walk in $table from $id reached depth $maxTreeDepth; '
        'the data contains a cycle or an unusually deep tree',
      );
    }
    return {for (final r in rows) _ids.fromSql(r.read<Uint8List>('id'))};
  }
}
