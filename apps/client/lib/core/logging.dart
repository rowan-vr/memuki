import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Configures the root logger.
///
/// Every record is forwarded to `dart:developer` (visible in DevTools with its
/// level, logger name, error, and stack trace) and printed as a single line to
/// the console. Debug builds log everything; release builds log [Level.INFO]
/// and above.
///
/// Libraries create named loggers with `Logger('memuki.<area>')`, e.g.
/// `Logger('memuki.storage')`.
void configureLogging({Level? level}) {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = level ?? (kReleaseMode ? Level.INFO : Level.ALL);
  Logger.root.onRecord.listen(_emit);
}

void _emit(LogRecord record) {
  developer.log(
    record.message,
    time: record.time,
    sequenceNumber: record.sequenceNumber,
    level: record.level.value,
    name: record.loggerName,
    error: record.error,
    stackTrace: record.stackTrace,
  );
  debugPrint(formatLogRecord(record));
}

/// Formats [record] as `<UTC time> <LEVEL> <logger>: <message>`, followed by
/// the error and stack trace on separate lines when present.
String formatLogRecord(LogRecord record) {
  final buffer = StringBuffer()
    ..write(record.time.toUtc().toIso8601String())
    ..write(' ')
    ..write(record.level.name.padRight(7))
    ..write(' ')
    ..write(record.loggerName.isEmpty ? 'root' : record.loggerName)
    ..write(': ')
    ..write(record.message);
  if (record.error != null) {
    buffer
      ..writeln()
      ..write('  error: ${record.error}');
  }
  if (record.stackTrace != null) {
    buffer
      ..writeln()
      ..write(record.stackTrace.toString().trimRight());
  }
  return buffer.toString();
}
