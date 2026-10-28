import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:memuki/core/logging.dart';

void main() {
  group('formatLogRecord', () {
    test('formats UTC time, level, logger, and message on one line', () {
      final record = LogRecord(Level.INFO, 'Opened collection', 'memuki.db');
      final line = formatLogRecord(record);

      final timestamp = DateTime.parse(line.split(' ').first);
      expect(timestamp.isUtc, isTrue);
      expect(line, endsWith(' INFO    memuki.db: Opened collection'));
      expect(line, isNot(contains('\n')));
    });

    test('appends error and stack trace on separate lines', () {
      final record = LogRecord(
        Level.SEVERE,
        'Write failed',
        'memuki.db',
        StateError('disk full'),
        StackTrace.fromString('#0 main (file.dart:1)'),
      );
      final lines = formatLogRecord(record).split('\n');

      expect(lines, hasLength(3));
      expect(lines[1], '  error: Bad state: disk full');
      expect(lines[2], '#0 main (file.dart:1)');
    });

    test('names the root logger', () {
      final record = LogRecord(Level.FINE, 'msg', '');
      expect(formatLogRecord(record), endsWith(' root: msg'));
    });
  });
}
