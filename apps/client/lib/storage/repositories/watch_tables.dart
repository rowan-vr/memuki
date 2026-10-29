import 'package:drift/drift.dart';

import '../database.dart';

/// Emits [load] now and again whenever one of [sources] changes. A view
/// changes when one of the tables it reads does. Used for models assembled
/// from several queries, which a single Drift query cannot watch.
Stream<T> watchTables<T>(
  MemukiDatabase db,
  Iterable<ResultSetImplementation<Object?, Object?>> sources,
  Future<T> Function() load,
) async* {
  final names = {
    for (final source in sources)
      ...switch (source) {
        ViewInfo(:final readTables) => readTables,
        _ => {source.entityName},
      },
  };
  final tables = db.allTables.where((t) => names.contains(t.actualTableName));
  yield await load();
  await for (final _ in db.tableUpdates(TableUpdateQuery.onAllTables(tables))) {
    yield await load();
  }
}
