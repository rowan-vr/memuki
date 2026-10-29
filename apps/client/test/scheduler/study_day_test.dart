import 'package:flutter_test/flutter_test.dart';
import 'package:memuki/scheduler/study_day.dart';

void main() {
  group('in UTC+9 with the default 03:00 start', () {
    final day = StudyDay(utcOffset: const Duration(hours: 9));

    test('a review before 03:00 belongs to the previous day', () {
      // 02:00 on 30 October in Tokyo.
      final review = DateTime.utc(2026, 10, 29, 17);
      // 03:00 on 29 October in Tokyo.
      expect(day.startOf(review), DateTime.utc(2026, 10, 28, 18));
    });

    test('a study day starts exactly at 03:00', () {
      final start = DateTime.utc(2026, 10, 29, 18);
      expect(day.startOf(start), start);
      expect(
        day.startOf(start.subtract(const Duration(milliseconds: 1))),
        DateTime.utc(2026, 10, 28, 18),
      );
    });

    test('later days start at 03:00 local time', () {
      final review = DateTime.utc(2026, 10, 29, 12);
      expect(day.startAfter(review, 1), DateTime.utc(2026, 10, 29, 18));
      expect(day.startAfter(review, 3), DateTime.utc(2026, 10, 31, 18));
    });

    test('days carry over month and year ends', () {
      final review = DateTime.utc(2026, 12, 30, 12);
      expect(day.startAfter(review, 2), DateTime.utc(2026, 12, 31, 18));
      expect(day.startAfter(review, 3), DateTime.utc(2027, 1, 1, 18));
    });
  });

  test('handles offsets of half hours', () {
    final day = StudyDay(utcOffset: const Duration(hours: 5, minutes: 30));
    // 05:30 on 29 October in India; the day began at 03:00 local time.
    expect(
      day.startOf(DateTime.utc(2026, 10, 29)),
      DateTime.utc(2026, 10, 28, 21, 30),
    );
  });

  test('handles offsets behind UTC', () {
    final day = StudyDay(utcOffset: const Duration(hours: -5));
    // 02:00 on 29 October in New York.
    expect(
      day.startOf(DateTime.utc(2026, 10, 29, 7)),
      DateTime.utc(2026, 10, 28, 8),
    );
  });

  test('follows the offset in effect on each side of a daylight saving '
      'change', () {
    // Central European Summer Time ends on 25 October 2026.
    final review = DateTime.utc(2026, 10, 24, 12);
    final summer = StudyDay(utcOffset: const Duration(hours: 2));
    final winter = StudyDay(utcOffset: const Duration(hours: 1));
    expect(summer.startAfter(review, 1), DateTime.utc(2026, 10, 25, 1));
    expect(winter.startAfter(review, 1), DateTime.utc(2026, 10, 25, 2));
  });

  test('uses the configured start of day', () {
    final day = StudyDay(utcOffset: Duration.zero, start: Duration.zero);
    expect(
      day.startOf(DateTime.utc(2026, 10, 29, 1)),
      DateTime.utc(2026, 10, 29),
    );
  });

  test('rejects invalid offsets, starts, and local times', () {
    expect(
      () => StudyDay(utcOffset: const Duration(hours: 19)),
      throwsArgumentError,
    );
    expect(
      () => StudyDay(utcOffset: const Duration(seconds: 30)),
      throwsArgumentError,
    );
    expect(
      () => StudyDay(utcOffset: Duration.zero, start: const Duration(days: 1)),
      throwsArgumentError,
    );
    expect(
      () =>
          StudyDay(utcOffset: Duration.zero, start: const Duration(hours: -1)),
      throwsArgumentError,
    );
    expect(
      () => StudyDay(utcOffset: Duration.zero).startOf(DateTime(2026)),
      throwsArgumentError,
    );
  });
}
