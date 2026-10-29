/// Throws an [ArgumentError] when [value] is empty or only whitespace.
void requireName(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}

/// Throws an [ArgumentError] when [value] is not in UTC.
void requireUtc(DateTime? value, String name) {
  if (value != null && !value.isUtc) {
    throw ArgumentError.value(value, name, 'must be UTC');
  }
}

/// Throws an [ArgumentError] when [value] is not a UTC offset: whole minutes
/// within 18 hours of UTC.
void requireUtcOffset(Duration value, String name) {
  if (value.inMicroseconds % Duration.microsecondsPerMinute != 0 ||
      value.abs() > const Duration(hours: 18)) {
    throw ArgumentError.value(
      value,
      name,
      'must be whole minutes within 18 hours of UTC',
    );
  }
}
