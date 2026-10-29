import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:memuki/storage/database.dart';
import 'package:memuki/storage/media/io_media_store.dart';
import 'package:memuki/storage/repositories/media_repository.dart';
import 'package:memuki/storage/repositories/repositories.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/parsing.dart';
import 'package:uuid/uuid.dart';

/// A problem with the command's input, reported without a stack trace.
class ToolException implements Exception {
  ToolException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// No row matches a reference.
class NoMatchException extends ToolException {
  NoMatchException(super.message);
}

/// Where the app keeps its data on this platform, or null if unknown.
String? defaultDataDirectory() {
  final env = Platform.environment;
  final home = env['HOME'];
  if (Platform.isLinux && home != null) {
    final data = env['XDG_DATA_HOME'] ?? p.join(home, '.local', 'share');
    return p.join(data, 'net.memuki.memuki');
  }
  if (Platform.isMacOS && home != null) {
    return p.join(home, 'Library', 'Application Support', 'net.memuki.memuki');
  }
  return null;
}

/// An open database and media store, with helpers for commands.
class Session {
  Session._(this.dbFile, this.mediaDir, this.db, this.store, this.out)
    : repos = Repositories(db),
      media = MediaRepository(db, store);

  /// Opens (and creates or upgrades, like the app) the database at [dbFile]
  /// and the media store in [mediaDir].
  static Future<Session> open({
    required File dbFile,
    required Directory mediaDir,
    required StringSink out,
  }) async {
    await dbFile.parent.create(recursive: true);
    final db = MemukiDatabase(
      NativeDatabase(dbFile),
      backupDirectory: () async => dbFile.parent,
    );
    await db.ensureOpen();
    final store = await IoMediaStore.open(mediaDir);
    return Session._(dbFile, mediaDir, db, store, out);
  }

  final File dbFile;
  final Directory mediaDir;
  final MemukiDatabase db;
  final IoMediaStore store;
  final Repositories repos;
  final MediaRepository media;
  final StringSink out;

  Future<void> close() => db.close();

  /// Finds the row of [table] that [input] names: a full ID, the start or
  /// end of one (dashes optional), or, for tables with a `name` column, its
  /// name. Tombstoned rows are included, so they can be inspected.
  Future<String> resolve(String table, String input, {String? label}) async {
    final what = label ?? table;
    final hex = input.replaceAll('-', '').toUpperCase();
    final byId = RegExp(r'^[0-9A-F]{4,32}$').hasMatch(hex);
    final hasName = await _hasColumn(table, 'name');
    final conditions = <String>[];
    final variables = <Variable>[];
    if (byId) {
      variables.add(Variable.withString(hex));
      final i = variables.length;
      conditions.add("hex(id) LIKE ?$i || '%' OR hex(id) LIKE '%' || ?$i");
    }
    if (hasName) {
      variables.add(Variable.withString(input));
      conditions.add('lower(name) = lower(?${variables.length})');
    }
    if (conditions.isEmpty) {
      throw NoMatchException('"$input" is not a $what ID');
    }
    final rows = await db
        .customSelect(
          'SELECT id FROM $table WHERE ${conditions.join(' OR ')}',
          variables: variables,
        )
        .get();
    return switch (rows) {
      [final row] => uuidOf(row.read<Uint8List>('id')),
      [] => throw NoMatchException('No $what matches "$input"'),
      _ => throw ToolException(
        '"$input" matches ${rows.length} ${what}s: '
        '${rows.map((r) => short(uuidOf(r.read<Uint8List>('id')))).join(', ')}',
      ),
    };
  }

  /// Which table has a row with this ID, searching every table with an `id`
  /// column.
  Future<(String table, String id)> find(String input) async {
    const tables = [
      'collections',
      'decks',
      'tags',
      'note_types',
      'field_definitions',
      'study_card_templates',
      'notes',
      'study_cards',
      'review_events',
    ];
    final found = <(String, String)>[];
    for (final table in tables) {
      try {
        found.add((table, await resolve(table, input)));
      } on NoMatchException {
        continue;
      }
    }
    return switch (found) {
      [final one] => one,
      [] => throw ToolException('Nothing matches "$input"'),
      _ => throw ToolException(
        '"$input" matches several entities: '
        '${found.map((f) => '${f.$1} ${short(f.$2)}').join(', ')}',
      ),
    };
  }

  Future<bool> _hasColumn(String table, String column) async {
    final rows = await db
        .customSelect(
          'SELECT name FROM pragma_table_info(?)',
          variables: [Variable.withString(table)],
        )
        .get();
    return rows.any((r) => r.read<String>('name') == column);
  }

  /// Prints [rows] as aligned columns under [headers].
  void table(List<String> headers, List<List<Object?>> rows) {
    final cells = [
      headers,
      for (final row in rows) [for (final cell in row) '${cell ?? ''}'],
    ];
    final widths = [
      for (var c = 0; c < headers.length; c++)
        cells.map((r) => displayWidth(r[c])).reduce((a, b) => a > b ? a : b),
    ];
    for (final row in cells) {
      out.writeln(
        [
          for (var c = 0; c < row.length; c++)
            c == row.length - 1
                ? row[c]
                : row[c] + ' ' * (widths[c] - displayWidth(row[c])),
        ].join('  ').trimRight(),
      );
    }
  }
}

/// The canonical UUID string of 16 ID bytes.
String uuidOf(List<int> bytes) => Uuid.unparse(bytes);

/// 16 ID bytes of a UUID string.
Uint8List bytesOf(String uuid) => Uint8List.fromList(UuidParsing.parse(uuid));

/// The last 8 hex digits of an ID: the random part, which tells IDs created
/// in the same millisecond apart. Commands accept it in place of the full ID.
String short(Object id) => '$id'.replaceAll('-', '').substring(24);

/// Columns a string takes in a terminal, counting East Asian wide characters
/// as two.
int displayWidth(String text) => text.runes
    .map(
      (r) =>
          (r >= 0x1100 && r <= 0x115F) || (r >= 0x2E80 && r <= 0xFFDC) ? 2 : 1,
    )
    .fold(0, (a, b) => a + b);
