/// A write was rejected because it would break an invariant that spans
/// entities. Nothing was changed.
sealed class RepositoryException implements Exception {
  const RepositoryException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// An entity that the operation needs does not exist.
class EntityNotFoundException extends RepositoryException {
  const EntityNotFoundException(super.message);
}

/// The entity cannot be deleted, e.g. a collection's default preset.
class ProtectedEntityException extends RepositoryException {
  const ProtectedEntityException(super.message);
}

/// An entity with this identity already exists.
class DuplicateEntityException extends RepositoryException {
  const DuplicateEntityException(super.message);
}

/// The operation would reference or move an entity across collections.
class CrossCollectionException extends RepositoryException {
  const CrossCollectionException(super.message);
}

/// A sibling deck or tag already has this name.
class DuplicateNameException extends RepositoryException {
  const DuplicateNameException(super.message);
}

/// The new parent is the entity itself or one of its descendants.
class ParentCycleException extends RepositoryException {
  const ParentCycleException(super.message);
}

/// The entity is still referenced, e.g. a note type that notes use.
class EntityInUseException extends RepositoryException {
  const EntityInUseException(super.message);
}

/// A field or card template does not belong to the note's note type, or the
/// note type would change.
class NoteTypeMismatchException extends RepositoryException {
  const NoteTypeMismatchException(super.message);
}
