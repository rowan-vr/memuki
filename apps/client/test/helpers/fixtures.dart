import 'package:drift/drift.dart';
import 'package:memuki/dev/collection_generator.dart';
import 'package:memuki/storage/database.dart';

/// The fixed time of a fixture database.
final fixtureEpoch = generatorEpoch;

/// The HLC node of a fixture database.
const fixtureNode = '00000000000000f1';

/// A database with a fixed clock and node, so the same writes always produce
/// the same rows, timestamps included.
MemukiDatabase openFixtureDatabase(QueryExecutor executor) =>
    MemukiDatabase(executor, now: () => fixtureEpoch, node: fixtureNode);

/// Every row of every table, by table name, in insertion order. Comparing two
/// dumps shows whether anything in the database changed.
Future<Map<String, List<Map<String, Object?>>>> dumpTables(
  MemukiDatabase db,
) async => {
  for (final table in db.allTables)
    table.actualTableName: [
      for (final row
          in await db
              .customSelect(
                'SELECT * FROM ${table.actualTableName} ORDER BY rowid',
              )
              .get())
        row.data,
    ],
};
