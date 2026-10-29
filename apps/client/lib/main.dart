import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'app.dart';
import 'core/error_handling.dart';
import 'core/logging.dart';
import 'presentation/startup/startup_error_app.dart';
import 'storage/database.dart';
import 'storage/database_exceptions.dart';
import 'storage/providers.dart';

final _log = Logger('memuki.startup');

Future<void> main() async {
  configureLogging();
  installErrorHandlers();

  // Opening creates or upgrades the schema, so a database that cannot be used
  // is reported before the app starts.
  final database = MemukiDatabase.open();
  try {
    await database.ensureOpen();
  } catch (error, stackTrace) {
    _log.shout('Could not open the database', error, stackTrace);
    await database.close();
    runApp(
      StartupErrorApp(
        error: switch (error) {
          DatabaseTooNewException() => StartupError.dataTooNew,
          DatabaseMigrationException() => StartupError.upgradeFailed,
          _ => StartupError.unknown,
        },
        details: '$error',
      ),
    );
    return;
  }

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const MemukiApp(),
    ),
  );
}
