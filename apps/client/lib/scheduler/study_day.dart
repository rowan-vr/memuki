import '../domain/invariants.dart';

/// Study days in a fixed UTC offset. A study day runs from [start] local
/// time until the same time the next day, so with the default start of
/// 03:00 a review at 01:00 belongs to the previous day.
///
/// The offset is fixed rather than a time zone, so the result does not
/// depend on the device's time zone database.
final class StudyDay {
  StudyDay({required this.utcOffset, this.start = defaultStart}) {
    requireUtcOffset(utcOffset, 'utcOffset');
    if (start.isNegative || start >= const Duration(days: 1)) {
      throw ArgumentError.value(start, 'start', 'must be within one day');
    }
  }

  static const defaultStart = Duration(hours: 3);

  final Duration utcOffset;

  /// The local time of day at which a study day starts.
  final Duration start;

  /// The start of the study day containing [instant].
  DateTime startOf(DateTime instant) => startAfter(instant, 0);

  /// The start of the study day [days] after the one containing [instant].
  DateTime startAfter(DateTime instant, int days) {
    requireUtc(instant, 'instant');
    // Shifting by the offset and the start turns the study day into a
    // calendar date in UTC arithmetic, which has no daylight saving.
    final shifted = instant.add(utcOffset - start);
    final date = DateTime.utc(shifted.year, shifted.month, shifted.day + days);
    return date.add(start - utcOffset);
  }
}
