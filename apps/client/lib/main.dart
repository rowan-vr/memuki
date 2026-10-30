import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/error_handling.dart';
import 'core/logging.dart';
import 'presentation/settings/appearance_settings.dart';
import 'presentation/startup/startup_error_app.dart';
import 'scheduler/schedulers.dart';
import 'services/rebuild_service.dart';
import 'storage/database_exceptions.dart';
import 'storage/device_preferences.dart';
import 'storage/media/io_media_store.dart';
import 'storage/open_database.dart';
import 'storage/providers.dart';

final _log = Logger('memuki.startup');

Future<void> main() async {
  configureLogging();
  installErrorHandlers();

  // Read first, so even a startup error appears in the chosen appearance.
  final prefs = await _openPreferences();

  // Opening creates or upgrades the schema, so a database that cannot be used
  // is reported before the app starts.
  final database = openAppDatabase(replayHistory: historyReplay(allSchedulers));
  final IoMediaStore media;
  try {
    await database.ensureOpen();
    final support = await getApplicationSupportDirectory();
    media = await IoMediaStore.open(Directory(p.join(support.path, 'media')));
  } catch (error, stackTrace) {
    _log.shout('Could not open storage', error, stackTrace);
    await database.close();
    runApp(
      StartupErrorApp(
        error: switch (error) {
          DatabaseTooNewException() => StartupError.dataTooNew,
          DatabaseMigrationException() => StartupError.upgradeFailed,
          _ => StartupError.unknown,
        },
        details: '$error',
        appearance: AppearanceSettings.read(prefs),
      ),
    );
    return;
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        mediaStoreProvider.overrideWithValue(media),
        devicePreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MemukiApp(),
    ),
  );
}

/// The device's preferences, or empty ones held in memory when the platform
/// store cannot be opened, so the app still starts.
Future<DevicePreferences> _openPreferences() async {
  try {
    return await SharedDevicePreferences.open();
  } catch (error, stackTrace) {
    _log.warning('Could not open device preferences', error, stackTrace);
    return MemoryDevicePreferences();
  }
}
