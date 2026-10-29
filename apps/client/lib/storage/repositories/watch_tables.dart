import 'package:drift/drift.dart';

import '../database.dart';

/// Emits [load] now and again whenever one of [tables] changes. Used for
/// models assembled from several tables, which a single Drift query cannot
/// watch.
Stream<T> watchTables<T>(
  MemukiDatabase db,
  Iterable<ResultSetImplementation<Object?, Object?>> tables,
  Future<T> Function() load,
) async* {
  yield await load();
  await for (final _ in db.tableUpdates(TableUpdateQuery.onAllTables(tables))) {
    yield await load();
  }
}
