import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'database.dart';
import 'history_replay.dart';

/// Opens the app's database in the application support directory.
///
/// Kept apart from [MemukiDatabase] so the storage code has no Flutter
/// imports and also runs in plain Dart tools (see `tool/memuki.dart`).
///
/// [replayHistory] is needed to upgrade review history from before v7.
MemukiDatabase openAppDatabase({ReplayHistory? replayHistory}) =>
    MemukiDatabase(
      driftDatabase(
        name: 'memuki',
        native: const DriftNativeOptions(
          databaseDirectory: getApplicationSupportDirectory,
        ),
      ),
      // Web storage is set up in Phase 12.
      backupDirectory: kIsWeb ? null : getApplicationSupportDirectory,
      replayHistory: replayHistory,
    );
