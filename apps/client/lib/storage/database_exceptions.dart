/// The database was written by a newer version of Memuki. It is not opened,
/// so the newer data is left untouched.
class DatabaseTooNewException implements Exception {
  const DatabaseTooNewException({required this.found, required this.supported});

  /// The schema version of the database.
  final int found;

  /// The newest schema version this build understands.
  final int supported;

  @override
  String toString() =>
      'DatabaseTooNewException: database schema v$found is newer than the '
      'supported v$supported';
}

/// Upgrading the database schema failed. The upgrade ran in one transaction,
/// so the database is left at [from] with its data unchanged.
class DatabaseMigrationException implements Exception {
  const DatabaseMigrationException({
    required this.from,
    required this.to,
    required this.cause,
  });

  final int from;
  final int to;
  final Object cause;

  @override
  String toString() =>
      'DatabaseMigrationException: upgrade from v$from to v$to failed: $cause';
}
