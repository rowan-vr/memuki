// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($CollectionsTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CollectionId, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<CollectionId>($CollectionsTable.$converterid);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [hlc, deleted, id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      hlc: $CollectionsTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: $CollectionsTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<CollectionId, Uint8List> $converterid =
      collectionIdConverter;
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final Hlc hlc;
  final bool deleted;
  final CollectionId id;
  final String name;
  const CollectionRow({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>($CollectionsTable.$converterhlc.toSql(hlc));
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['id'] = Variable<Uint8List>($CollectionsTable.$converterid.toSql(id));
    }
    map['name'] = Variable<String>(name);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      name: Value(name),
    );
  }

  factory CollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<CollectionId>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<CollectionId>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  CollectionRow copyWith({
    Hlc? hlc,
    bool? deleted,
    CollectionId? id,
    String? name,
  }) => CollectionRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    name: name ?? this.name,
  );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hlc, deleted, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.name == this.name);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<CollectionId> id;
  final Value<String> name;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required CollectionId id,
    required String name,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       name = Value(name);
  static Insertable<CollectionRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<CollectionId>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $CollectionsTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $CollectionsTable.$converterid.toSql(id.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecksTable extends Decks with TableInfo<$DecksTable, DeckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($DecksTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DeckId, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<DeckId>($DecksTable.$converterid);
  @override
  late final GeneratedColumnWithTypeConverter<CollectionId, Uint8List>
  collectionId = GeneratedColumn<Uint8List>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  ).withConverter<CollectionId>($DecksTable.$convertercollectionId);
  @override
  late final GeneratedColumnWithTypeConverter<DeckId?, Uint8List> parentId =
      GeneratedColumn<Uint8List>(
        'parent_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<DeckId?>($DecksTable.$converterparentIdn);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    id,
    collectionId,
    parentId,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {collectionId, id},
  ];
  @override
  DeckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckRow(
      hlc: $DecksTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: $DecksTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      collectionId: $DecksTable.$convertercollectionId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}collection_id'],
        )!,
      ),
      parentId: $DecksTable.$converterparentIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}parent_id'],
        ),
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<DeckId, Uint8List> $converterid = deckIdConverter;
  static TypeConverter<CollectionId, Uint8List> $convertercollectionId =
      collectionIdConverter;
  static TypeConverter<DeckId, Uint8List> $converterparentId = deckIdConverter;
  static TypeConverter<DeckId?, Uint8List?> $converterparentIdn =
      NullAwareTypeConverter.wrap($converterparentId);
}

class DeckRow extends DataClass implements Insertable<DeckRow> {
  final Hlc hlc;
  final bool deleted;
  final DeckId id;
  final CollectionId collectionId;
  final DeckId? parentId;
  final String name;
  const DeckRow({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.collectionId,
    this.parentId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>($DecksTable.$converterhlc.toSql(hlc));
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['id'] = Variable<Uint8List>($DecksTable.$converterid.toSql(id));
    }
    {
      map['collection_id'] = Variable<Uint8List>(
        $DecksTable.$convertercollectionId.toSql(collectionId),
      );
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<Uint8List>(
        $DecksTable.$converterparentIdn.toSql(parentId),
      );
    }
    map['name'] = Variable<String>(name);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      collectionId: Value(collectionId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
    );
  }

  factory DeckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<DeckId>(json['id']),
      collectionId: serializer.fromJson<CollectionId>(json['collectionId']),
      parentId: serializer.fromJson<DeckId?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<DeckId>(id),
      'collectionId': serializer.toJson<CollectionId>(collectionId),
      'parentId': serializer.toJson<DeckId?>(parentId),
      'name': serializer.toJson<String>(name),
    };
  }

  DeckRow copyWith({
    Hlc? hlc,
    bool? deleted,
    DeckId? id,
    CollectionId? collectionId,
    Value<DeckId?> parentId = const Value.absent(),
    String? name,
  }) => DeckRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
  );
  DeckRow copyWithCompanion(DecksCompanion data) {
    return DeckRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(hlc, deleted, id, collectionId, parentId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.parentId == this.parentId &&
          other.name == this.name);
}

class DecksCompanion extends UpdateCompanion<DeckRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<DeckId> id;
  final Value<CollectionId> collectionId;
  final Value<DeckId?> parentId;
  final Value<String> name;
  final Value<int> rowid;
  const DecksCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required DeckId id,
    required CollectionId collectionId,
    this.parentId = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       collectionId = Value(collectionId),
       name = Value(name);
  static Insertable<DeckRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? id,
    Expression<Uint8List>? collectionId,
    Expression<Uint8List>? parentId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<DeckId>? id,
    Value<CollectionId>? collectionId,
    Value<DeckId?>? parentId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>($DecksTable.$converterhlc.toSql(hlc.value));
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<Uint8List>($DecksTable.$converterid.toSql(id.value));
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<Uint8List>(
        $DecksTable.$convertercollectionId.toSql(collectionId.value),
      );
    }
    if (parentId.present) {
      map['parent_id'] = Variable<Uint8List>(
        $DecksTable.$converterparentIdn.toSql(parentId.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($TagsTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TagId, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<TagId>($TagsTable.$converterid);
  @override
  late final GeneratedColumnWithTypeConverter<CollectionId, Uint8List>
  collectionId = GeneratedColumn<Uint8List>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  ).withConverter<CollectionId>($TagsTable.$convertercollectionId);
  @override
  late final GeneratedColumnWithTypeConverter<TagId?, Uint8List> parentId =
      GeneratedColumn<Uint8List>(
        'parent_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      ).withConverter<TagId?>($TagsTable.$converterparentIdn);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    id,
    collectionId,
    parentId,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {collectionId, id},
  ];
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      hlc: $TagsTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: $TagsTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      collectionId: $TagsTable.$convertercollectionId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}collection_id'],
        )!,
      ),
      parentId: $TagsTable.$converterparentIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}parent_id'],
        ),
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<TagId, Uint8List> $converterid = tagIdConverter;
  static TypeConverter<CollectionId, Uint8List> $convertercollectionId =
      collectionIdConverter;
  static TypeConverter<TagId, Uint8List> $converterparentId = tagIdConverter;
  static TypeConverter<TagId?, Uint8List?> $converterparentIdn =
      NullAwareTypeConverter.wrap($converterparentId);
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final Hlc hlc;
  final bool deleted;
  final TagId id;
  final CollectionId collectionId;
  final TagId? parentId;
  final String name;
  const TagRow({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.collectionId,
    this.parentId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>($TagsTable.$converterhlc.toSql(hlc));
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['id'] = Variable<Uint8List>($TagsTable.$converterid.toSql(id));
    }
    {
      map['collection_id'] = Variable<Uint8List>(
        $TagsTable.$convertercollectionId.toSql(collectionId),
      );
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<Uint8List>(
        $TagsTable.$converterparentIdn.toSql(parentId),
      );
    }
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      collectionId: Value(collectionId),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<TagId>(json['id']),
      collectionId: serializer.fromJson<CollectionId>(json['collectionId']),
      parentId: serializer.fromJson<TagId?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<TagId>(id),
      'collectionId': serializer.toJson<CollectionId>(collectionId),
      'parentId': serializer.toJson<TagId?>(parentId),
      'name': serializer.toJson<String>(name),
    };
  }

  TagRow copyWith({
    Hlc? hlc,
    bool? deleted,
    TagId? id,
    CollectionId? collectionId,
    Value<TagId?> parentId = const Value.absent(),
    String? name,
  }) => TagRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(hlc, deleted, id, collectionId, parentId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.parentId == this.parentId &&
          other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<TagId> id;
  final Value<CollectionId> collectionId;
  final Value<TagId?> parentId;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required TagId id,
    required CollectionId collectionId,
    this.parentId = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       collectionId = Value(collectionId),
       name = Value(name);
  static Insertable<TagRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? id,
    Expression<Uint8List>? collectionId,
    Expression<Uint8List>? parentId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<TagId>? id,
    Value<CollectionId>? collectionId,
    Value<TagId?>? parentId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>($TagsTable.$converterhlc.toSql(hlc.value));
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<Uint8List>($TagsTable.$converterid.toSql(id.value));
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<Uint8List>(
        $TagsTable.$convertercollectionId.toSql(collectionId.value),
      );
    }
    if (parentId.present) {
      map['parent_id'] = Variable<Uint8List>(
        $TagsTable.$converterparentIdn.toSql(parentId.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteTypesTable extends NoteTypes
    with TableInfo<$NoteTypesTable, NoteTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTypesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($NoteTypesTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<NoteTypeId, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<NoteTypeId>($NoteTypesTable.$converterid);
  @override
  late final GeneratedColumnWithTypeConverter<CollectionId, Uint8List>
  collectionId = GeneratedColumn<Uint8List>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  ).withConverter<CollectionId>($NoteTypesTable.$convertercollectionId);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [hlc, deleted, id, collectionId, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {collectionId, id},
  ];
  @override
  NoteTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTypeRow(
      hlc: $NoteTypesTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: $NoteTypesTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      collectionId: $NoteTypesTable.$convertercollectionId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}collection_id'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $NoteTypesTable createAlias(String alias) {
    return $NoteTypesTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<NoteTypeId, Uint8List> $converterid =
      noteTypeIdConverter;
  static TypeConverter<CollectionId, Uint8List> $convertercollectionId =
      collectionIdConverter;
}

class NoteTypeRow extends DataClass implements Insertable<NoteTypeRow> {
  final Hlc hlc;
  final bool deleted;
  final NoteTypeId id;
  final CollectionId collectionId;
  final String name;
  const NoteTypeRow({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.collectionId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>($NoteTypesTable.$converterhlc.toSql(hlc));
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['id'] = Variable<Uint8List>($NoteTypesTable.$converterid.toSql(id));
    }
    {
      map['collection_id'] = Variable<Uint8List>(
        $NoteTypesTable.$convertercollectionId.toSql(collectionId),
      );
    }
    map['name'] = Variable<String>(name);
    return map;
  }

  NoteTypesCompanion toCompanion(bool nullToAbsent) {
    return NoteTypesCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      collectionId: Value(collectionId),
      name: Value(name),
    );
  }

  factory NoteTypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTypeRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<NoteTypeId>(json['id']),
      collectionId: serializer.fromJson<CollectionId>(json['collectionId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<NoteTypeId>(id),
      'collectionId': serializer.toJson<CollectionId>(collectionId),
      'name': serializer.toJson<String>(name),
    };
  }

  NoteTypeRow copyWith({
    Hlc? hlc,
    bool? deleted,
    NoteTypeId? id,
    CollectionId? collectionId,
    String? name,
  }) => NoteTypeRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    name: name ?? this.name,
  );
  NoteTypeRow copyWithCompanion(NoteTypesCompanion data) {
    return NoteTypeRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTypeRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hlc, deleted, id, collectionId, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTypeRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.name == this.name);
}

class NoteTypesCompanion extends UpdateCompanion<NoteTypeRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<NoteTypeId> id;
  final Value<CollectionId> collectionId;
  final Value<String> name;
  final Value<int> rowid;
  const NoteTypesCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteTypesCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required NoteTypeId id,
    required CollectionId collectionId,
    required String name,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       collectionId = Value(collectionId),
       name = Value(name);
  static Insertable<NoteTypeRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? id,
    Expression<Uint8List>? collectionId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteTypesCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<NoteTypeId>? id,
    Value<CollectionId>? collectionId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return NoteTypesCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $NoteTypesTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $NoteTypesTable.$converterid.toSql(id.value),
      );
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<Uint8List>(
        $NoteTypesTable.$convertercollectionId.toSql(collectionId.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTypesCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($NotesTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<NoteId, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<NoteId>($NotesTable.$converterid);
  @override
  late final GeneratedColumnWithTypeConverter<CollectionId, Uint8List>
  collectionId = GeneratedColumn<Uint8List>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  ).withConverter<CollectionId>($NotesTable.$convertercollectionId);
  @override
  late final GeneratedColumnWithTypeConverter<NoteTypeId, Uint8List>
  noteTypeId = GeneratedColumn<Uint8List>(
    'note_type_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  ).withConverter<NoteTypeId>($NotesTable.$converternoteTypeId);
  @override
  late final GeneratedColumnWithTypeConverter<SourceKind?, String> sourceKind =
      GeneratedColumn<String>(
        'source_kind',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<SourceKind?>($NotesTable.$convertersourceKindn);
  static const VerificationMeta _sourceReferenceMeta = const VerificationMeta(
    'sourceReference',
  );
  @override
  late final GeneratedColumn<String> sourceReference = GeneratedColumn<String>(
    'source_reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    id,
    collectionId,
    noteTypeId,
    sourceKind,
    sourceReference,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('source_reference')) {
      context.handle(
        _sourceReferenceMeta,
        sourceReference.isAcceptableOrUnknown(
          data['source_reference']!,
          _sourceReferenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {collectionId, id},
  ];
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      hlc: $NotesTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: $NotesTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      collectionId: $NotesTable.$convertercollectionId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}collection_id'],
        )!,
      ),
      noteTypeId: $NotesTable.$converternoteTypeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}note_type_id'],
        )!,
      ),
      sourceKind: $NotesTable.$convertersourceKindn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source_kind'],
        ),
      ),
      sourceReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_reference'],
      ),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<NoteId, Uint8List> $converterid = noteIdConverter;
  static TypeConverter<CollectionId, Uint8List> $convertercollectionId =
      collectionIdConverter;
  static TypeConverter<NoteTypeId, Uint8List> $converternoteTypeId =
      noteTypeIdConverter;
  static JsonTypeConverter2<SourceKind, String, String> $convertersourceKind =
      const EnumNameConverter<SourceKind>(SourceKind.values);
  static JsonTypeConverter2<SourceKind?, String?, String?>
  $convertersourceKindn = JsonTypeConverter2.asNullable($convertersourceKind);
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final Hlc hlc;
  final bool deleted;
  final NoteId id;
  final CollectionId collectionId;
  final NoteTypeId noteTypeId;
  final SourceKind? sourceKind;
  final String? sourceReference;
  const NoteRow({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.collectionId,
    required this.noteTypeId,
    this.sourceKind,
    this.sourceReference,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>($NotesTable.$converterhlc.toSql(hlc));
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['id'] = Variable<Uint8List>($NotesTable.$converterid.toSql(id));
    }
    {
      map['collection_id'] = Variable<Uint8List>(
        $NotesTable.$convertercollectionId.toSql(collectionId),
      );
    }
    {
      map['note_type_id'] = Variable<Uint8List>(
        $NotesTable.$converternoteTypeId.toSql(noteTypeId),
      );
    }
    if (!nullToAbsent || sourceKind != null) {
      map['source_kind'] = Variable<String>(
        $NotesTable.$convertersourceKindn.toSql(sourceKind),
      );
    }
    if (!nullToAbsent || sourceReference != null) {
      map['source_reference'] = Variable<String>(sourceReference);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      collectionId: Value(collectionId),
      noteTypeId: Value(noteTypeId),
      sourceKind: sourceKind == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceKind),
      sourceReference: sourceReference == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceReference),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<NoteId>(json['id']),
      collectionId: serializer.fromJson<CollectionId>(json['collectionId']),
      noteTypeId: serializer.fromJson<NoteTypeId>(json['noteTypeId']),
      sourceKind: $NotesTable.$convertersourceKindn.fromJson(
        serializer.fromJson<String?>(json['sourceKind']),
      ),
      sourceReference: serializer.fromJson<String?>(json['sourceReference']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<NoteId>(id),
      'collectionId': serializer.toJson<CollectionId>(collectionId),
      'noteTypeId': serializer.toJson<NoteTypeId>(noteTypeId),
      'sourceKind': serializer.toJson<String?>(
        $NotesTable.$convertersourceKindn.toJson(sourceKind),
      ),
      'sourceReference': serializer.toJson<String?>(sourceReference),
    };
  }

  NoteRow copyWith({
    Hlc? hlc,
    bool? deleted,
    NoteId? id,
    CollectionId? collectionId,
    NoteTypeId? noteTypeId,
    Value<SourceKind?> sourceKind = const Value.absent(),
    Value<String?> sourceReference = const Value.absent(),
  }) => NoteRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    noteTypeId: noteTypeId ?? this.noteTypeId,
    sourceKind: sourceKind.present ? sourceKind.value : this.sourceKind,
    sourceReference: sourceReference.present
        ? sourceReference.value
        : this.sourceReference,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      noteTypeId: data.noteTypeId.present
          ? data.noteTypeId.value
          : this.noteTypeId,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      sourceReference: data.sourceReference.present
          ? data.sourceReference.value
          : this.sourceReference,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('noteTypeId: $noteTypeId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceReference: $sourceReference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    hlc,
    deleted,
    id,
    collectionId,
    noteTypeId,
    sourceKind,
    sourceReference,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.noteTypeId == this.noteTypeId &&
          other.sourceKind == this.sourceKind &&
          other.sourceReference == this.sourceReference);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<NoteId> id;
  final Value<CollectionId> collectionId;
  final Value<NoteTypeId> noteTypeId;
  final Value<SourceKind?> sourceKind;
  final Value<String?> sourceReference;
  final Value<int> rowid;
  const NotesCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.noteTypeId = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.sourceReference = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required NoteId id,
    required CollectionId collectionId,
    required NoteTypeId noteTypeId,
    this.sourceKind = const Value.absent(),
    this.sourceReference = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       collectionId = Value(collectionId),
       noteTypeId = Value(noteTypeId);
  static Insertable<NoteRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? id,
    Expression<Uint8List>? collectionId,
    Expression<Uint8List>? noteTypeId,
    Expression<String>? sourceKind,
    Expression<String>? sourceReference,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (noteTypeId != null) 'note_type_id': noteTypeId,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (sourceReference != null) 'source_reference': sourceReference,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<NoteId>? id,
    Value<CollectionId>? collectionId,
    Value<NoteTypeId>? noteTypeId,
    Value<SourceKind?>? sourceKind,
    Value<String?>? sourceReference,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      noteTypeId: noteTypeId ?? this.noteTypeId,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceReference: sourceReference ?? this.sourceReference,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>($NotesTable.$converterhlc.toSql(hlc.value));
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<Uint8List>($NotesTable.$converterid.toSql(id.value));
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<Uint8List>(
        $NotesTable.$convertercollectionId.toSql(collectionId.value),
      );
    }
    if (noteTypeId.present) {
      map['note_type_id'] = Variable<Uint8List>(
        $NotesTable.$converternoteTypeId.toSql(noteTypeId.value),
      );
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(
        $NotesTable.$convertersourceKindn.toSql(sourceKind.value),
      );
    }
    if (sourceReference.present) {
      map['source_reference'] = Variable<String>(sourceReference.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('noteTypeId: $noteTypeId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('sourceReference: $sourceReference, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteTagsTable extends NoteTags
    with TableInfo<$NoteTagsTable, NoteTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTagsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($NoteTagsTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CollectionId, Uint8List>
  collectionId = GeneratedColumn<Uint8List>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  ).withConverter<CollectionId>($NoteTagsTable.$convertercollectionId);
  @override
  late final GeneratedColumnWithTypeConverter<NoteId, Uint8List> noteId =
      GeneratedColumn<Uint8List>(
        'note_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<NoteId>($NoteTagsTable.$converternoteId);
  @override
  late final GeneratedColumnWithTypeConverter<TagId, Uint8List> tagId =
      GeneratedColumn<Uint8List>(
        'tag_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<TagId>($NoteTagsTable.$convertertagId);
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    collectionId,
    noteId,
    tagId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId, tagId};
  @override
  NoteTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTagRow(
      hlc: $NoteTagsTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      collectionId: $NoteTagsTable.$convertercollectionId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}collection_id'],
        )!,
      ),
      noteId: $NoteTagsTable.$converternoteId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}note_id'],
        )!,
      ),
      tagId: $NoteTagsTable.$convertertagId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}tag_id'],
        )!,
      ),
    );
  }

  @override
  $NoteTagsTable createAlias(String alias) {
    return $NoteTagsTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<CollectionId, Uint8List> $convertercollectionId =
      collectionIdConverter;
  static TypeConverter<NoteId, Uint8List> $converternoteId = noteIdConverter;
  static TypeConverter<TagId, Uint8List> $convertertagId = tagIdConverter;
}

class NoteTagRow extends DataClass implements Insertable<NoteTagRow> {
  final Hlc hlc;
  final bool deleted;
  final CollectionId collectionId;
  final NoteId noteId;
  final TagId tagId;
  const NoteTagRow({
    required this.hlc,
    required this.deleted,
    required this.collectionId,
    required this.noteId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>($NoteTagsTable.$converterhlc.toSql(hlc));
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['collection_id'] = Variable<Uint8List>(
        $NoteTagsTable.$convertercollectionId.toSql(collectionId),
      );
    }
    {
      map['note_id'] = Variable<Uint8List>(
        $NoteTagsTable.$converternoteId.toSql(noteId),
      );
    }
    {
      map['tag_id'] = Variable<Uint8List>(
        $NoteTagsTable.$convertertagId.toSql(tagId),
      );
    }
    return map;
  }

  NoteTagsCompanion toCompanion(bool nullToAbsent) {
    return NoteTagsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      collectionId: Value(collectionId),
      noteId: Value(noteId),
      tagId: Value(tagId),
    );
  }

  factory NoteTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTagRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      collectionId: serializer.fromJson<CollectionId>(json['collectionId']),
      noteId: serializer.fromJson<NoteId>(json['noteId']),
      tagId: serializer.fromJson<TagId>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'collectionId': serializer.toJson<CollectionId>(collectionId),
      'noteId': serializer.toJson<NoteId>(noteId),
      'tagId': serializer.toJson<TagId>(tagId),
    };
  }

  NoteTagRow copyWith({
    Hlc? hlc,
    bool? deleted,
    CollectionId? collectionId,
    NoteId? noteId,
    TagId? tagId,
  }) => NoteTagRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    collectionId: collectionId ?? this.collectionId,
    noteId: noteId ?? this.noteId,
    tagId: tagId ?? this.tagId,
  );
  NoteTagRow copyWithCompanion(NoteTagsCompanion data) {
    return NoteTagRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('collectionId: $collectionId, ')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hlc, deleted, collectionId, noteId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTagRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.collectionId == this.collectionId &&
          other.noteId == this.noteId &&
          other.tagId == this.tagId);
}

class NoteTagsCompanion extends UpdateCompanion<NoteTagRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<CollectionId> collectionId;
  final Value<NoteId> noteId;
  final Value<TagId> tagId;
  final Value<int> rowid;
  const NoteTagsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteTagsCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required CollectionId collectionId,
    required NoteId noteId,
    required TagId tagId,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       collectionId = Value(collectionId),
       noteId = Value(noteId),
       tagId = Value(tagId);
  static Insertable<NoteTagRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? collectionId,
    Expression<Uint8List>? noteId,
    Expression<Uint8List>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (collectionId != null) 'collection_id': collectionId,
      if (noteId != null) 'note_id': noteId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteTagsCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<CollectionId>? collectionId,
    Value<NoteId>? noteId,
    Value<TagId>? tagId,
    Value<int>? rowid,
  }) {
    return NoteTagsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      collectionId: collectionId ?? this.collectionId,
      noteId: noteId ?? this.noteId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $NoteTagsTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<Uint8List>(
        $NoteTagsTable.$convertercollectionId.toSql(collectionId.value),
      );
    }
    if (noteId.present) {
      map['note_id'] = Variable<Uint8List>(
        $NoteTagsTable.$converternoteId.toSql(noteId.value),
      );
    }
    if (tagId.present) {
      map['tag_id'] = Variable<Uint8List>(
        $NoteTagsTable.$convertertagId.toSql(tagId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('collectionId: $collectionId, ')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyCardTemplatesTable extends StudyCardTemplates
    with TableInfo<$StudyCardTemplatesTable, StudyCardTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyCardTemplatesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($StudyCardTemplatesTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<StudyCardTemplateId, Uint8List>
  id = GeneratedColumn<Uint8List>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  ).withConverter<StudyCardTemplateId>($StudyCardTemplatesTable.$converterid);
  @override
  late final GeneratedColumnWithTypeConverter<NoteTypeId, Uint8List>
  noteTypeId = GeneratedColumn<Uint8List>(
    'note_type_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES note_types (id) ON DELETE CASCADE',
    ),
  ).withConverter<NoteTypeId>($StudyCardTemplatesTable.$converternoteTypeId);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    id,
    noteTypeId,
    position,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_card_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyCardTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyCardTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyCardTemplateRow(
      hlc: $StudyCardTemplatesTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: $StudyCardTemplatesTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      noteTypeId: $StudyCardTemplatesTable.$converternoteTypeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}note_type_id'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $StudyCardTemplatesTable createAlias(String alias) {
    return $StudyCardTemplatesTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<StudyCardTemplateId, Uint8List> $converterid =
      studyCardTemplateIdConverter;
  static TypeConverter<NoteTypeId, Uint8List> $converternoteTypeId =
      noteTypeIdConverter;
}

class StudyCardTemplateRow extends DataClass
    implements Insertable<StudyCardTemplateRow> {
  final Hlc hlc;
  final bool deleted;
  final StudyCardTemplateId id;
  final NoteTypeId noteTypeId;
  final int position;
  final String name;
  const StudyCardTemplateRow({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.noteTypeId,
    required this.position,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>(
        $StudyCardTemplatesTable.$converterhlc.toSql(hlc),
      );
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['id'] = Variable<Uint8List>(
        $StudyCardTemplatesTable.$converterid.toSql(id),
      );
    }
    {
      map['note_type_id'] = Variable<Uint8List>(
        $StudyCardTemplatesTable.$converternoteTypeId.toSql(noteTypeId),
      );
    }
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    return map;
  }

  StudyCardTemplatesCompanion toCompanion(bool nullToAbsent) {
    return StudyCardTemplatesCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      noteTypeId: Value(noteTypeId),
      position: Value(position),
      name: Value(name),
    );
  }

  factory StudyCardTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyCardTemplateRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<StudyCardTemplateId>(json['id']),
      noteTypeId: serializer.fromJson<NoteTypeId>(json['noteTypeId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<StudyCardTemplateId>(id),
      'noteTypeId': serializer.toJson<NoteTypeId>(noteTypeId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
    };
  }

  StudyCardTemplateRow copyWith({
    Hlc? hlc,
    bool? deleted,
    StudyCardTemplateId? id,
    NoteTypeId? noteTypeId,
    int? position,
    String? name,
  }) => StudyCardTemplateRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    noteTypeId: noteTypeId ?? this.noteTypeId,
    position: position ?? this.position,
    name: name ?? this.name,
  );
  StudyCardTemplateRow copyWithCompanion(StudyCardTemplatesCompanion data) {
    return StudyCardTemplateRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      noteTypeId: data.noteTypeId.present
          ? data.noteTypeId.value
          : this.noteTypeId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyCardTemplateRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('noteTypeId: $noteTypeId, ')
          ..write('position: $position, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hlc, deleted, id, noteTypeId, position, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyCardTemplateRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.noteTypeId == this.noteTypeId &&
          other.position == this.position &&
          other.name == this.name);
}

class StudyCardTemplatesCompanion
    extends UpdateCompanion<StudyCardTemplateRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<StudyCardTemplateId> id;
  final Value<NoteTypeId> noteTypeId;
  final Value<int> position;
  final Value<String> name;
  final Value<int> rowid;
  const StudyCardTemplatesCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.noteTypeId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyCardTemplatesCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required StudyCardTemplateId id,
    required NoteTypeId noteTypeId,
    required int position,
    required String name,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       noteTypeId = Value(noteTypeId),
       position = Value(position),
       name = Value(name);
  static Insertable<StudyCardTemplateRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? id,
    Expression<Uint8List>? noteTypeId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (noteTypeId != null) 'note_type_id': noteTypeId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyCardTemplatesCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<StudyCardTemplateId>? id,
    Value<NoteTypeId>? noteTypeId,
    Value<int>? position,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return StudyCardTemplatesCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      noteTypeId: noteTypeId ?? this.noteTypeId,
      position: position ?? this.position,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $StudyCardTemplatesTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $StudyCardTemplatesTable.$converterid.toSql(id.value),
      );
    }
    if (noteTypeId.present) {
      map['note_type_id'] = Variable<Uint8List>(
        $StudyCardTemplatesTable.$converternoteTypeId.toSql(noteTypeId.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyCardTemplatesCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('noteTypeId: $noteTypeId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyCardsTable extends StudyCards
    with TableInfo<$StudyCardsTable, StudyCardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyCardsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($StudyCardsTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<StudyCardId, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<StudyCardId>($StudyCardsTable.$converterid);
  @override
  late final GeneratedColumnWithTypeConverter<CollectionId, Uint8List>
  collectionId = GeneratedColumn<Uint8List>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  ).withConverter<CollectionId>($StudyCardsTable.$convertercollectionId);
  @override
  late final GeneratedColumnWithTypeConverter<NoteId, Uint8List> noteId =
      GeneratedColumn<Uint8List>(
        'note_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<NoteId>($StudyCardsTable.$converternoteId);
  @override
  late final GeneratedColumnWithTypeConverter<StudyCardTemplateId, Uint8List>
  templateId = GeneratedColumn<Uint8List>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_card_templates (id)',
    ),
  ).withConverter<StudyCardTemplateId>($StudyCardsTable.$convertertemplateId);
  @override
  late final GeneratedColumnWithTypeConverter<DeckId, Uint8List> deckId =
      GeneratedColumn<Uint8List>(
        'deck_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<DeckId>($StudyCardsTable.$converterdeckId);
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    id,
    collectionId,
    noteId,
    templateId,
    deckId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyCardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {noteId, templateId},
  ];
  @override
  StudyCardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyCardRow(
      hlc: $StudyCardsTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: $StudyCardsTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      collectionId: $StudyCardsTable.$convertercollectionId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}collection_id'],
        )!,
      ),
      noteId: $StudyCardsTable.$converternoteId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}note_id'],
        )!,
      ),
      templateId: $StudyCardsTable.$convertertemplateId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}template_id'],
        )!,
      ),
      deckId: $StudyCardsTable.$converterdeckId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}deck_id'],
        )!,
      ),
    );
  }

  @override
  $StudyCardsTable createAlias(String alias) {
    return $StudyCardsTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<StudyCardId, Uint8List> $converterid =
      studyCardIdConverter;
  static TypeConverter<CollectionId, Uint8List> $convertercollectionId =
      collectionIdConverter;
  static TypeConverter<NoteId, Uint8List> $converternoteId = noteIdConverter;
  static TypeConverter<StudyCardTemplateId, Uint8List> $convertertemplateId =
      studyCardTemplateIdConverter;
  static TypeConverter<DeckId, Uint8List> $converterdeckId = deckIdConverter;
}

class StudyCardRow extends DataClass implements Insertable<StudyCardRow> {
  final Hlc hlc;
  final bool deleted;
  final StudyCardId id;
  final CollectionId collectionId;
  final NoteId noteId;
  final StudyCardTemplateId templateId;
  final DeckId deckId;
  const StudyCardRow({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.collectionId,
    required this.noteId,
    required this.templateId,
    required this.deckId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>($StudyCardsTable.$converterhlc.toSql(hlc));
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['id'] = Variable<Uint8List>($StudyCardsTable.$converterid.toSql(id));
    }
    {
      map['collection_id'] = Variable<Uint8List>(
        $StudyCardsTable.$convertercollectionId.toSql(collectionId),
      );
    }
    {
      map['note_id'] = Variable<Uint8List>(
        $StudyCardsTable.$converternoteId.toSql(noteId),
      );
    }
    {
      map['template_id'] = Variable<Uint8List>(
        $StudyCardsTable.$convertertemplateId.toSql(templateId),
      );
    }
    {
      map['deck_id'] = Variable<Uint8List>(
        $StudyCardsTable.$converterdeckId.toSql(deckId),
      );
    }
    return map;
  }

  StudyCardsCompanion toCompanion(bool nullToAbsent) {
    return StudyCardsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      collectionId: Value(collectionId),
      noteId: Value(noteId),
      templateId: Value(templateId),
      deckId: Value(deckId),
    );
  }

  factory StudyCardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyCardRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<StudyCardId>(json['id']),
      collectionId: serializer.fromJson<CollectionId>(json['collectionId']),
      noteId: serializer.fromJson<NoteId>(json['noteId']),
      templateId: serializer.fromJson<StudyCardTemplateId>(json['templateId']),
      deckId: serializer.fromJson<DeckId>(json['deckId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<StudyCardId>(id),
      'collectionId': serializer.toJson<CollectionId>(collectionId),
      'noteId': serializer.toJson<NoteId>(noteId),
      'templateId': serializer.toJson<StudyCardTemplateId>(templateId),
      'deckId': serializer.toJson<DeckId>(deckId),
    };
  }

  StudyCardRow copyWith({
    Hlc? hlc,
    bool? deleted,
    StudyCardId? id,
    CollectionId? collectionId,
    NoteId? noteId,
    StudyCardTemplateId? templateId,
    DeckId? deckId,
  }) => StudyCardRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    noteId: noteId ?? this.noteId,
    templateId: templateId ?? this.templateId,
    deckId: deckId ?? this.deckId,
  );
  StudyCardRow copyWithCompanion(StudyCardsCompanion data) {
    return StudyCardRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyCardRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('noteId: $noteId, ')
          ..write('templateId: $templateId, ')
          ..write('deckId: $deckId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(hlc, deleted, id, collectionId, noteId, templateId, deckId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyCardRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.noteId == this.noteId &&
          other.templateId == this.templateId &&
          other.deckId == this.deckId);
}

class StudyCardsCompanion extends UpdateCompanion<StudyCardRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<StudyCardId> id;
  final Value<CollectionId> collectionId;
  final Value<NoteId> noteId;
  final Value<StudyCardTemplateId> templateId;
  final Value<DeckId> deckId;
  final Value<int> rowid;
  const StudyCardsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.deckId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyCardsCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required StudyCardId id,
    required CollectionId collectionId,
    required NoteId noteId,
    required StudyCardTemplateId templateId,
    required DeckId deckId,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       collectionId = Value(collectionId),
       noteId = Value(noteId),
       templateId = Value(templateId),
       deckId = Value(deckId);
  static Insertable<StudyCardRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? id,
    Expression<Uint8List>? collectionId,
    Expression<Uint8List>? noteId,
    Expression<Uint8List>? templateId,
    Expression<Uint8List>? deckId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (noteId != null) 'note_id': noteId,
      if (templateId != null) 'template_id': templateId,
      if (deckId != null) 'deck_id': deckId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyCardsCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<StudyCardId>? id,
    Value<CollectionId>? collectionId,
    Value<NoteId>? noteId,
    Value<StudyCardTemplateId>? templateId,
    Value<DeckId>? deckId,
    Value<int>? rowid,
  }) {
    return StudyCardsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      noteId: noteId ?? this.noteId,
      templateId: templateId ?? this.templateId,
      deckId: deckId ?? this.deckId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $StudyCardsTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $StudyCardsTable.$converterid.toSql(id.value),
      );
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<Uint8List>(
        $StudyCardsTable.$convertercollectionId.toSql(collectionId.value),
      );
    }
    if (noteId.present) {
      map['note_id'] = Variable<Uint8List>(
        $StudyCardsTable.$converternoteId.toSql(noteId.value),
      );
    }
    if (templateId.present) {
      map['template_id'] = Variable<Uint8List>(
        $StudyCardsTable.$convertertemplateId.toSql(templateId.value),
      );
    }
    if (deckId.present) {
      map['deck_id'] = Variable<Uint8List>(
        $StudyCardsTable.$converterdeckId.toSql(deckId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyCardsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('noteId: $noteId, ')
          ..write('templateId: $templateId, ')
          ..write('deckId: $deckId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaAssetsTable extends MediaAssets
    with TableInfo<$MediaAssetsTable, MediaAssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaAssetsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($MediaAssetsTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CollectionId, Uint8List>
  collectionId = GeneratedColumn<Uint8List>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  ).withConverter<CollectionId>($MediaAssetsTable.$convertercollectionId);
  @override
  late final GeneratedColumnWithTypeConverter<ContentHash, Uint8List> hash =
      GeneratedColumn<Uint8List>(
        'hash',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<ContentHash>($MediaAssetsTable.$converterhash);
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    collectionId,
    hash,
    mimeType,
    sizeBytes,
    originalName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaAssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, hash};
  @override
  MediaAssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaAssetRow(
      hlc: $MediaAssetsTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      collectionId: $MediaAssetsTable.$convertercollectionId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}collection_id'],
        )!,
      ),
      hash: $MediaAssetsTable.$converterhash.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}hash'],
        )!,
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      ),
    );
  }

  @override
  $MediaAssetsTable createAlias(String alias) {
    return $MediaAssetsTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<CollectionId, Uint8List> $convertercollectionId =
      collectionIdConverter;
  static TypeConverter<ContentHash, Uint8List> $converterhash =
      const ContentHashConverter();
}

class MediaAssetRow extends DataClass implements Insertable<MediaAssetRow> {
  final Hlc hlc;
  final bool deleted;
  final CollectionId collectionId;
  final ContentHash hash;
  final String mimeType;
  final int sizeBytes;
  final String? originalName;
  const MediaAssetRow({
    required this.hlc,
    required this.deleted,
    required this.collectionId,
    required this.hash,
    required this.mimeType,
    required this.sizeBytes,
    this.originalName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>($MediaAssetsTable.$converterhlc.toSql(hlc));
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['collection_id'] = Variable<Uint8List>(
        $MediaAssetsTable.$convertercollectionId.toSql(collectionId),
      );
    }
    {
      map['hash'] = Variable<Uint8List>(
        $MediaAssetsTable.$converterhash.toSql(hash),
      );
    }
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || originalName != null) {
      map['original_name'] = Variable<String>(originalName);
    }
    return map;
  }

  MediaAssetsCompanion toCompanion(bool nullToAbsent) {
    return MediaAssetsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      collectionId: Value(collectionId),
      hash: Value(hash),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      originalName: originalName == null && nullToAbsent
          ? const Value.absent()
          : Value(originalName),
    );
  }

  factory MediaAssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaAssetRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      collectionId: serializer.fromJson<CollectionId>(json['collectionId']),
      hash: serializer.fromJson<ContentHash>(json['hash']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      originalName: serializer.fromJson<String?>(json['originalName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'collectionId': serializer.toJson<CollectionId>(collectionId),
      'hash': serializer.toJson<ContentHash>(hash),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'originalName': serializer.toJson<String?>(originalName),
    };
  }

  MediaAssetRow copyWith({
    Hlc? hlc,
    bool? deleted,
    CollectionId? collectionId,
    ContentHash? hash,
    String? mimeType,
    int? sizeBytes,
    Value<String?> originalName = const Value.absent(),
  }) => MediaAssetRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    collectionId: collectionId ?? this.collectionId,
    hash: hash ?? this.hash,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    originalName: originalName.present ? originalName.value : this.originalName,
  );
  MediaAssetRow copyWithCompanion(MediaAssetsCompanion data) {
    return MediaAssetRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      hash: data.hash.present ? data.hash.value : this.hash,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('collectionId: $collectionId, ')
          ..write('hash: $hash, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('originalName: $originalName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    hlc,
    deleted,
    collectionId,
    hash,
    mimeType,
    sizeBytes,
    originalName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaAssetRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.collectionId == this.collectionId &&
          other.hash == this.hash &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.originalName == this.originalName);
}

class MediaAssetsCompanion extends UpdateCompanion<MediaAssetRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<CollectionId> collectionId;
  final Value<ContentHash> hash;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<String?> originalName;
  final Value<int> rowid;
  const MediaAssetsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.hash = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.originalName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaAssetsCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required CollectionId collectionId,
    required ContentHash hash,
    required String mimeType,
    required int sizeBytes,
    this.originalName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       collectionId = Value(collectionId),
       hash = Value(hash),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes);
  static Insertable<MediaAssetRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? collectionId,
    Expression<Uint8List>? hash,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<String>? originalName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (collectionId != null) 'collection_id': collectionId,
      if (hash != null) 'hash': hash,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (originalName != null) 'original_name': originalName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaAssetsCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<CollectionId>? collectionId,
    Value<ContentHash>? hash,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<String?>? originalName,
    Value<int>? rowid,
  }) {
    return MediaAssetsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      collectionId: collectionId ?? this.collectionId,
      hash: hash ?? this.hash,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      originalName: originalName ?? this.originalName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $MediaAssetsTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<Uint8List>(
        $MediaAssetsTable.$convertercollectionId.toSql(collectionId.value),
      );
    }
    if (hash.present) {
      map['hash'] = Variable<Uint8List>(
        $MediaAssetsTable.$converterhash.toSql(hash.value),
      );
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaAssetsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('collectionId: $collectionId, ')
          ..write('hash: $hash, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('originalName: $originalName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceTable extends Device with TableInfo<$DeviceTable, DeviceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nodeMeta = const VerificationMeta('node');
  @override
  late final GeneratedColumn<String> node = GeneratedColumn<String>(
    'node',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Hlc?, String> lastHlc =
      GeneratedColumn<String>(
        'last_hlc',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Hlc?>($DeviceTable.$converterlastHlcn);
  @override
  List<GeneratedColumn> get $columns => [id, node, lastHlc];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('node')) {
      context.handle(
        _nodeMeta,
        node.isAcceptableOrUnknown(data['node']!, _nodeMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      node: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node'],
      )!,
      lastHlc: $DeviceTable.$converterlastHlcn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_hlc'],
        ),
      ),
    );
  }

  @override
  $DeviceTable createAlias(String alias) {
    return $DeviceTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterlastHlc = const HlcConverter();
  static TypeConverter<Hlc?, String?> $converterlastHlcn =
      NullAwareTypeConverter.wrap($converterlastHlc);
}

class DeviceRow extends DataClass implements Insertable<DeviceRow> {
  final int id;

  /// The node ID in this device's HLC timestamps.
  final String node;

  /// The latest timestamp issued, so the clock never goes backwards across
  /// restarts.
  final Hlc? lastHlc;
  const DeviceRow({required this.id, required this.node, this.lastHlc});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['node'] = Variable<String>(node);
    if (!nullToAbsent || lastHlc != null) {
      map['last_hlc'] = Variable<String>(
        $DeviceTable.$converterlastHlcn.toSql(lastHlc),
      );
    }
    return map;
  }

  DeviceCompanion toCompanion(bool nullToAbsent) {
    return DeviceCompanion(
      id: Value(id),
      node: Value(node),
      lastHlc: lastHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(lastHlc),
    );
  }

  factory DeviceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceRow(
      id: serializer.fromJson<int>(json['id']),
      node: serializer.fromJson<String>(json['node']),
      lastHlc: serializer.fromJson<Hlc?>(json['lastHlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'node': serializer.toJson<String>(node),
      'lastHlc': serializer.toJson<Hlc?>(lastHlc),
    };
  }

  DeviceRow copyWith({
    int? id,
    String? node,
    Value<Hlc?> lastHlc = const Value.absent(),
  }) => DeviceRow(
    id: id ?? this.id,
    node: node ?? this.node,
    lastHlc: lastHlc.present ? lastHlc.value : this.lastHlc,
  );
  DeviceRow copyWithCompanion(DeviceCompanion data) {
    return DeviceRow(
      id: data.id.present ? data.id.value : this.id,
      node: data.node.present ? data.node.value : this.node,
      lastHlc: data.lastHlc.present ? data.lastHlc.value : this.lastHlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceRow(')
          ..write('id: $id, ')
          ..write('node: $node, ')
          ..write('lastHlc: $lastHlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, node, lastHlc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRow &&
          other.id == this.id &&
          other.node == this.node &&
          other.lastHlc == this.lastHlc);
}

class DeviceCompanion extends UpdateCompanion<DeviceRow> {
  final Value<int> id;
  final Value<String> node;
  final Value<Hlc?> lastHlc;
  const DeviceCompanion({
    this.id = const Value.absent(),
    this.node = const Value.absent(),
    this.lastHlc = const Value.absent(),
  });
  DeviceCompanion.insert({
    this.id = const Value.absent(),
    required String node,
    this.lastHlc = const Value.absent(),
  }) : node = Value(node);
  static Insertable<DeviceRow> custom({
    Expression<int>? id,
    Expression<String>? node,
    Expression<String>? lastHlc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (node != null) 'node': node,
      if (lastHlc != null) 'last_hlc': lastHlc,
    });
  }

  DeviceCompanion copyWith({
    Value<int>? id,
    Value<String>? node,
    Value<Hlc?>? lastHlc,
  }) {
    return DeviceCompanion(
      id: id ?? this.id,
      node: node ?? this.node,
      lastHlc: lastHlc ?? this.lastHlc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (node.present) {
      map['node'] = Variable<String>(node.value);
    }
    if (lastHlc.present) {
      map['last_hlc'] = Variable<String>(
        $DeviceTable.$converterlastHlcn.toSql(lastHlc.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceCompanion(')
          ..write('id: $id, ')
          ..write('node: $node, ')
          ..write('lastHlc: $lastHlc')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<CollectionId, Uint8List>
  collectionId = GeneratedColumn<Uint8List>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  ).withConverter<CollectionId>($OutboxTable.$convertercollectionId);
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityKeyMeta = const VerificationMeta(
    'entityKey',
  );
  @override
  late final GeneratedColumn<Uint8List> entityKey = GeneratedColumn<Uint8List>(
    'entity_key',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($OutboxTable.$converterhlc);
  @override
  List<GeneratedColumn> get $columns => [
    collectionId,
    entityTable,
    entityKey,
    hlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_key')) {
      context.handle(
        _entityKeyMeta,
        entityKey.isAcceptableOrUnknown(data['entity_key']!, _entityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_entityKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityTable, entityKey};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      collectionId: $OutboxTable.$convertercollectionId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}collection_id'],
        )!,
      ),
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}entity_key'],
      )!,
      hlc: $OutboxTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }

  static TypeConverter<CollectionId, Uint8List> $convertercollectionId =
      collectionIdConverter;
  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final CollectionId collectionId;
  final String entityTable;

  /// The entity's primary key; composite keys are their parts' bytes
  /// concatenated.
  final Uint8List entityKey;
  final Hlc hlc;
  const OutboxRow({
    required this.collectionId,
    required this.entityTable,
    required this.entityKey,
    required this.hlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['collection_id'] = Variable<Uint8List>(
        $OutboxTable.$convertercollectionId.toSql(collectionId),
      );
    }
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_key'] = Variable<Uint8List>(entityKey);
    {
      map['hlc'] = Variable<String>($OutboxTable.$converterhlc.toSql(hlc));
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      collectionId: Value(collectionId),
      entityTable: Value(entityTable),
      entityKey: Value(entityKey),
      hlc: Value(hlc),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      collectionId: serializer.fromJson<CollectionId>(json['collectionId']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      entityKey: serializer.fromJson<Uint8List>(json['entityKey']),
      hlc: serializer.fromJson<Hlc>(json['hlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<CollectionId>(collectionId),
      'entityTable': serializer.toJson<String>(entityTable),
      'entityKey': serializer.toJson<Uint8List>(entityKey),
      'hlc': serializer.toJson<Hlc>(hlc),
    };
  }

  OutboxRow copyWith({
    CollectionId? collectionId,
    String? entityTable,
    Uint8List? entityKey,
    Hlc? hlc,
  }) => OutboxRow(
    collectionId: collectionId ?? this.collectionId,
    entityTable: entityTable ?? this.entityTable,
    entityKey: entityKey ?? this.entityKey,
    hlc: hlc ?? this.hlc,
  );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityKey: data.entityKey.present ? data.entityKey.value : this.entityKey,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('collectionId: $collectionId, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityKey: $entityKey, ')
          ..write('hlc: $hlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    collectionId,
    entityTable,
    $driftBlobEquality.hash(entityKey),
    hlc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.collectionId == this.collectionId &&
          other.entityTable == this.entityTable &&
          $driftBlobEquality.equals(other.entityKey, this.entityKey) &&
          other.hlc == this.hlc);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<CollectionId> collectionId;
  final Value<String> entityTable;
  final Value<Uint8List> entityKey;
  final Value<Hlc> hlc;
  final Value<int> rowid;
  const OutboxCompanion({
    this.collectionId = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.entityKey = const Value.absent(),
    this.hlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required CollectionId collectionId,
    required String entityTable,
    required Uint8List entityKey,
    required Hlc hlc,
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       entityTable = Value(entityTable),
       entityKey = Value(entityKey),
       hlc = Value(hlc);
  static Insertable<OutboxRow> custom({
    Expression<Uint8List>? collectionId,
    Expression<String>? entityTable,
    Expression<Uint8List>? entityKey,
    Expression<String>? hlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (entityTable != null) 'entity_table': entityTable,
      if (entityKey != null) 'entity_key': entityKey,
      if (hlc != null) 'hlc': hlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<CollectionId>? collectionId,
    Value<String>? entityTable,
    Value<Uint8List>? entityKey,
    Value<Hlc>? hlc,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      collectionId: collectionId ?? this.collectionId,
      entityTable: entityTable ?? this.entityTable,
      entityKey: entityKey ?? this.entityKey,
      hlc: hlc ?? this.hlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<Uint8List>(
        $OutboxTable.$convertercollectionId.toSql(collectionId.value),
      );
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityKey.present) {
      map['entity_key'] = Variable<Uint8List>(entityKey.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $OutboxTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityKey: $entityKey, ')
          ..write('hlc: $hlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewEventsTable extends ReviewEvents
    with TableInfo<$ReviewEventsTable, ReviewEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewEventsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<ReviewEventId, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<ReviewEventId>($ReviewEventsTable.$converterid);
  @override
  late final GeneratedColumnWithTypeConverter<StudyCardId, Uint8List>
  studyCardId = GeneratedColumn<Uint8List>(
    'study_card_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_cards (id)',
    ),
  ).withConverter<StudyCardId>($ReviewEventsTable.$converterstudyCardId);
  @override
  late final GeneratedColumnWithTypeConverter<ReviewEventKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReviewEventKind>($ReviewEventsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> at =
      GeneratedColumn<int>(
        'at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReviewEventsTable.$converterat);
  @override
  late final GeneratedColumnWithTypeConverter<Grade?, String> grade =
      GeneratedColumn<String>(
        'grade',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Grade?>($ReviewEventsTable.$convertergraden);
  @override
  late final GeneratedColumnWithTypeConverter<Duration?, int> responseTime =
      GeneratedColumn<int>(
        'response_time',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<Duration?>($ReviewEventsTable.$converterresponseTimen);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> dueBefore =
      GeneratedColumn<int>(
        'due_before',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ReviewEventsTable.$converterdueBeforen);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> dueAfter =
      GeneratedColumn<int>(
        'due_after',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ReviewEventsTable.$converterdueAftern);
  @override
  late final GeneratedColumnWithTypeConverter<ReviewEventId?, Uint8List>
  undoneEventId = GeneratedColumn<Uint8List>(
    'undone_event_id',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES review_events (id)',
    ),
  ).withConverter<ReviewEventId?>($ReviewEventsTable.$converterundoneEventIdn);
  static const VerificationMeta _schedulerIdMeta = const VerificationMeta(
    'schedulerId',
  );
  @override
  late final GeneratedColumn<String> schedulerId = GeneratedColumn<String>(
    'scheduler_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schedulerVersionMeta = const VerificationMeta(
    'schedulerVersion',
  );
  @override
  late final GeneratedColumn<int> schedulerVersion = GeneratedColumn<int>(
    'scheduler_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configVersionMeta = const VerificationMeta(
    'configVersion',
  );
  @override
  late final GeneratedColumn<int> configVersion = GeneratedColumn<int>(
    'config_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($ReviewEventsTable.$converterhlc);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studyCardId,
    kind,
    at,
    grade,
    responseTime,
    dueBefore,
    dueAfter,
    undoneEventId,
    schedulerId,
    schedulerVersion,
    configVersion,
    hlc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scheduler_id')) {
      context.handle(
        _schedulerIdMeta,
        schedulerId.isAcceptableOrUnknown(
          data['scheduler_id']!,
          _schedulerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schedulerIdMeta);
    }
    if (data.containsKey('scheduler_version')) {
      context.handle(
        _schedulerVersionMeta,
        schedulerVersion.isAcceptableOrUnknown(
          data['scheduler_version']!,
          _schedulerVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schedulerVersionMeta);
    }
    if (data.containsKey('config_version')) {
      context.handle(
        _configVersionMeta,
        configVersion.isAcceptableOrUnknown(
          data['config_version']!,
          _configVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_configVersionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewEventRow(
      id: $ReviewEventsTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      studyCardId: $ReviewEventsTable.$converterstudyCardId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}study_card_id'],
        )!,
      ),
      kind: $ReviewEventsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      at: $ReviewEventsTable.$converterat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}at'],
        )!,
      ),
      grade: $ReviewEventsTable.$convertergraden.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}grade'],
        ),
      ),
      responseTime: $ReviewEventsTable.$converterresponseTimen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}response_time'],
        ),
      ),
      dueBefore: $ReviewEventsTable.$converterdueBeforen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}due_before'],
        ),
      ),
      dueAfter: $ReviewEventsTable.$converterdueAftern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}due_after'],
        ),
      ),
      undoneEventId: $ReviewEventsTable.$converterundoneEventIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}undone_event_id'],
        ),
      ),
      schedulerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduler_id'],
      )!,
      schedulerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduler_version'],
      )!,
      configVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}config_version'],
      )!,
      hlc: $ReviewEventsTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
    );
  }

  @override
  $ReviewEventsTable createAlias(String alias) {
    return $ReviewEventsTable(attachedDatabase, alias);
  }

  static TypeConverter<ReviewEventId, Uint8List> $converterid =
      reviewEventIdConverter;
  static TypeConverter<StudyCardId, Uint8List> $converterstudyCardId =
      studyCardIdConverter;
  static JsonTypeConverter2<ReviewEventKind, String, String> $converterkind =
      const EnumNameConverter<ReviewEventKind>(ReviewEventKind.values);
  static TypeConverter<DateTime, int> $converterat = const UtcMillisConverter();
  static JsonTypeConverter2<Grade, String, String> $convertergrade =
      const EnumNameConverter<Grade>(Grade.values);
  static JsonTypeConverter2<Grade?, String?, String?> $convertergraden =
      JsonTypeConverter2.asNullable($convertergrade);
  static TypeConverter<Duration, int> $converterresponseTime =
      const DurationMillisConverter();
  static TypeConverter<Duration?, int?> $converterresponseTimen =
      NullAwareTypeConverter.wrap($converterresponseTime);
  static TypeConverter<DateTime, int> $converterdueBefore =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $converterdueBeforen =
      NullAwareTypeConverter.wrap($converterdueBefore);
  static TypeConverter<DateTime, int> $converterdueAfter =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $converterdueAftern =
      NullAwareTypeConverter.wrap($converterdueAfter);
  static TypeConverter<ReviewEventId, Uint8List> $converterundoneEventId =
      reviewEventIdConverter;
  static TypeConverter<ReviewEventId?, Uint8List?> $converterundoneEventIdn =
      NullAwareTypeConverter.wrap($converterundoneEventId);
  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
}

class ReviewEventRow extends DataClass implements Insertable<ReviewEventRow> {
  final ReviewEventId id;
  final StudyCardId studyCardId;
  final ReviewEventKind kind;
  final DateTime at;
  final Grade? grade;
  final Duration? responseTime;
  final DateTime? dueBefore;
  final DateTime? dueAfter;
  final ReviewEventId? undoneEventId;
  final String schedulerId;
  final int schedulerVersion;
  final int configVersion;
  final Hlc hlc;
  const ReviewEventRow({
    required this.id,
    required this.studyCardId,
    required this.kind,
    required this.at,
    this.grade,
    this.responseTime,
    this.dueBefore,
    this.dueAfter,
    this.undoneEventId,
    required this.schedulerId,
    required this.schedulerVersion,
    required this.configVersion,
    required this.hlc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['id'] = Variable<Uint8List>(
        $ReviewEventsTable.$converterid.toSql(id),
      );
    }
    {
      map['study_card_id'] = Variable<Uint8List>(
        $ReviewEventsTable.$converterstudyCardId.toSql(studyCardId),
      );
    }
    {
      map['kind'] = Variable<String>(
        $ReviewEventsTable.$converterkind.toSql(kind),
      );
    }
    {
      map['at'] = Variable<int>($ReviewEventsTable.$converterat.toSql(at));
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(
        $ReviewEventsTable.$convertergraden.toSql(grade),
      );
    }
    if (!nullToAbsent || responseTime != null) {
      map['response_time'] = Variable<int>(
        $ReviewEventsTable.$converterresponseTimen.toSql(responseTime),
      );
    }
    if (!nullToAbsent || dueBefore != null) {
      map['due_before'] = Variable<int>(
        $ReviewEventsTable.$converterdueBeforen.toSql(dueBefore),
      );
    }
    if (!nullToAbsent || dueAfter != null) {
      map['due_after'] = Variable<int>(
        $ReviewEventsTable.$converterdueAftern.toSql(dueAfter),
      );
    }
    if (!nullToAbsent || undoneEventId != null) {
      map['undone_event_id'] = Variable<Uint8List>(
        $ReviewEventsTable.$converterundoneEventIdn.toSql(undoneEventId),
      );
    }
    map['scheduler_id'] = Variable<String>(schedulerId);
    map['scheduler_version'] = Variable<int>(schedulerVersion);
    map['config_version'] = Variable<int>(configVersion);
    {
      map['hlc'] = Variable<String>(
        $ReviewEventsTable.$converterhlc.toSql(hlc),
      );
    }
    return map;
  }

  ReviewEventsCompanion toCompanion(bool nullToAbsent) {
    return ReviewEventsCompanion(
      id: Value(id),
      studyCardId: Value(studyCardId),
      kind: Value(kind),
      at: Value(at),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      responseTime: responseTime == null && nullToAbsent
          ? const Value.absent()
          : Value(responseTime),
      dueBefore: dueBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(dueBefore),
      dueAfter: dueAfter == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAfter),
      undoneEventId: undoneEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(undoneEventId),
      schedulerId: Value(schedulerId),
      schedulerVersion: Value(schedulerVersion),
      configVersion: Value(configVersion),
      hlc: Value(hlc),
    );
  }

  factory ReviewEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewEventRow(
      id: serializer.fromJson<ReviewEventId>(json['id']),
      studyCardId: serializer.fromJson<StudyCardId>(json['studyCardId']),
      kind: $ReviewEventsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      at: serializer.fromJson<DateTime>(json['at']),
      grade: $ReviewEventsTable.$convertergraden.fromJson(
        serializer.fromJson<String?>(json['grade']),
      ),
      responseTime: serializer.fromJson<Duration?>(json['responseTime']),
      dueBefore: serializer.fromJson<DateTime?>(json['dueBefore']),
      dueAfter: serializer.fromJson<DateTime?>(json['dueAfter']),
      undoneEventId: serializer.fromJson<ReviewEventId?>(json['undoneEventId']),
      schedulerId: serializer.fromJson<String>(json['schedulerId']),
      schedulerVersion: serializer.fromJson<int>(json['schedulerVersion']),
      configVersion: serializer.fromJson<int>(json['configVersion']),
      hlc: serializer.fromJson<Hlc>(json['hlc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<ReviewEventId>(id),
      'studyCardId': serializer.toJson<StudyCardId>(studyCardId),
      'kind': serializer.toJson<String>(
        $ReviewEventsTable.$converterkind.toJson(kind),
      ),
      'at': serializer.toJson<DateTime>(at),
      'grade': serializer.toJson<String?>(
        $ReviewEventsTable.$convertergraden.toJson(grade),
      ),
      'responseTime': serializer.toJson<Duration?>(responseTime),
      'dueBefore': serializer.toJson<DateTime?>(dueBefore),
      'dueAfter': serializer.toJson<DateTime?>(dueAfter),
      'undoneEventId': serializer.toJson<ReviewEventId?>(undoneEventId),
      'schedulerId': serializer.toJson<String>(schedulerId),
      'schedulerVersion': serializer.toJson<int>(schedulerVersion),
      'configVersion': serializer.toJson<int>(configVersion),
      'hlc': serializer.toJson<Hlc>(hlc),
    };
  }

  ReviewEventRow copyWith({
    ReviewEventId? id,
    StudyCardId? studyCardId,
    ReviewEventKind? kind,
    DateTime? at,
    Value<Grade?> grade = const Value.absent(),
    Value<Duration?> responseTime = const Value.absent(),
    Value<DateTime?> dueBefore = const Value.absent(),
    Value<DateTime?> dueAfter = const Value.absent(),
    Value<ReviewEventId?> undoneEventId = const Value.absent(),
    String? schedulerId,
    int? schedulerVersion,
    int? configVersion,
    Hlc? hlc,
  }) => ReviewEventRow(
    id: id ?? this.id,
    studyCardId: studyCardId ?? this.studyCardId,
    kind: kind ?? this.kind,
    at: at ?? this.at,
    grade: grade.present ? grade.value : this.grade,
    responseTime: responseTime.present ? responseTime.value : this.responseTime,
    dueBefore: dueBefore.present ? dueBefore.value : this.dueBefore,
    dueAfter: dueAfter.present ? dueAfter.value : this.dueAfter,
    undoneEventId: undoneEventId.present
        ? undoneEventId.value
        : this.undoneEventId,
    schedulerId: schedulerId ?? this.schedulerId,
    schedulerVersion: schedulerVersion ?? this.schedulerVersion,
    configVersion: configVersion ?? this.configVersion,
    hlc: hlc ?? this.hlc,
  );
  ReviewEventRow copyWithCompanion(ReviewEventsCompanion data) {
    return ReviewEventRow(
      id: data.id.present ? data.id.value : this.id,
      studyCardId: data.studyCardId.present
          ? data.studyCardId.value
          : this.studyCardId,
      kind: data.kind.present ? data.kind.value : this.kind,
      at: data.at.present ? data.at.value : this.at,
      grade: data.grade.present ? data.grade.value : this.grade,
      responseTime: data.responseTime.present
          ? data.responseTime.value
          : this.responseTime,
      dueBefore: data.dueBefore.present ? data.dueBefore.value : this.dueBefore,
      dueAfter: data.dueAfter.present ? data.dueAfter.value : this.dueAfter,
      undoneEventId: data.undoneEventId.present
          ? data.undoneEventId.value
          : this.undoneEventId,
      schedulerId: data.schedulerId.present
          ? data.schedulerId.value
          : this.schedulerId,
      schedulerVersion: data.schedulerVersion.present
          ? data.schedulerVersion.value
          : this.schedulerVersion,
      configVersion: data.configVersion.present
          ? data.configVersion.value
          : this.configVersion,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewEventRow(')
          ..write('id: $id, ')
          ..write('studyCardId: $studyCardId, ')
          ..write('kind: $kind, ')
          ..write('at: $at, ')
          ..write('grade: $grade, ')
          ..write('responseTime: $responseTime, ')
          ..write('dueBefore: $dueBefore, ')
          ..write('dueAfter: $dueAfter, ')
          ..write('undoneEventId: $undoneEventId, ')
          ..write('schedulerId: $schedulerId, ')
          ..write('schedulerVersion: $schedulerVersion, ')
          ..write('configVersion: $configVersion, ')
          ..write('hlc: $hlc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studyCardId,
    kind,
    at,
    grade,
    responseTime,
    dueBefore,
    dueAfter,
    undoneEventId,
    schedulerId,
    schedulerVersion,
    configVersion,
    hlc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewEventRow &&
          other.id == this.id &&
          other.studyCardId == this.studyCardId &&
          other.kind == this.kind &&
          other.at == this.at &&
          other.grade == this.grade &&
          other.responseTime == this.responseTime &&
          other.dueBefore == this.dueBefore &&
          other.dueAfter == this.dueAfter &&
          other.undoneEventId == this.undoneEventId &&
          other.schedulerId == this.schedulerId &&
          other.schedulerVersion == this.schedulerVersion &&
          other.configVersion == this.configVersion &&
          other.hlc == this.hlc);
}

class ReviewEventsCompanion extends UpdateCompanion<ReviewEventRow> {
  final Value<ReviewEventId> id;
  final Value<StudyCardId> studyCardId;
  final Value<ReviewEventKind> kind;
  final Value<DateTime> at;
  final Value<Grade?> grade;
  final Value<Duration?> responseTime;
  final Value<DateTime?> dueBefore;
  final Value<DateTime?> dueAfter;
  final Value<ReviewEventId?> undoneEventId;
  final Value<String> schedulerId;
  final Value<int> schedulerVersion;
  final Value<int> configVersion;
  final Value<Hlc> hlc;
  final Value<int> rowid;
  const ReviewEventsCompanion({
    this.id = const Value.absent(),
    this.studyCardId = const Value.absent(),
    this.kind = const Value.absent(),
    this.at = const Value.absent(),
    this.grade = const Value.absent(),
    this.responseTime = const Value.absent(),
    this.dueBefore = const Value.absent(),
    this.dueAfter = const Value.absent(),
    this.undoneEventId = const Value.absent(),
    this.schedulerId = const Value.absent(),
    this.schedulerVersion = const Value.absent(),
    this.configVersion = const Value.absent(),
    this.hlc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewEventsCompanion.insert({
    required ReviewEventId id,
    required StudyCardId studyCardId,
    required ReviewEventKind kind,
    required DateTime at,
    this.grade = const Value.absent(),
    this.responseTime = const Value.absent(),
    this.dueBefore = const Value.absent(),
    this.dueAfter = const Value.absent(),
    this.undoneEventId = const Value.absent(),
    required String schedulerId,
    required int schedulerVersion,
    required int configVersion,
    required Hlc hlc,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       studyCardId = Value(studyCardId),
       kind = Value(kind),
       at = Value(at),
       schedulerId = Value(schedulerId),
       schedulerVersion = Value(schedulerVersion),
       configVersion = Value(configVersion),
       hlc = Value(hlc);
  static Insertable<ReviewEventRow> custom({
    Expression<Uint8List>? id,
    Expression<Uint8List>? studyCardId,
    Expression<String>? kind,
    Expression<int>? at,
    Expression<String>? grade,
    Expression<int>? responseTime,
    Expression<int>? dueBefore,
    Expression<int>? dueAfter,
    Expression<Uint8List>? undoneEventId,
    Expression<String>? schedulerId,
    Expression<int>? schedulerVersion,
    Expression<int>? configVersion,
    Expression<String>? hlc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studyCardId != null) 'study_card_id': studyCardId,
      if (kind != null) 'kind': kind,
      if (at != null) 'at': at,
      if (grade != null) 'grade': grade,
      if (responseTime != null) 'response_time': responseTime,
      if (dueBefore != null) 'due_before': dueBefore,
      if (dueAfter != null) 'due_after': dueAfter,
      if (undoneEventId != null) 'undone_event_id': undoneEventId,
      if (schedulerId != null) 'scheduler_id': schedulerId,
      if (schedulerVersion != null) 'scheduler_version': schedulerVersion,
      if (configVersion != null) 'config_version': configVersion,
      if (hlc != null) 'hlc': hlc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewEventsCompanion copyWith({
    Value<ReviewEventId>? id,
    Value<StudyCardId>? studyCardId,
    Value<ReviewEventKind>? kind,
    Value<DateTime>? at,
    Value<Grade?>? grade,
    Value<Duration?>? responseTime,
    Value<DateTime?>? dueBefore,
    Value<DateTime?>? dueAfter,
    Value<ReviewEventId?>? undoneEventId,
    Value<String>? schedulerId,
    Value<int>? schedulerVersion,
    Value<int>? configVersion,
    Value<Hlc>? hlc,
    Value<int>? rowid,
  }) {
    return ReviewEventsCompanion(
      id: id ?? this.id,
      studyCardId: studyCardId ?? this.studyCardId,
      kind: kind ?? this.kind,
      at: at ?? this.at,
      grade: grade ?? this.grade,
      responseTime: responseTime ?? this.responseTime,
      dueBefore: dueBefore ?? this.dueBefore,
      dueAfter: dueAfter ?? this.dueAfter,
      undoneEventId: undoneEventId ?? this.undoneEventId,
      schedulerId: schedulerId ?? this.schedulerId,
      schedulerVersion: schedulerVersion ?? this.schedulerVersion,
      configVersion: configVersion ?? this.configVersion,
      hlc: hlc ?? this.hlc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $ReviewEventsTable.$converterid.toSql(id.value),
      );
    }
    if (studyCardId.present) {
      map['study_card_id'] = Variable<Uint8List>(
        $ReviewEventsTable.$converterstudyCardId.toSql(studyCardId.value),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ReviewEventsTable.$converterkind.toSql(kind.value),
      );
    }
    if (at.present) {
      map['at'] = Variable<int>(
        $ReviewEventsTable.$converterat.toSql(at.value),
      );
    }
    if (grade.present) {
      map['grade'] = Variable<String>(
        $ReviewEventsTable.$convertergraden.toSql(grade.value),
      );
    }
    if (responseTime.present) {
      map['response_time'] = Variable<int>(
        $ReviewEventsTable.$converterresponseTimen.toSql(responseTime.value),
      );
    }
    if (dueBefore.present) {
      map['due_before'] = Variable<int>(
        $ReviewEventsTable.$converterdueBeforen.toSql(dueBefore.value),
      );
    }
    if (dueAfter.present) {
      map['due_after'] = Variable<int>(
        $ReviewEventsTable.$converterdueAftern.toSql(dueAfter.value),
      );
    }
    if (undoneEventId.present) {
      map['undone_event_id'] = Variable<Uint8List>(
        $ReviewEventsTable.$converterundoneEventIdn.toSql(undoneEventId.value),
      );
    }
    if (schedulerId.present) {
      map['scheduler_id'] = Variable<String>(schedulerId.value);
    }
    if (schedulerVersion.present) {
      map['scheduler_version'] = Variable<int>(schedulerVersion.value);
    }
    if (configVersion.present) {
      map['config_version'] = Variable<int>(configVersion.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $ReviewEventsTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewEventsCompanion(')
          ..write('id: $id, ')
          ..write('studyCardId: $studyCardId, ')
          ..write('kind: $kind, ')
          ..write('at: $at, ')
          ..write('grade: $grade, ')
          ..write('responseTime: $responseTime, ')
          ..write('dueBefore: $dueBefore, ')
          ..write('dueAfter: $dueAfter, ')
          ..write('undoneEventId: $undoneEventId, ')
          ..write('schedulerId: $schedulerId, ')
          ..write('schedulerVersion: $schedulerVersion, ')
          ..write('configVersion: $configVersion, ')
          ..write('hlc: $hlc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchedulingStatesTable extends SchedulingStates
    with TableInfo<$SchedulingStatesTable, SchedulingStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulingStatesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<StudyCardId, Uint8List>
  studyCardId = GeneratedColumn<Uint8List>(
    'study_card_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES study_cards (id) ON DELETE CASCADE',
    ),
  ).withConverter<StudyCardId>($SchedulingStatesTable.$converterstudyCardId);
  @override
  late final GeneratedColumnWithTypeConverter<StudyCardState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<StudyCardState>($SchedulingStatesTable.$converterstate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> due =
      GeneratedColumn<int>(
        'due',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($SchedulingStatesTable.$converterduen);
  @override
  late final GeneratedColumnWithTypeConverter<Duration, int> interval =
      GeneratedColumn<int>(
        'interval',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Duration>($SchedulingStatesTable.$converterinterval);
  static const VerificationMeta _easeMeta = const VerificationMeta('ease');
  @override
  late final GeneratedColumn<double> ease = GeneratedColumn<double>(
    'ease',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepMeta = const VerificationMeta('step');
  @override
  late final GeneratedColumn<int> step = GeneratedColumn<int>(
    'step',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReviewEventId?, Uint8List>
  lastEventId =
      GeneratedColumn<Uint8List>(
        'last_event_id',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES review_events (id)',
        ),
      ).withConverter<ReviewEventId?>(
        $SchedulingStatesTable.$converterlastEventIdn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    studyCardId,
    state,
    due,
    interval,
    ease,
    step,
    lapses,
    reviewCount,
    lastEventId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduling_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchedulingStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ease')) {
      context.handle(
        _easeMeta,
        ease.isAcceptableOrUnknown(data['ease']!, _easeMeta),
      );
    }
    if (data.containsKey('step')) {
      context.handle(
        _stepMeta,
        step.isAcceptableOrUnknown(data['step']!, _stepMeta),
      );
    } else if (isInserting) {
      context.missing(_stepMeta);
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    } else if (isInserting) {
      context.missing(_lapsesMeta);
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reviewCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studyCardId};
  @override
  SchedulingStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchedulingStateRow(
      studyCardId: $SchedulingStatesTable.$converterstudyCardId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}study_card_id'],
        )!,
      ),
      state: $SchedulingStatesTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      due: $SchedulingStatesTable.$converterduen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}due'],
        ),
      ),
      interval: $SchedulingStatesTable.$converterinterval.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}interval'],
        )!,
      ),
      ease: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease'],
      ),
      step: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
      lastEventId: $SchedulingStatesTable.$converterlastEventIdn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}last_event_id'],
        ),
      ),
    );
  }

  @override
  $SchedulingStatesTable createAlias(String alias) {
    return $SchedulingStatesTable(attachedDatabase, alias);
  }

  static TypeConverter<StudyCardId, Uint8List> $converterstudyCardId =
      studyCardIdConverter;
  static JsonTypeConverter2<StudyCardState, String, String> $converterstate =
      const EnumNameConverter<StudyCardState>(StudyCardState.values);
  static TypeConverter<DateTime, int> $converterdue =
      const UtcMillisConverter();
  static TypeConverter<DateTime?, int?> $converterduen =
      NullAwareTypeConverter.wrap($converterdue);
  static TypeConverter<Duration, int> $converterinterval =
      const DurationMillisConverter();
  static TypeConverter<ReviewEventId, Uint8List> $converterlastEventId =
      reviewEventIdConverter;
  static TypeConverter<ReviewEventId?, Uint8List?> $converterlastEventIdn =
      NullAwareTypeConverter.wrap($converterlastEventId);
}

class SchedulingStateRow extends DataClass
    implements Insertable<SchedulingStateRow> {
  final StudyCardId studyCardId;
  final StudyCardState state;
  final DateTime? due;
  final Duration interval;
  final double? ease;
  final int step;
  final int lapses;
  final int reviewCount;
  final ReviewEventId? lastEventId;
  const SchedulingStateRow({
    required this.studyCardId,
    required this.state,
    this.due,
    required this.interval,
    this.ease,
    required this.step,
    required this.lapses,
    required this.reviewCount,
    this.lastEventId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['study_card_id'] = Variable<Uint8List>(
        $SchedulingStatesTable.$converterstudyCardId.toSql(studyCardId),
      );
    }
    {
      map['state'] = Variable<String>(
        $SchedulingStatesTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || due != null) {
      map['due'] = Variable<int>(
        $SchedulingStatesTable.$converterduen.toSql(due),
      );
    }
    {
      map['interval'] = Variable<int>(
        $SchedulingStatesTable.$converterinterval.toSql(interval),
      );
    }
    if (!nullToAbsent || ease != null) {
      map['ease'] = Variable<double>(ease);
    }
    map['step'] = Variable<int>(step);
    map['lapses'] = Variable<int>(lapses);
    map['review_count'] = Variable<int>(reviewCount);
    if (!nullToAbsent || lastEventId != null) {
      map['last_event_id'] = Variable<Uint8List>(
        $SchedulingStatesTable.$converterlastEventIdn.toSql(lastEventId),
      );
    }
    return map;
  }

  SchedulingStatesCompanion toCompanion(bool nullToAbsent) {
    return SchedulingStatesCompanion(
      studyCardId: Value(studyCardId),
      state: Value(state),
      due: due == null && nullToAbsent ? const Value.absent() : Value(due),
      interval: Value(interval),
      ease: ease == null && nullToAbsent ? const Value.absent() : Value(ease),
      step: Value(step),
      lapses: Value(lapses),
      reviewCount: Value(reviewCount),
      lastEventId: lastEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEventId),
    );
  }

  factory SchedulingStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchedulingStateRow(
      studyCardId: serializer.fromJson<StudyCardId>(json['studyCardId']),
      state: $SchedulingStatesTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      due: serializer.fromJson<DateTime?>(json['due']),
      interval: serializer.fromJson<Duration>(json['interval']),
      ease: serializer.fromJson<double?>(json['ease']),
      step: serializer.fromJson<int>(json['step']),
      lapses: serializer.fromJson<int>(json['lapses']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      lastEventId: serializer.fromJson<ReviewEventId?>(json['lastEventId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studyCardId': serializer.toJson<StudyCardId>(studyCardId),
      'state': serializer.toJson<String>(
        $SchedulingStatesTable.$converterstate.toJson(state),
      ),
      'due': serializer.toJson<DateTime?>(due),
      'interval': serializer.toJson<Duration>(interval),
      'ease': serializer.toJson<double?>(ease),
      'step': serializer.toJson<int>(step),
      'lapses': serializer.toJson<int>(lapses),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'lastEventId': serializer.toJson<ReviewEventId?>(lastEventId),
    };
  }

  SchedulingStateRow copyWith({
    StudyCardId? studyCardId,
    StudyCardState? state,
    Value<DateTime?> due = const Value.absent(),
    Duration? interval,
    Value<double?> ease = const Value.absent(),
    int? step,
    int? lapses,
    int? reviewCount,
    Value<ReviewEventId?> lastEventId = const Value.absent(),
  }) => SchedulingStateRow(
    studyCardId: studyCardId ?? this.studyCardId,
    state: state ?? this.state,
    due: due.present ? due.value : this.due,
    interval: interval ?? this.interval,
    ease: ease.present ? ease.value : this.ease,
    step: step ?? this.step,
    lapses: lapses ?? this.lapses,
    reviewCount: reviewCount ?? this.reviewCount,
    lastEventId: lastEventId.present ? lastEventId.value : this.lastEventId,
  );
  SchedulingStateRow copyWithCompanion(SchedulingStatesCompanion data) {
    return SchedulingStateRow(
      studyCardId: data.studyCardId.present
          ? data.studyCardId.value
          : this.studyCardId,
      state: data.state.present ? data.state.value : this.state,
      due: data.due.present ? data.due.value : this.due,
      interval: data.interval.present ? data.interval.value : this.interval,
      ease: data.ease.present ? data.ease.value : this.ease,
      step: data.step.present ? data.step.value : this.step,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
      lastEventId: data.lastEventId.present
          ? data.lastEventId.value
          : this.lastEventId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchedulingStateRow(')
          ..write('studyCardId: $studyCardId, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('interval: $interval, ')
          ..write('ease: $ease, ')
          ..write('step: $step, ')
          ..write('lapses: $lapses, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('lastEventId: $lastEventId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    studyCardId,
    state,
    due,
    interval,
    ease,
    step,
    lapses,
    reviewCount,
    lastEventId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchedulingStateRow &&
          other.studyCardId == this.studyCardId &&
          other.state == this.state &&
          other.due == this.due &&
          other.interval == this.interval &&
          other.ease == this.ease &&
          other.step == this.step &&
          other.lapses == this.lapses &&
          other.reviewCount == this.reviewCount &&
          other.lastEventId == this.lastEventId);
}

class SchedulingStatesCompanion extends UpdateCompanion<SchedulingStateRow> {
  final Value<StudyCardId> studyCardId;
  final Value<StudyCardState> state;
  final Value<DateTime?> due;
  final Value<Duration> interval;
  final Value<double?> ease;
  final Value<int> step;
  final Value<int> lapses;
  final Value<int> reviewCount;
  final Value<ReviewEventId?> lastEventId;
  final Value<int> rowid;
  const SchedulingStatesCompanion({
    this.studyCardId = const Value.absent(),
    this.state = const Value.absent(),
    this.due = const Value.absent(),
    this.interval = const Value.absent(),
    this.ease = const Value.absent(),
    this.step = const Value.absent(),
    this.lapses = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.lastEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchedulingStatesCompanion.insert({
    required StudyCardId studyCardId,
    required StudyCardState state,
    this.due = const Value.absent(),
    required Duration interval,
    this.ease = const Value.absent(),
    required int step,
    required int lapses,
    required int reviewCount,
    this.lastEventId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : studyCardId = Value(studyCardId),
       state = Value(state),
       interval = Value(interval),
       step = Value(step),
       lapses = Value(lapses),
       reviewCount = Value(reviewCount);
  static Insertable<SchedulingStateRow> custom({
    Expression<Uint8List>? studyCardId,
    Expression<String>? state,
    Expression<int>? due,
    Expression<int>? interval,
    Expression<double>? ease,
    Expression<int>? step,
    Expression<int>? lapses,
    Expression<int>? reviewCount,
    Expression<Uint8List>? lastEventId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (studyCardId != null) 'study_card_id': studyCardId,
      if (state != null) 'state': state,
      if (due != null) 'due': due,
      if (interval != null) 'interval': interval,
      if (ease != null) 'ease': ease,
      if (step != null) 'step': step,
      if (lapses != null) 'lapses': lapses,
      if (reviewCount != null) 'review_count': reviewCount,
      if (lastEventId != null) 'last_event_id': lastEventId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchedulingStatesCompanion copyWith({
    Value<StudyCardId>? studyCardId,
    Value<StudyCardState>? state,
    Value<DateTime?>? due,
    Value<Duration>? interval,
    Value<double?>? ease,
    Value<int>? step,
    Value<int>? lapses,
    Value<int>? reviewCount,
    Value<ReviewEventId?>? lastEventId,
    Value<int>? rowid,
  }) {
    return SchedulingStatesCompanion(
      studyCardId: studyCardId ?? this.studyCardId,
      state: state ?? this.state,
      due: due ?? this.due,
      interval: interval ?? this.interval,
      ease: ease ?? this.ease,
      step: step ?? this.step,
      lapses: lapses ?? this.lapses,
      reviewCount: reviewCount ?? this.reviewCount,
      lastEventId: lastEventId ?? this.lastEventId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studyCardId.present) {
      map['study_card_id'] = Variable<Uint8List>(
        $SchedulingStatesTable.$converterstudyCardId.toSql(studyCardId.value),
      );
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $SchedulingStatesTable.$converterstate.toSql(state.value),
      );
    }
    if (due.present) {
      map['due'] = Variable<int>(
        $SchedulingStatesTable.$converterduen.toSql(due.value),
      );
    }
    if (interval.present) {
      map['interval'] = Variable<int>(
        $SchedulingStatesTable.$converterinterval.toSql(interval.value),
      );
    }
    if (ease.present) {
      map['ease'] = Variable<double>(ease.value);
    }
    if (step.present) {
      map['step'] = Variable<int>(step.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (lastEventId.present) {
      map['last_event_id'] = Variable<Uint8List>(
        $SchedulingStatesTable.$converterlastEventIdn.toSql(lastEventId.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulingStatesCompanion(')
          ..write('studyCardId: $studyCardId, ')
          ..write('state: $state, ')
          ..write('due: $due, ')
          ..write('interval: $interval, ')
          ..write('ease: $ease, ')
          ..write('step: $step, ')
          ..write('lapses: $lapses, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('lastEventId: $lastEventId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FieldDefinitionsTable extends FieldDefinitions
    with TableInfo<$FieldDefinitionsTable, FieldDefinitionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldDefinitionsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($FieldDefinitionsTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FieldDefinitionId, Uint8List> id =
      GeneratedColumn<Uint8List>(
        'id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      ).withConverter<FieldDefinitionId>($FieldDefinitionsTable.$converterid);
  @override
  late final GeneratedColumnWithTypeConverter<NoteTypeId, Uint8List>
  noteTypeId = GeneratedColumn<Uint8List>(
    'note_type_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES note_types (id) ON DELETE CASCADE',
    ),
  ).withConverter<NoteTypeId>($FieldDefinitionsTable.$converternoteTypeId);
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FieldType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FieldType>($FieldDefinitionsTable.$convertertype);
  @override
  List<GeneratedColumn> get $columns => [
    hlc,
    deleted,
    id,
    noteTypeId,
    position,
    name,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FieldDefinitionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FieldDefinitionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldDefinitionRow(
      hlc: $FieldDefinitionsTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: $FieldDefinitionsTable.$converterid.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}id'],
        )!,
      ),
      noteTypeId: $FieldDefinitionsTable.$converternoteTypeId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}note_type_id'],
        )!,
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $FieldDefinitionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
    );
  }

  @override
  $FieldDefinitionsTable createAlias(String alias) {
    return $FieldDefinitionsTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<FieldDefinitionId, Uint8List> $converterid =
      fieldDefinitionIdConverter;
  static TypeConverter<NoteTypeId, Uint8List> $converternoteTypeId =
      noteTypeIdConverter;
  static JsonTypeConverter2<FieldType, String, String> $convertertype =
      const EnumNameConverter<FieldType>(FieldType.values);
}

class FieldDefinitionRow extends DataClass
    implements Insertable<FieldDefinitionRow> {
  final Hlc hlc;
  final bool deleted;
  final FieldDefinitionId id;
  final NoteTypeId noteTypeId;
  final int position;
  final String name;
  final FieldType type;
  const FieldDefinitionRow({
    required this.hlc,
    required this.deleted,
    required this.id,
    required this.noteTypeId,
    required this.position,
    required this.name,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>(
        $FieldDefinitionsTable.$converterhlc.toSql(hlc),
      );
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['id'] = Variable<Uint8List>(
        $FieldDefinitionsTable.$converterid.toSql(id),
      );
    }
    {
      map['note_type_id'] = Variable<Uint8List>(
        $FieldDefinitionsTable.$converternoteTypeId.toSql(noteTypeId),
      );
    }
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>(
        $FieldDefinitionsTable.$convertertype.toSql(type),
      );
    }
    return map;
  }

  FieldDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return FieldDefinitionsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      id: Value(id),
      noteTypeId: Value(noteTypeId),
      position: Value(position),
      name: Value(name),
      type: Value(type),
    );
  }

  factory FieldDefinitionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldDefinitionRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<FieldDefinitionId>(json['id']),
      noteTypeId: serializer.fromJson<NoteTypeId>(json['noteTypeId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
      type: $FieldDefinitionsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<FieldDefinitionId>(id),
      'noteTypeId': serializer.toJson<NoteTypeId>(noteTypeId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $FieldDefinitionsTable.$convertertype.toJson(type),
      ),
    };
  }

  FieldDefinitionRow copyWith({
    Hlc? hlc,
    bool? deleted,
    FieldDefinitionId? id,
    NoteTypeId? noteTypeId,
    int? position,
    String? name,
    FieldType? type,
  }) => FieldDefinitionRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    noteTypeId: noteTypeId ?? this.noteTypeId,
    position: position ?? this.position,
    name: name ?? this.name,
    type: type ?? this.type,
  );
  FieldDefinitionRow copyWithCompanion(FieldDefinitionsCompanion data) {
    return FieldDefinitionRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      noteTypeId: data.noteTypeId.present
          ? data.noteTypeId.value
          : this.noteTypeId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldDefinitionRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('noteTypeId: $noteTypeId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(hlc, deleted, id, noteTypeId, position, name, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldDefinitionRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.noteTypeId == this.noteTypeId &&
          other.position == this.position &&
          other.name == this.name &&
          other.type == this.type);
}

class FieldDefinitionsCompanion extends UpdateCompanion<FieldDefinitionRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<FieldDefinitionId> id;
  final Value<NoteTypeId> noteTypeId;
  final Value<int> position;
  final Value<String> name;
  final Value<FieldType> type;
  final Value<int> rowid;
  const FieldDefinitionsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.noteTypeId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldDefinitionsCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required FieldDefinitionId id,
    required NoteTypeId noteTypeId,
    required int position,
    required String name,
    required FieldType type,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       id = Value(id),
       noteTypeId = Value(noteTypeId),
       position = Value(position),
       name = Value(name),
       type = Value(type);
  static Insertable<FieldDefinitionRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? id,
    Expression<Uint8List>? noteTypeId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (noteTypeId != null) 'note_type_id': noteTypeId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldDefinitionsCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<FieldDefinitionId>? id,
    Value<NoteTypeId>? noteTypeId,
    Value<int>? position,
    Value<String>? name,
    Value<FieldType>? type,
    Value<int>? rowid,
  }) {
    return FieldDefinitionsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      noteTypeId: noteTypeId ?? this.noteTypeId,
      position: position ?? this.position,
      name: name ?? this.name,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $FieldDefinitionsTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<Uint8List>(
        $FieldDefinitionsTable.$converterid.toSql(id.value),
      );
    }
    if (noteTypeId.present) {
      map['note_type_id'] = Variable<Uint8List>(
        $FieldDefinitionsTable.$converternoteTypeId.toSql(noteTypeId.value),
      );
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $FieldDefinitionsTable.$convertertype.toSql(type.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldDefinitionsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('noteTypeId: $noteTypeId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteFieldsTable extends NoteFields
    with TableInfo<$NoteFieldsTable, NoteFieldRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteFieldsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<Hlc, String> hlc =
      GeneratedColumn<String>(
        'hlc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Hlc>($NoteFieldsTable.$converterhlc);
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<NoteId, Uint8List> noteId =
      GeneratedColumn<Uint8List>(
        'note_id',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES notes (id) ON DELETE CASCADE',
        ),
      ).withConverter<NoteId>($NoteFieldsTable.$converternoteId);
  @override
  late final GeneratedColumnWithTypeConverter<FieldDefinitionId, Uint8List>
  fieldId = GeneratedColumn<Uint8List>(
    'field_id',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES field_definitions (id) ON DELETE CASCADE',
    ),
  ).withConverter<FieldDefinitionId>($NoteFieldsTable.$converterfieldId);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [hlc, deleted, noteId, fieldId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_fields';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteFieldRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId, fieldId};
  @override
  NoteFieldRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteFieldRow(
      hlc: $NoteFieldsTable.$converterhlc.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hlc'],
        )!,
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      noteId: $NoteFieldsTable.$converternoteId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}note_id'],
        )!,
      ),
      fieldId: $NoteFieldsTable.$converterfieldId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.blob,
          data['${effectivePrefix}field_id'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $NoteFieldsTable createAlias(String alias) {
    return $NoteFieldsTable(attachedDatabase, alias);
  }

  static TypeConverter<Hlc, String> $converterhlc = const HlcConverter();
  static TypeConverter<NoteId, Uint8List> $converternoteId = noteIdConverter;
  static TypeConverter<FieldDefinitionId, Uint8List> $converterfieldId =
      fieldDefinitionIdConverter;
}

class NoteFieldRow extends DataClass implements Insertable<NoteFieldRow> {
  final Hlc hlc;
  final bool deleted;
  final NoteId noteId;
  final FieldDefinitionId fieldId;
  final String value;
  const NoteFieldRow({
    required this.hlc,
    required this.deleted,
    required this.noteId,
    required this.fieldId,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['hlc'] = Variable<String>($NoteFieldsTable.$converterhlc.toSql(hlc));
    }
    map['deleted'] = Variable<bool>(deleted);
    {
      map['note_id'] = Variable<Uint8List>(
        $NoteFieldsTable.$converternoteId.toSql(noteId),
      );
    }
    {
      map['field_id'] = Variable<Uint8List>(
        $NoteFieldsTable.$converterfieldId.toSql(fieldId),
      );
    }
    map['value'] = Variable<String>(value);
    return map;
  }

  NoteFieldsCompanion toCompanion(bool nullToAbsent) {
    return NoteFieldsCompanion(
      hlc: Value(hlc),
      deleted: Value(deleted),
      noteId: Value(noteId),
      fieldId: Value(fieldId),
      value: Value(value),
    );
  }

  factory NoteFieldRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteFieldRow(
      hlc: serializer.fromJson<Hlc>(json['hlc']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      noteId: serializer.fromJson<NoteId>(json['noteId']),
      fieldId: serializer.fromJson<FieldDefinitionId>(json['fieldId']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'hlc': serializer.toJson<Hlc>(hlc),
      'deleted': serializer.toJson<bool>(deleted),
      'noteId': serializer.toJson<NoteId>(noteId),
      'fieldId': serializer.toJson<FieldDefinitionId>(fieldId),
      'value': serializer.toJson<String>(value),
    };
  }

  NoteFieldRow copyWith({
    Hlc? hlc,
    bool? deleted,
    NoteId? noteId,
    FieldDefinitionId? fieldId,
    String? value,
  }) => NoteFieldRow(
    hlc: hlc ?? this.hlc,
    deleted: deleted ?? this.deleted,
    noteId: noteId ?? this.noteId,
    fieldId: fieldId ?? this.fieldId,
    value: value ?? this.value,
  );
  NoteFieldRow copyWithCompanion(NoteFieldsCompanion data) {
    return NoteFieldRow(
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteFieldRow(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('noteId: $noteId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(hlc, deleted, noteId, fieldId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteFieldRow &&
          other.hlc == this.hlc &&
          other.deleted == this.deleted &&
          other.noteId == this.noteId &&
          other.fieldId == this.fieldId &&
          other.value == this.value);
}

class NoteFieldsCompanion extends UpdateCompanion<NoteFieldRow> {
  final Value<Hlc> hlc;
  final Value<bool> deleted;
  final Value<NoteId> noteId;
  final Value<FieldDefinitionId> fieldId;
  final Value<String> value;
  final Value<int> rowid;
  const NoteFieldsCompanion({
    this.hlc = const Value.absent(),
    this.deleted = const Value.absent(),
    this.noteId = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteFieldsCompanion.insert({
    required Hlc hlc,
    this.deleted = const Value.absent(),
    required NoteId noteId,
    required FieldDefinitionId fieldId,
    required String value,
    this.rowid = const Value.absent(),
  }) : hlc = Value(hlc),
       noteId = Value(noteId),
       fieldId = Value(fieldId),
       value = Value(value);
  static Insertable<NoteFieldRow> custom({
    Expression<String>? hlc,
    Expression<bool>? deleted,
    Expression<Uint8List>? noteId,
    Expression<Uint8List>? fieldId,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (hlc != null) 'hlc': hlc,
      if (deleted != null) 'deleted': deleted,
      if (noteId != null) 'note_id': noteId,
      if (fieldId != null) 'field_id': fieldId,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteFieldsCompanion copyWith({
    Value<Hlc>? hlc,
    Value<bool>? deleted,
    Value<NoteId>? noteId,
    Value<FieldDefinitionId>? fieldId,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return NoteFieldsCompanion(
      hlc: hlc ?? this.hlc,
      deleted: deleted ?? this.deleted,
      noteId: noteId ?? this.noteId,
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (hlc.present) {
      map['hlc'] = Variable<String>(
        $NoteFieldsTable.$converterhlc.toSql(hlc.value),
      );
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<Uint8List>(
        $NoteFieldsTable.$converternoteId.toSql(noteId.value),
      );
    }
    if (fieldId.present) {
      map['field_id'] = Variable<Uint8List>(
        $NoteFieldsTable.$converterfieldId.toSql(fieldId.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteFieldsCompanion(')
          ..write('hlc: $hlc, ')
          ..write('deleted: $deleted, ')
          ..write('noteId: $noteId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MemukiDatabase extends GeneratedDatabase {
  _$MemukiDatabase(QueryExecutor e) : super(e);
  $MemukiDatabaseManager get managers => $MemukiDatabaseManager(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $DecksTable decks = $DecksTable(this);
  late final Trigger decksCollectionImmutable = Trigger(
    'CREATE TRIGGER decks_collection_immutable BEFORE UPDATE OF collection_id ON decks WHEN NEW.collection_id IS NOT OLD.collection_id BEGIN SELECT RAISE (ABORT, \'collection_id is immutable\');END',
    'decks_collection_immutable',
  );
  late final $TagsTable tags = $TagsTable(this);
  late final Trigger tagsCollectionImmutable = Trigger(
    'CREATE TRIGGER tags_collection_immutable BEFORE UPDATE OF collection_id ON tags WHEN NEW.collection_id IS NOT OLD.collection_id BEGIN SELECT RAISE (ABORT, \'collection_id is immutable\');END',
    'tags_collection_immutable',
  );
  late final $NoteTypesTable noteTypes = $NoteTypesTable(this);
  late final Trigger noteTypesCollectionImmutable = Trigger(
    'CREATE TRIGGER note_types_collection_immutable BEFORE UPDATE OF collection_id ON note_types WHEN NEW.collection_id IS NOT OLD.collection_id BEGIN SELECT RAISE (ABORT, \'collection_id is immutable\');END',
    'note_types_collection_immutable',
  );
  late final $NotesTable notes = $NotesTable(this);
  late final Trigger notesCollectionImmutable = Trigger(
    'CREATE TRIGGER notes_collection_immutable BEFORE UPDATE OF collection_id ON notes WHEN NEW.collection_id IS NOT OLD.collection_id BEGIN SELECT RAISE (ABORT, \'collection_id is immutable\');END',
    'notes_collection_immutable',
  );
  late final $NoteTagsTable noteTags = $NoteTagsTable(this);
  late final Trigger noteTagsCollectionImmutable = Trigger(
    'CREATE TRIGGER note_tags_collection_immutable BEFORE UPDATE OF collection_id ON note_tags WHEN NEW.collection_id IS NOT OLD.collection_id BEGIN SELECT RAISE (ABORT, \'collection_id is immutable\');END',
    'note_tags_collection_immutable',
  );
  late final $StudyCardTemplatesTable studyCardTemplates =
      $StudyCardTemplatesTable(this);
  late final $StudyCardsTable studyCards = $StudyCardsTable(this);
  late final Trigger studyCardsCollectionImmutable = Trigger(
    'CREATE TRIGGER study_cards_collection_immutable BEFORE UPDATE OF collection_id ON study_cards WHEN NEW.collection_id IS NOT OLD.collection_id BEGIN SELECT RAISE (ABORT, \'collection_id is immutable\');END',
    'study_cards_collection_immutable',
  );
  late final $MediaAssetsTable mediaAssets = $MediaAssetsTable(this);
  late final Trigger mediaAssetsCollectionImmutable = Trigger(
    'CREATE TRIGGER media_assets_collection_immutable BEFORE UPDATE OF collection_id ON media_assets WHEN NEW.collection_id IS NOT OLD.collection_id BEGIN SELECT RAISE (ABORT, \'collection_id is immutable\');END',
    'media_assets_collection_immutable',
  );
  late final $DeviceTable device = $DeviceTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final Index outboxHlc = Index(
    'outbox_hlc',
    'CREATE INDEX outbox_hlc ON outbox (hlc)',
  );
  late final Index studyCardsDeck = Index(
    'study_cards_deck',
    'CREATE INDEX study_cards_deck ON study_cards (collection_id, deck_id)',
  );
  late final Index studyCardsTemplate = Index(
    'study_cards_template',
    'CREATE INDEX study_cards_template ON study_cards (template_id)',
  );
  late final Index studyCardsHlc = Index(
    'study_cards_hlc',
    'CREATE INDEX study_cards_hlc ON study_cards (hlc)',
  );
  late final $ReviewEventsTable reviewEvents = $ReviewEventsTable(this);
  late final $SchedulingStatesTable schedulingStates = $SchedulingStatesTable(
    this,
  );
  late final Index reviewEventsCard = Index(
    'review_events_card',
    'CREATE INDEX review_events_card ON review_events (study_card_id, at)',
  );
  late final Index reviewEventsAt = Index(
    'review_events_at',
    'CREATE INDEX review_events_at ON review_events (at)',
  );
  late final Index reviewEventsHlc = Index(
    'review_events_hlc',
    'CREATE INDEX review_events_hlc ON review_events (hlc)',
  );
  late final Index schedulingStatesDue = Index(
    'scheduling_states_due',
    'CREATE INDEX scheduling_states_due ON scheduling_states (state, due)',
  );
  late final $FieldDefinitionsTable fieldDefinitions = $FieldDefinitionsTable(
    this,
  );
  late final Index noteTypesCollection = Index(
    'note_types_collection',
    'CREATE INDEX note_types_collection ON note_types (collection_id)',
  );
  late final Index noteTypesHlc = Index(
    'note_types_hlc',
    'CREATE INDEX note_types_hlc ON note_types (hlc)',
  );
  late final Index fieldDefinitionsNoteType = Index(
    'field_definitions_note_type',
    'CREATE INDEX field_definitions_note_type ON field_definitions (note_type_id)',
  );
  late final Index fieldDefinitionsHlc = Index(
    'field_definitions_hlc',
    'CREATE INDEX field_definitions_hlc ON field_definitions (hlc)',
  );
  late final Index studyCardTemplatesNoteType = Index(
    'study_card_templates_note_type',
    'CREATE INDEX study_card_templates_note_type ON study_card_templates (note_type_id)',
  );
  late final Index studyCardTemplatesHlc = Index(
    'study_card_templates_hlc',
    'CREATE INDEX study_card_templates_hlc ON study_card_templates (hlc)',
  );
  late final $NoteFieldsTable noteFields = $NoteFieldsTable(this);
  late final Index notesNoteType = Index(
    'notes_note_type',
    'CREATE INDEX notes_note_type ON notes (collection_id, note_type_id)',
  );
  late final Index notesHlc = Index(
    'notes_hlc',
    'CREATE INDEX notes_hlc ON notes (hlc)',
  );
  late final Index noteFieldsField = Index(
    'note_fields_field',
    'CREATE INDEX note_fields_field ON note_fields (field_id)',
  );
  late final Index noteFieldsHlc = Index(
    'note_fields_hlc',
    'CREATE INDEX note_fields_hlc ON note_fields (hlc)',
  );
  late final Index tagsParent = Index(
    'tags_parent',
    'CREATE INDEX tags_parent ON tags (collection_id, parent_id)',
  );
  late final Index tagsHlc = Index(
    'tags_hlc',
    'CREATE INDEX tags_hlc ON tags (hlc)',
  );
  late final Index noteTagsTag = Index(
    'note_tags_tag',
    'CREATE INDEX note_tags_tag ON note_tags (collection_id, tag_id)',
  );
  late final Index noteTagsHlc = Index(
    'note_tags_hlc',
    'CREATE INDEX note_tags_hlc ON note_tags (hlc)',
  );
  late final Index mediaAssetsHlc = Index(
    'media_assets_hlc',
    'CREATE INDEX media_assets_hlc ON media_assets (hlc)',
  );
  late final Index collectionsHlc = Index(
    'collections_hlc',
    'CREATE INDEX collections_hlc ON collections (hlc)',
  );
  late final Index decksParent = Index(
    'decks_parent',
    'CREATE INDEX decks_parent ON decks (collection_id, parent_id)',
  );
  late final Index decksHlc = Index(
    'decks_hlc',
    'CREATE INDEX decks_hlc ON decks (hlc)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    collections,
    decks,
    decksCollectionImmutable,
    tags,
    tagsCollectionImmutable,
    noteTypes,
    noteTypesCollectionImmutable,
    notes,
    notesCollectionImmutable,
    noteTags,
    noteTagsCollectionImmutable,
    studyCardTemplates,
    studyCards,
    studyCardsCollectionImmutable,
    mediaAssets,
    mediaAssetsCollectionImmutable,
    device,
    outbox,
    outboxHlc,
    studyCardsDeck,
    studyCardsTemplate,
    studyCardsHlc,
    reviewEvents,
    schedulingStates,
    reviewEventsCard,
    reviewEventsAt,
    reviewEventsHlc,
    schedulingStatesDue,
    fieldDefinitions,
    noteTypesCollection,
    noteTypesHlc,
    fieldDefinitionsNoteType,
    fieldDefinitionsHlc,
    studyCardTemplatesNoteType,
    studyCardTemplatesHlc,
    noteFields,
    notesNoteType,
    notesHlc,
    noteFieldsField,
    noteFieldsHlc,
    tagsParent,
    tagsHlc,
    noteTagsTag,
    noteTagsHlc,
    mediaAssetsHlc,
    collectionsHlc,
    decksParent,
    decksHlc,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decks',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'note_types',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'note_tags',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'note_types',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('study_card_templates', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_cards',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_assets',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'study_cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scheduling_states', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'note_types',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('field_definitions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'notes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_fields', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'field_definitions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('note_fields', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required Hlc hlc,
      Value<bool> deleted,
      required CollectionId id,
      required String name,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<Hlc> hlc,
      Value<bool> deleted,
      Value<CollectionId> id,
      Value<String> name,
      Value<int> rowid,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$MemukiDatabase, $CollectionsTable, CollectionRow> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DecksTable, List<DeckRow>> _decksRefsTable(
    _$MemukiDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.decks,
    aliasName: 'collections__id__decks__collection_id',
  );

  $$DecksTableProcessedTableManager get decksRefs {
    final manager = $$DecksTableTableManager($_db, $_db.decks).filter(
      (f) => f.collectionId.id.sqlEquals($_itemColumn<Uint8List>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_decksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TagsTable, List<TagRow>> _tagsRefsTable(
    _$MemukiDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tags,
    aliasName: 'collections__id__tags__collection_id',
  );

  $$TagsTableProcessedTableManager get tagsRefs {
    final manager = $$TagsTableTableManager($_db, $_db.tags).filter(
      (f) => f.collectionId.id.sqlEquals($_itemColumn<Uint8List>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_tagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteTypesTable, List<NoteTypeRow>>
  _noteTypesRefsTable(_$MemukiDatabase db) => MultiTypedResultKey.fromTable(
    db.noteTypes,
    aliasName: 'collections__id__note_types__collection_id',
  );

  $$NoteTypesTableProcessedTableManager get noteTypesRefs {
    final manager = $$NoteTypesTableTableManager($_db, $_db.noteTypes).filter(
      (f) => f.collectionId.id.sqlEquals($_itemColumn<Uint8List>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_noteTypesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NotesTable, List<NoteRow>> _notesRefsTable(
    _$MemukiDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: 'collections__id__notes__collection_id',
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager($_db, $_db.notes).filter(
      (f) => f.collectionId.id.sqlEquals($_itemColumn<Uint8List>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NoteTagsTable, List<NoteTagRow>>
  _noteTagsRefsTable(_$MemukiDatabase db) => MultiTypedResultKey.fromTable(
    db.noteTags,
    aliasName: 'collections__id__note_tags__collection_id',
  );

  $$NoteTagsTableProcessedTableManager get noteTagsRefs {
    final manager = $$NoteTagsTableTableManager($_db, $_db.noteTags).filter(
      (f) => f.collectionId.id.sqlEquals($_itemColumn<Uint8List>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_noteTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StudyCardsTable, List<StudyCardRow>>
  _studyCardsRefsTable(_$MemukiDatabase db) => MultiTypedResultKey.fromTable(
    db.studyCards,
    aliasName: 'collections__id__study_cards__collection_id',
  );

  $$StudyCardsTableProcessedTableManager get studyCardsRefs {
    final manager = $$StudyCardsTableTableManager($_db, $_db.studyCards).filter(
      (f) => f.collectionId.id.sqlEquals($_itemColumn<Uint8List>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_studyCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MediaAssetsTable, List<MediaAssetRow>>
  _mediaAssetsRefsTable(_$MemukiDatabase db) => MultiTypedResultKey.fromTable(
    db.mediaAssets,
    aliasName: 'collections__id__media_assets__collection_id',
  );

  $$MediaAssetsTableProcessedTableManager get mediaAssetsRefs {
    final manager = $$MediaAssetsTableTableManager($_db, $_db.mediaAssets)
        .filter(
          (f) => f.collectionId.id.sqlEquals($_itemColumn<Uint8List>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_mediaAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$MemukiDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CollectionId, CollectionId, Uint8List>
  get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> decksRefs(
    Expression<bool> Function($$DecksTableFilterComposer f) f,
  ) {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tagsRefs(
    Expression<bool> Function($$TagsTableFilterComposer f) f,
  ) {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteTypesRefs(
    Expression<bool> Function($$NoteTypesTableFilterComposer f) f,
  ) {
    final $$NoteTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTypes,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTypesTableFilterComposer(
            $db: $db,
            $table: $db.noteTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> noteTagsRefs(
    Expression<bool> Function($$NoteTagsTableFilterComposer f) f,
  ) {
    final $$NoteTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableFilterComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> studyCardsRefs(
    Expression<bool> Function($$StudyCardsTableFilterComposer f) f,
  ) {
    final $$StudyCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableFilterComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mediaAssetsRefs(
    Expression<bool> Function($$MediaAssetsTableFilterComposer f) f,
  ) {
    final $$MediaAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableFilterComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$MemukiDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CollectionId, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> decksRefs<T extends Object>(
    Expression<T> Function($$DecksTableAnnotationComposer a) f,
  ) {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tagsRefs<T extends Object>(
    Expression<T> Function($$TagsTableAnnotationComposer a) f,
  ) {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> noteTypesRefs<T extends Object>(
    Expression<T> Function($$NoteTypesTableAnnotationComposer a) f,
  ) {
    final $$NoteTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTypes,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> noteTagsRefs<T extends Object>(
    Expression<T> Function($$NoteTagsTableAnnotationComposer a) f,
  ) {
    final $$NoteTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteTags,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> studyCardsRefs<T extends Object>(
    Expression<T> Function($$StudyCardsTableAnnotationComposer a) f,
  ) {
    final $$StudyCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mediaAssetsRefs<T extends Object>(
    Expression<T> Function($$MediaAssetsTableAnnotationComposer a) f,
  ) {
    final $$MediaAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaAssets,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $CollectionsTable,
          CollectionRow,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (CollectionRow, $$CollectionsTableReferences),
          CollectionRow,
          PrefetchHooks Function({
            bool decksRefs,
            bool tagsRefs,
            bool noteTypesRefs,
            bool notesRefs,
            bool noteTagsRefs,
            bool studyCardsRefs,
            bool mediaAssetsRefs,
          })
        > {
  $$CollectionsTableTableManager(_$MemukiDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<CollectionId> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required CollectionId id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, CollectionRow>(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                decksRefs = false,
                tagsRefs = false,
                noteTypesRefs = false,
                notesRefs = false,
                noteTagsRefs = false,
                studyCardsRefs = false,
                mediaAssetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (decksRefs) db.decks,
                    if (tagsRefs) db.tags,
                    if (noteTypesRefs) db.noteTypes,
                    if (notesRefs) db.notes,
                    if (noteTagsRefs) db.noteTags,
                    if (studyCardsRefs) db.studyCards,
                    if (mediaAssetsRefs) db.mediaAssets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (decksRefs)
                        await $_getPrefetchedDataByColumns<
                          CollectionRow,
                          $CollectionsTable,
                          DeckRow,
                          $DecksTable
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._decksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).decksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'collection_id',
                          typedResults: items,
                        ),
                      if (tagsRefs)
                        await $_getPrefetchedDataByColumns<
                          CollectionRow,
                          $CollectionsTable,
                          TagRow,
                          $TagsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._tagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).tagsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'collection_id',
                          typedResults: items,
                        ),
                      if (noteTypesRefs)
                        await $_getPrefetchedDataByColumns<
                          CollectionRow,
                          $CollectionsTable,
                          NoteTypeRow,
                          $NoteTypesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._noteTypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).noteTypesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'collection_id',
                          typedResults: items,
                        ),
                      if (notesRefs)
                        await $_getPrefetchedDataByColumns<
                          CollectionRow,
                          $CollectionsTable,
                          NoteRow,
                          $NotesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._notesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).notesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'collection_id',
                          typedResults: items,
                        ),
                      if (noteTagsRefs)
                        await $_getPrefetchedDataByColumns<
                          CollectionRow,
                          $CollectionsTable,
                          NoteTagRow,
                          $NoteTagsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._noteTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).noteTagsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'collection_id',
                          typedResults: items,
                        ),
                      if (studyCardsRefs)
                        await $_getPrefetchedDataByColumns<
                          CollectionRow,
                          $CollectionsTable,
                          StudyCardRow,
                          $StudyCardsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._studyCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).studyCardsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'collection_id',
                          typedResults: items,
                        ),
                      if (mediaAssetsRefs)
                        await $_getPrefetchedDataByColumns<
                          CollectionRow,
                          $CollectionsTable,
                          MediaAssetRow,
                          $MediaAssetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CollectionsTableReferences
                              ._mediaAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CollectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaAssetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'collection_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $CollectionsTable,
      CollectionRow,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (CollectionRow, $$CollectionsTableReferences),
      CollectionRow,
      PrefetchHooks Function({
        bool decksRefs,
        bool tagsRefs,
        bool noteTypesRefs,
        bool notesRefs,
        bool noteTagsRefs,
        bool studyCardsRefs,
        bool mediaAssetsRefs,
      })
    >;
typedef $$DecksTableCreateCompanionBuilder = DecksCompanion Function({
  required Hlc hlc,
  Value<bool> deleted,
  required DeckId id,
  required CollectionId collectionId,
  Value<DeckId?> parentId,
  required String name,
  Value<int> rowid,
});
typedef $$DecksTableUpdateCompanionBuilder = DecksCompanion Function({
  Value<Hlc> hlc,
  Value<bool> deleted,
  Value<DeckId> id,
  Value<CollectionId> collectionId,
  Value<DeckId?> parentId,
  Value<String> name,
  Value<int> rowid,
});

final class $$DecksTableReferences
    extends BaseReferences<_$MemukiDatabase, $DecksTable, DeckRow> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$MemukiDatabase db) =>
      db.collections.createAlias('decks__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<Uint8List>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DecksTableFilterComposer
    extends Composer<_$MemukiDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DeckId, DeckId, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DeckId?, DeckId, Uint8List> get parentId =>
      $composableBuilder(
        column: $table.parentId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$MemukiDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecksTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeckId, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeckId?, Uint8List> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $DecksTable,
          DeckRow,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (DeckRow, $$DecksTableReferences),
          DeckRow,
          PrefetchHooks Function({bool collectionId})
        > {
  $$DecksTableTableManager(_$MemukiDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<DeckId> id = const Value.absent(),
                Value<CollectionId> collectionId = const Value.absent(),
                Value<DeckId?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                parentId: parentId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required DeckId id,
                required CollectionId collectionId,
                Value<DeckId?> parentId = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                parentId: parentId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DecksTable, DeckRow>(table),
                  $$DecksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.collectionId,
                        referencedTable: $$DecksTableReferences
                            ._collectionIdTable(db),
                        referencedColumn: $$DecksTableReferences
                            ._collectionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $DecksTable,
      DeckRow,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (DeckRow, $$DecksTableReferences),
      DeckRow,
      PrefetchHooks Function({bool collectionId})
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required Hlc hlc,
  Value<bool> deleted,
  required TagId id,
  required CollectionId collectionId,
  Value<TagId?> parentId,
  required String name,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<Hlc> hlc,
  Value<bool> deleted,
  Value<TagId> id,
  Value<CollectionId> collectionId,
  Value<TagId?> parentId,
  Value<String> name,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$MemukiDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$MemukiDatabase db) =>
      db.collections.createAlias('tags__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<Uint8List>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$MemukiDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TagId, TagId, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TagId?, TagId, Uint8List> get parentId =>
      $composableBuilder(
        column: $table.parentId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagsTableOrderingComposer
    extends Composer<_$MemukiDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagsTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TagId, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TagId?, Uint8List> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool collectionId})
        > {
  $$TagsTableTableManager(_$MemukiDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<TagId> id = const Value.absent(),
                Value<CollectionId> collectionId = const Value.absent(),
                Value<TagId?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                parentId: parentId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required TagId id,
                required CollectionId collectionId,
                Value<TagId?> parentId = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                parentId: parentId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, TagRow>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.collectionId,
                        referencedTable: $$TagsTableReferences
                            ._collectionIdTable(db),
                        referencedColumn: $$TagsTableReferences
                            ._collectionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool collectionId})
    >;
typedef $$NoteTypesTableCreateCompanionBuilder = NoteTypesCompanion Function({
  required Hlc hlc,
  Value<bool> deleted,
  required NoteTypeId id,
  required CollectionId collectionId,
  required String name,
  Value<int> rowid,
});
typedef $$NoteTypesTableUpdateCompanionBuilder = NoteTypesCompanion Function({
  Value<Hlc> hlc,
  Value<bool> deleted,
  Value<NoteTypeId> id,
  Value<CollectionId> collectionId,
  Value<String> name,
  Value<int> rowid,
});

final class $$NoteTypesTableReferences
    extends BaseReferences<_$MemukiDatabase, $NoteTypesTable, NoteTypeRow> {
  $$NoteTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$MemukiDatabase db) =>
      db.collections.createAlias('note_types__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<Uint8List>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $StudyCardTemplatesTable,
    List<StudyCardTemplateRow>
  >
  _studyCardTemplatesRefsTable(_$MemukiDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.studyCardTemplates,
        aliasName: 'note_types__id__study_card_templates__note_type_id',
      );

  $$StudyCardTemplatesTableProcessedTableManager get studyCardTemplatesRefs {
    final manager = $$StudyCardTemplatesTableTableManager(
      $_db,
      $_db.studyCardTemplates,
    ).filter((f) => f.noteTypeId.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studyCardTemplatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FieldDefinitionsTable, List<FieldDefinitionRow>>
  _fieldDefinitionsRefsTable(_$MemukiDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.fieldDefinitions,
        aliasName: 'note_types__id__field_definitions__note_type_id',
      );

  $$FieldDefinitionsTableProcessedTableManager get fieldDefinitionsRefs {
    final manager = $$FieldDefinitionsTableTableManager(
      $_db,
      $_db.fieldDefinitions,
    ).filter((f) => f.noteTypeId.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _fieldDefinitionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NoteTypesTableFilterComposer
    extends Composer<_$MemukiDatabase, $NoteTypesTable> {
  $$NoteTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NoteTypeId, NoteTypeId, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> studyCardTemplatesRefs(
    Expression<bool> Function($$StudyCardTemplatesTableFilterComposer f) f,
  ) {
    final $$StudyCardTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyCardTemplates,
      getReferencedColumn: (t) => t.noteTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.studyCardTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fieldDefinitionsRefs(
    Expression<bool> Function($$FieldDefinitionsTableFilterComposer f) f,
  ) {
    final $$FieldDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fieldDefinitions,
      getReferencedColumn: (t) => t.noteTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.fieldDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NoteTypesTableOrderingComposer
    extends Composer<_$MemukiDatabase, $NoteTypesTable> {
  $$NoteTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTypesTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $NoteTypesTable> {
  $$NoteTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NoteTypeId, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> studyCardTemplatesRefs<T extends Object>(
    Expression<T> Function($$StudyCardTemplatesTableAnnotationComposer a) f,
  ) {
    final $$StudyCardTemplatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.studyCardTemplates,
          getReferencedColumn: (t) => t.noteTypeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudyCardTemplatesTableAnnotationComposer(
                $db: $db,
                $table: $db.studyCardTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> fieldDefinitionsRefs<T extends Object>(
    Expression<T> Function($$FieldDefinitionsTableAnnotationComposer a) f,
  ) {
    final $$FieldDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fieldDefinitions,
      getReferencedColumn: (t) => t.noteTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.fieldDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NoteTypesTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $NoteTypesTable,
          NoteTypeRow,
          $$NoteTypesTableFilterComposer,
          $$NoteTypesTableOrderingComposer,
          $$NoteTypesTableAnnotationComposer,
          $$NoteTypesTableCreateCompanionBuilder,
          $$NoteTypesTableUpdateCompanionBuilder,
          (NoteTypeRow, $$NoteTypesTableReferences),
          NoteTypeRow,
          PrefetchHooks Function({
            bool collectionId,
            bool studyCardTemplatesRefs,
            bool fieldDefinitionsRefs,
          })
        > {
  $$NoteTypesTableTableManager(_$MemukiDatabase db, $NoteTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<NoteTypeId> id = const Value.absent(),
                Value<CollectionId> collectionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteTypesCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required NoteTypeId id,
                required CollectionId collectionId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => NoteTypesCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteTypesTable, NoteTypeRow>(table),
                  $$NoteTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                collectionId = false,
                studyCardTemplatesRefs = false,
                fieldDefinitionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studyCardTemplatesRefs) db.studyCardTemplates,
                    if (fieldDefinitionsRefs) db.fieldDefinitions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (collectionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.collectionId,
                            referencedTable: $$NoteTypesTableReferences
                                ._collectionIdTable(db),
                            referencedColumn: $$NoteTypesTableReferences
                                ._collectionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studyCardTemplatesRefs)
                        await $_getPrefetchedDataByColumns<
                          NoteTypeRow,
                          $NoteTypesTable,
                          StudyCardTemplateRow,
                          $StudyCardTemplatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$NoteTypesTableReferences
                              ._studyCardTemplatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NoteTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).studyCardTemplatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'note_type_id',
                          typedResults: items,
                        ),
                      if (fieldDefinitionsRefs)
                        await $_getPrefetchedDataByColumns<
                          NoteTypeRow,
                          $NoteTypesTable,
                          FieldDefinitionRow,
                          $FieldDefinitionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$NoteTypesTableReferences
                              ._fieldDefinitionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NoteTypesTableReferences(
                                db,
                                table,
                                p0,
                              ).fieldDefinitionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'note_type_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NoteTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $NoteTypesTable,
      NoteTypeRow,
      $$NoteTypesTableFilterComposer,
      $$NoteTypesTableOrderingComposer,
      $$NoteTypesTableAnnotationComposer,
      $$NoteTypesTableCreateCompanionBuilder,
      $$NoteTypesTableUpdateCompanionBuilder,
      (NoteTypeRow, $$NoteTypesTableReferences),
      NoteTypeRow,
      PrefetchHooks Function({
        bool collectionId,
        bool studyCardTemplatesRefs,
        bool fieldDefinitionsRefs,
      })
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required Hlc hlc,
  Value<bool> deleted,
  required NoteId id,
  required CollectionId collectionId,
  required NoteTypeId noteTypeId,
  Value<SourceKind?> sourceKind,
  Value<String?> sourceReference,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<Hlc> hlc,
  Value<bool> deleted,
  Value<NoteId> id,
  Value<CollectionId> collectionId,
  Value<NoteTypeId> noteTypeId,
  Value<SourceKind?> sourceKind,
  Value<String?> sourceReference,
  Value<int> rowid,
});

final class $$NotesTableReferences
    extends BaseReferences<_$MemukiDatabase, $NotesTable, NoteRow> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$MemukiDatabase db) =>
      db.collections.createAlias('notes__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<Uint8List>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NoteFieldsTable, List<NoteFieldRow>>
  _noteFieldsRefsTable(_$MemukiDatabase db) => MultiTypedResultKey.fromTable(
    db.noteFields,
    aliasName: 'notes__id__note_fields__note_id',
  );

  $$NoteFieldsTableProcessedTableManager get noteFieldsRefs {
    final manager = $$NoteFieldsTableTableManager(
      $_db,
      $_db.noteFields,
    ).filter((f) => f.noteId.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteFieldsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NotesTableFilterComposer
    extends Composer<_$MemukiDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NoteId, NoteId, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<NoteTypeId, NoteTypeId, Uint8List>
  get noteTypeId => $composableBuilder(
    column: $table.noteTypeId,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<SourceKind?, SourceKind, String>
  get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> noteFieldsRefs(
    Expression<bool> Function($$NoteFieldsTableFilterComposer f) f,
  ) {
    final $$NoteFieldsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteFields,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteFieldsTableFilterComposer(
            $db: $db,
            $table: $db.noteFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$MemukiDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get noteTypeId => $composableBuilder(
    column: $table.noteTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NoteId, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NoteTypeId, Uint8List> get noteTypeId =>
      $composableBuilder(
        column: $table.noteTypeId,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<SourceKind?, String> get sourceKind =>
      $composableBuilder(
        column: $table.sourceKind,
        builder: (column) => column,
      );

  GeneratedColumn<String> get sourceReference => $composableBuilder(
    column: $table.sourceReference,
    builder: (column) => column,
  );

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> noteFieldsRefs<T extends Object>(
    Expression<T> Function($$NoteFieldsTableAnnotationComposer a) f,
  ) {
    final $$NoteFieldsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteFields,
      getReferencedColumn: (t) => t.noteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteFieldsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, $$NotesTableReferences),
          NoteRow,
          PrefetchHooks Function({bool collectionId, bool noteFieldsRefs})
        > {
  $$NotesTableTableManager(_$MemukiDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<NoteId> id = const Value.absent(),
                Value<CollectionId> collectionId = const Value.absent(),
                Value<NoteTypeId> noteTypeId = const Value.absent(),
                Value<SourceKind?> sourceKind = const Value.absent(),
                Value<String?> sourceReference = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                noteTypeId: noteTypeId,
                sourceKind: sourceKind,
                sourceReference: sourceReference,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required NoteId id,
                required CollectionId collectionId,
                required NoteTypeId noteTypeId,
                Value<SourceKind?> sourceKind = const Value.absent(),
                Value<String?> sourceReference = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                noteTypeId: noteTypeId,
                sourceKind: sourceKind,
                sourceReference: sourceReference,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, NoteRow>(table),
                  $$NotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({collectionId = false, noteFieldsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (noteFieldsRefs) db.noteFields],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (collectionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.collectionId,
                            referencedTable: $$NotesTableReferences
                                ._collectionIdTable(db),
                            referencedColumn: $$NotesTableReferences
                                ._collectionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteFieldsRefs)
                        await $_getPrefetchedDataByColumns<
                          NoteRow,
                          $NotesTable,
                          NoteFieldRow,
                          $NoteFieldsTable
                        >(
                          currentTable: table,
                          referencedTable: $$NotesTableReferences
                              ._noteFieldsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NotesTableReferences(
                                db,
                                table,
                                p0,
                              ).noteFieldsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'note_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, $$NotesTableReferences),
      NoteRow,
      PrefetchHooks Function({bool collectionId, bool noteFieldsRefs})
    >;
typedef $$NoteTagsTableCreateCompanionBuilder = NoteTagsCompanion Function({
  required Hlc hlc,
  Value<bool> deleted,
  required CollectionId collectionId,
  required NoteId noteId,
  required TagId tagId,
  Value<int> rowid,
});
typedef $$NoteTagsTableUpdateCompanionBuilder = NoteTagsCompanion Function({
  Value<Hlc> hlc,
  Value<bool> deleted,
  Value<CollectionId> collectionId,
  Value<NoteId> noteId,
  Value<TagId> tagId,
  Value<int> rowid,
});

final class $$NoteTagsTableReferences
    extends BaseReferences<_$MemukiDatabase, $NoteTagsTable, NoteTagRow> {
  $$NoteTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$MemukiDatabase db) =>
      db.collections.createAlias('note_tags__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<Uint8List>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteTagsTableFilterComposer
    extends Composer<_$MemukiDatabase, $NoteTagsTable> {
  $$NoteTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NoteId, NoteId, Uint8List> get noteId =>
      $composableBuilder(
        column: $table.noteId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TagId, TagId, Uint8List> get tagId =>
      $composableBuilder(
        column: $table.tagId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableOrderingComposer
    extends Composer<_$MemukiDatabase, $NoteTagsTable> {
  $$NoteTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $NoteTagsTable> {
  $$NoteTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NoteId, Uint8List> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TagId, Uint8List> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteTagsTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $NoteTagsTable,
          NoteTagRow,
          $$NoteTagsTableFilterComposer,
          $$NoteTagsTableOrderingComposer,
          $$NoteTagsTableAnnotationComposer,
          $$NoteTagsTableCreateCompanionBuilder,
          $$NoteTagsTableUpdateCompanionBuilder,
          (NoteTagRow, $$NoteTagsTableReferences),
          NoteTagRow,
          PrefetchHooks Function({bool collectionId})
        > {
  $$NoteTagsTableTableManager(_$MemukiDatabase db, $NoteTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<CollectionId> collectionId = const Value.absent(),
                Value<NoteId> noteId = const Value.absent(),
                Value<TagId> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteTagsCompanion(
                hlc: hlc,
                deleted: deleted,
                collectionId: collectionId,
                noteId: noteId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required CollectionId collectionId,
                required NoteId noteId,
                required TagId tagId,
                Value<int> rowid = const Value.absent(),
              }) => NoteTagsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                collectionId: collectionId,
                noteId: noteId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteTagsTable, NoteTagRow>(table),
                  $$NoteTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.collectionId,
                        referencedTable: $$NoteTagsTableReferences
                            ._collectionIdTable(db),
                        referencedColumn: $$NoteTagsTableReferences
                            ._collectionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $NoteTagsTable,
      NoteTagRow,
      $$NoteTagsTableFilterComposer,
      $$NoteTagsTableOrderingComposer,
      $$NoteTagsTableAnnotationComposer,
      $$NoteTagsTableCreateCompanionBuilder,
      $$NoteTagsTableUpdateCompanionBuilder,
      (NoteTagRow, $$NoteTagsTableReferences),
      NoteTagRow,
      PrefetchHooks Function({bool collectionId})
    >;
typedef $$StudyCardTemplatesTableCreateCompanionBuilder =
    StudyCardTemplatesCompanion Function({
      required Hlc hlc,
      Value<bool> deleted,
      required StudyCardTemplateId id,
      required NoteTypeId noteTypeId,
      required int position,
      required String name,
      Value<int> rowid,
    });
typedef $$StudyCardTemplatesTableUpdateCompanionBuilder =
    StudyCardTemplatesCompanion Function({
      Value<Hlc> hlc,
      Value<bool> deleted,
      Value<StudyCardTemplateId> id,
      Value<NoteTypeId> noteTypeId,
      Value<int> position,
      Value<String> name,
      Value<int> rowid,
    });

final class $$StudyCardTemplatesTableReferences
    extends
        BaseReferences<
          _$MemukiDatabase,
          $StudyCardTemplatesTable,
          StudyCardTemplateRow
        > {
  $$StudyCardTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NoteTypesTable _noteTypeIdTable(_$MemukiDatabase db) => db.noteTypes
      .createAlias('study_card_templates__note_type_id__note_types__id');

  $$NoteTypesTableProcessedTableManager get noteTypeId {
    final $_column = $_itemColumn<Uint8List>('note_type_id')!;

    final manager = $$NoteTypesTableTableManager(
      $_db,
      $_db.noteTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StudyCardsTable, List<StudyCardRow>>
  _studyCardsRefsTable(_$MemukiDatabase db) => MultiTypedResultKey.fromTable(
    db.studyCards,
    aliasName: 'study_card_templates__id__study_cards__template_id',
  );

  $$StudyCardsTableProcessedTableManager get studyCardsRefs {
    final manager = $$StudyCardsTableTableManager(
      $_db,
      $_db.studyCards,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(_studyCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudyCardTemplatesTableFilterComposer
    extends Composer<_$MemukiDatabase, $StudyCardTemplatesTable> {
  $$StudyCardTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    StudyCardTemplateId,
    StudyCardTemplateId,
    Uint8List
  >
  get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$NoteTypesTableFilterComposer get noteTypeId {
    final $$NoteTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteTypeId,
      referencedTable: $db.noteTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTypesTableFilterComposer(
            $db: $db,
            $table: $db.noteTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> studyCardsRefs(
    Expression<bool> Function($$StudyCardsTableFilterComposer f) f,
  ) {
    final $$StudyCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableFilterComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudyCardTemplatesTableOrderingComposer
    extends Composer<_$MemukiDatabase, $StudyCardTemplatesTable> {
  $$StudyCardTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$NoteTypesTableOrderingComposer get noteTypeId {
    final $$NoteTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteTypeId,
      referencedTable: $db.noteTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTypesTableOrderingComposer(
            $db: $db,
            $table: $db.noteTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyCardTemplatesTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $StudyCardTemplatesTable> {
  $$StudyCardTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StudyCardTemplateId, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$NoteTypesTableAnnotationComposer get noteTypeId {
    final $$NoteTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteTypeId,
      referencedTable: $db.noteTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> studyCardsRefs<T extends Object>(
    Expression<T> Function($$StudyCardsTableAnnotationComposer a) f,
  ) {
    final $$StudyCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudyCardTemplatesTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $StudyCardTemplatesTable,
          StudyCardTemplateRow,
          $$StudyCardTemplatesTableFilterComposer,
          $$StudyCardTemplatesTableOrderingComposer,
          $$StudyCardTemplatesTableAnnotationComposer,
          $$StudyCardTemplatesTableCreateCompanionBuilder,
          $$StudyCardTemplatesTableUpdateCompanionBuilder,
          (StudyCardTemplateRow, $$StudyCardTemplatesTableReferences),
          StudyCardTemplateRow,
          PrefetchHooks Function({bool noteTypeId, bool studyCardsRefs})
        > {
  $$StudyCardTemplatesTableTableManager(
    _$MemukiDatabase db,
    $StudyCardTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyCardTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyCardTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyCardTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<StudyCardTemplateId> id = const Value.absent(),
                Value<NoteTypeId> noteTypeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyCardTemplatesCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                noteTypeId: noteTypeId,
                position: position,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required StudyCardTemplateId id,
                required NoteTypeId noteTypeId,
                required int position,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => StudyCardTemplatesCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                noteTypeId: noteTypeId,
                position: position,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudyCardTemplatesTable, StudyCardTemplateRow>(
                    table,
                  ),
                  $$StudyCardTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({noteTypeId = false, studyCardsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (studyCardsRefs) db.studyCards],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (noteTypeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.noteTypeId,
                            referencedTable: $$StudyCardTemplatesTableReferences
                                ._noteTypeIdTable(db),
                            referencedColumn:
                                $$StudyCardTemplatesTableReferences
                                    ._noteTypeIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studyCardsRefs)
                        await $_getPrefetchedDataByColumns<
                          StudyCardTemplateRow,
                          $StudyCardTemplatesTable,
                          StudyCardRow,
                          $StudyCardsTable
                        >(
                          currentTable: table,
                          referencedTable: $$StudyCardTemplatesTableReferences
                              ._studyCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudyCardTemplatesTableReferences(
                                db,
                                table,
                                p0,
                              ).studyCardsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'template_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StudyCardTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $StudyCardTemplatesTable,
      StudyCardTemplateRow,
      $$StudyCardTemplatesTableFilterComposer,
      $$StudyCardTemplatesTableOrderingComposer,
      $$StudyCardTemplatesTableAnnotationComposer,
      $$StudyCardTemplatesTableCreateCompanionBuilder,
      $$StudyCardTemplatesTableUpdateCompanionBuilder,
      (StudyCardTemplateRow, $$StudyCardTemplatesTableReferences),
      StudyCardTemplateRow,
      PrefetchHooks Function({bool noteTypeId, bool studyCardsRefs})
    >;
typedef $$StudyCardsTableCreateCompanionBuilder = StudyCardsCompanion Function({
  required Hlc hlc,
  Value<bool> deleted,
  required StudyCardId id,
  required CollectionId collectionId,
  required NoteId noteId,
  required StudyCardTemplateId templateId,
  required DeckId deckId,
  Value<int> rowid,
});
typedef $$StudyCardsTableUpdateCompanionBuilder = StudyCardsCompanion Function({
  Value<Hlc> hlc,
  Value<bool> deleted,
  Value<StudyCardId> id,
  Value<CollectionId> collectionId,
  Value<NoteId> noteId,
  Value<StudyCardTemplateId> templateId,
  Value<DeckId> deckId,
  Value<int> rowid,
});

final class $$StudyCardsTableReferences
    extends BaseReferences<_$MemukiDatabase, $StudyCardsTable, StudyCardRow> {
  $$StudyCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$MemukiDatabase db) =>
      db.collections.createAlias('study_cards__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<Uint8List>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudyCardTemplatesTable _templateIdTable(_$MemukiDatabase db) => db
      .studyCardTemplates
      .createAlias('study_cards__template_id__study_card_templates__id');

  $$StudyCardTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<Uint8List>('template_id')!;

    final manager = $$StudyCardTemplatesTableTableManager(
      $_db,
      $_db.studyCardTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReviewEventsTable, List<ReviewEventRow>>
  _reviewEventsRefsTable(_$MemukiDatabase db) => MultiTypedResultKey.fromTable(
    db.reviewEvents,
    aliasName: 'study_cards__id__review_events__study_card_id',
  );

  $$ReviewEventsTableProcessedTableManager get reviewEventsRefs {
    final manager = $$ReviewEventsTableTableManager(
      $_db,
      $_db.reviewEvents,
    ).filter((f) => f.studyCardId.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SchedulingStatesTable, List<SchedulingStateRow>>
  _schedulingStatesRefsTable(_$MemukiDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.schedulingStates,
        aliasName: 'study_cards__id__scheduling_states__study_card_id',
      );

  $$SchedulingStatesTableProcessedTableManager get schedulingStatesRefs {
    final manager = $$SchedulingStatesTableTableManager(
      $_db,
      $_db.schedulingStates,
    ).filter((f) => f.studyCardId.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _schedulingStatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudyCardsTableFilterComposer
    extends Composer<_$MemukiDatabase, $StudyCardsTable> {
  $$StudyCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StudyCardId, StudyCardId, Uint8List> get id =>
      $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<NoteId, NoteId, Uint8List> get noteId =>
      $composableBuilder(
        column: $table.noteId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DeckId, DeckId, Uint8List> get deckId =>
      $composableBuilder(
        column: $table.deckId,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudyCardTemplatesTableFilterComposer get templateId {
    final $$StudyCardTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.studyCardTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.studyCardTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> reviewEventsRefs(
    Expression<bool> Function($$ReviewEventsTableFilterComposer f) f,
  ) {
    final $$ReviewEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewEvents,
      getReferencedColumn: (t) => t.studyCardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewEventsTableFilterComposer(
            $db: $db,
            $table: $db.reviewEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> schedulingStatesRefs(
    Expression<bool> Function($$SchedulingStatesTableFilterComposer f) f,
  ) {
    final $$SchedulingStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedulingStates,
      getReferencedColumn: (t) => t.studyCardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulingStatesTableFilterComposer(
            $db: $db,
            $table: $db.schedulingStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudyCardsTableOrderingComposer
    extends Composer<_$MemukiDatabase, $StudyCardsTable> {
  $$StudyCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudyCardTemplatesTableOrderingComposer get templateId {
    final $$StudyCardTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.studyCardTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.studyCardTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudyCardsTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $StudyCardsTable> {
  $$StudyCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StudyCardId, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NoteId, Uint8List> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeckId, Uint8List> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudyCardTemplatesTableAnnotationComposer get templateId {
    final $$StudyCardTemplatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.templateId,
          referencedTable: $db.studyCardTemplates,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$StudyCardTemplatesTableAnnotationComposer(
                $db: $db,
                $table: $db.studyCardTemplates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> reviewEventsRefs<T extends Object>(
    Expression<T> Function($$ReviewEventsTableAnnotationComposer a) f,
  ) {
    final $$ReviewEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewEvents,
      getReferencedColumn: (t) => t.studyCardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> schedulingStatesRefs<T extends Object>(
    Expression<T> Function($$SchedulingStatesTableAnnotationComposer a) f,
  ) {
    final $$SchedulingStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedulingStates,
      getReferencedColumn: (t) => t.studyCardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulingStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedulingStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudyCardsTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $StudyCardsTable,
          StudyCardRow,
          $$StudyCardsTableFilterComposer,
          $$StudyCardsTableOrderingComposer,
          $$StudyCardsTableAnnotationComposer,
          $$StudyCardsTableCreateCompanionBuilder,
          $$StudyCardsTableUpdateCompanionBuilder,
          (StudyCardRow, $$StudyCardsTableReferences),
          StudyCardRow,
          PrefetchHooks Function({
            bool collectionId,
            bool templateId,
            bool reviewEventsRefs,
            bool schedulingStatesRefs,
          })
        > {
  $$StudyCardsTableTableManager(_$MemukiDatabase db, $StudyCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<StudyCardId> id = const Value.absent(),
                Value<CollectionId> collectionId = const Value.absent(),
                Value<NoteId> noteId = const Value.absent(),
                Value<StudyCardTemplateId> templateId = const Value.absent(),
                Value<DeckId> deckId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyCardsCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                noteId: noteId,
                templateId: templateId,
                deckId: deckId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required StudyCardId id,
                required CollectionId collectionId,
                required NoteId noteId,
                required StudyCardTemplateId templateId,
                required DeckId deckId,
                Value<int> rowid = const Value.absent(),
              }) => StudyCardsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                collectionId: collectionId,
                noteId: noteId,
                templateId: templateId,
                deckId: deckId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StudyCardsTable, StudyCardRow>(table),
                  $$StudyCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                collectionId = false,
                templateId = false,
                reviewEventsRefs = false,
                schedulingStatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (reviewEventsRefs) db.reviewEvents,
                    if (schedulingStatesRefs) db.schedulingStates,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (collectionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.collectionId,
                            referencedTable: $$StudyCardsTableReferences
                                ._collectionIdTable(db),
                            referencedColumn: $$StudyCardsTableReferences
                                ._collectionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (templateId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.templateId,
                            referencedTable: $$StudyCardsTableReferences
                                ._templateIdTable(db),
                            referencedColumn: $$StudyCardsTableReferences
                                ._templateIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (reviewEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          StudyCardRow,
                          $StudyCardsTable,
                          ReviewEventRow,
                          $ReviewEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$StudyCardsTableReferences
                              ._reviewEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudyCardsTableReferences(
                                db,
                                table,
                                p0,
                              ).reviewEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'study_card_id',
                          typedResults: items,
                        ),
                      if (schedulingStatesRefs)
                        await $_getPrefetchedDataByColumns<
                          StudyCardRow,
                          $StudyCardsTable,
                          SchedulingStateRow,
                          $SchedulingStatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$StudyCardsTableReferences
                              ._schedulingStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudyCardsTableReferences(
                                db,
                                table,
                                p0,
                              ).schedulingStatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'study_card_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StudyCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $StudyCardsTable,
      StudyCardRow,
      $$StudyCardsTableFilterComposer,
      $$StudyCardsTableOrderingComposer,
      $$StudyCardsTableAnnotationComposer,
      $$StudyCardsTableCreateCompanionBuilder,
      $$StudyCardsTableUpdateCompanionBuilder,
      (StudyCardRow, $$StudyCardsTableReferences),
      StudyCardRow,
      PrefetchHooks Function({
        bool collectionId,
        bool templateId,
        bool reviewEventsRefs,
        bool schedulingStatesRefs,
      })
    >;
typedef $$MediaAssetsTableCreateCompanionBuilder =
    MediaAssetsCompanion Function({
      required Hlc hlc,
      Value<bool> deleted,
      required CollectionId collectionId,
      required ContentHash hash,
      required String mimeType,
      required int sizeBytes,
      Value<String?> originalName,
      Value<int> rowid,
    });
typedef $$MediaAssetsTableUpdateCompanionBuilder =
    MediaAssetsCompanion Function({
      Value<Hlc> hlc,
      Value<bool> deleted,
      Value<CollectionId> collectionId,
      Value<ContentHash> hash,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<String?> originalName,
      Value<int> rowid,
    });

final class $$MediaAssetsTableReferences
    extends BaseReferences<_$MemukiDatabase, $MediaAssetsTable, MediaAssetRow> {
  $$MediaAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$MemukiDatabase db) => db
      .collections
      .createAlias('media_assets__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<Uint8List>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaAssetsTableFilterComposer
    extends Composer<_$MemukiDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ContentHash, ContentHash, Uint8List>
  get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableOrderingComposer
    extends Composer<_$MemukiDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $MediaAssetsTable> {
  $$MediaAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContentHash, Uint8List> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaAssetsTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $MediaAssetsTable,
          MediaAssetRow,
          $$MediaAssetsTableFilterComposer,
          $$MediaAssetsTableOrderingComposer,
          $$MediaAssetsTableAnnotationComposer,
          $$MediaAssetsTableCreateCompanionBuilder,
          $$MediaAssetsTableUpdateCompanionBuilder,
          (MediaAssetRow, $$MediaAssetsTableReferences),
          MediaAssetRow,
          PrefetchHooks Function({bool collectionId})
        > {
  $$MediaAssetsTableTableManager(_$MemukiDatabase db, $MediaAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<CollectionId> collectionId = const Value.absent(),
                Value<ContentHash> hash = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> originalName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetsCompanion(
                hlc: hlc,
                deleted: deleted,
                collectionId: collectionId,
                hash: hash,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                originalName: originalName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required CollectionId collectionId,
                required ContentHash hash,
                required String mimeType,
                required int sizeBytes,
                Value<String?> originalName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaAssetsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                collectionId: collectionId,
                hash: hash,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                originalName: originalName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaAssetsTable, MediaAssetRow>(table),
                  $$MediaAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.collectionId,
                        referencedTable: $$MediaAssetsTableReferences
                            ._collectionIdTable(db),
                        referencedColumn: $$MediaAssetsTableReferences
                            ._collectionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MediaAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $MediaAssetsTable,
      MediaAssetRow,
      $$MediaAssetsTableFilterComposer,
      $$MediaAssetsTableOrderingComposer,
      $$MediaAssetsTableAnnotationComposer,
      $$MediaAssetsTableCreateCompanionBuilder,
      $$MediaAssetsTableUpdateCompanionBuilder,
      (MediaAssetRow, $$MediaAssetsTableReferences),
      MediaAssetRow,
      PrefetchHooks Function({bool collectionId})
    >;
typedef $$DeviceTableCreateCompanionBuilder = DeviceCompanion Function({
  Value<int> id,
  required String node,
  Value<Hlc?> lastHlc,
});
typedef $$DeviceTableUpdateCompanionBuilder = DeviceCompanion Function({
  Value<int> id,
  Value<String> node,
  Value<Hlc?> lastHlc,
});

class $$DeviceTableFilterComposer
    extends Composer<_$MemukiDatabase, $DeviceTable> {
  $$DeviceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get node => $composableBuilder(
    column: $table.node,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Hlc?, Hlc, String> get lastHlc =>
      $composableBuilder(
        column: $table.lastHlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$DeviceTableOrderingComposer
    extends Composer<_$MemukiDatabase, $DeviceTable> {
  $$DeviceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get node => $composableBuilder(
    column: $table.node,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastHlc => $composableBuilder(
    column: $table.lastHlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $DeviceTable> {
  $$DeviceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get node =>
      $composableBuilder(column: $table.node, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Hlc?, String> get lastHlc =>
      $composableBuilder(column: $table.lastHlc, builder: (column) => column);
}

class $$DeviceTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $DeviceTable,
          DeviceRow,
          $$DeviceTableFilterComposer,
          $$DeviceTableOrderingComposer,
          $$DeviceTableAnnotationComposer,
          $$DeviceTableCreateCompanionBuilder,
          $$DeviceTableUpdateCompanionBuilder,
          (
            DeviceRow,
            BaseReferences<_$MemukiDatabase, $DeviceTable, DeviceRow>,
          ),
          DeviceRow,
          PrefetchHooks Function()
        > {
  $$DeviceTableTableManager(_$MemukiDatabase db, $DeviceTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> node = const Value.absent(),
            Value<Hlc?> lastHlc = const Value.absent(),
          }) => DeviceCompanion(id: id, node: node, lastHlc: lastHlc),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String node,
            Value<Hlc?> lastHlc = const Value.absent(),
          }) => DeviceCompanion.insert(id: id, node: node, lastHlc: lastHlc),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeviceTable, DeviceRow>(table),
                  BaseReferences<_$MemukiDatabase, $DeviceTable, DeviceRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $DeviceTable,
      DeviceRow,
      $$DeviceTableFilterComposer,
      $$DeviceTableOrderingComposer,
      $$DeviceTableAnnotationComposer,
      $$DeviceTableCreateCompanionBuilder,
      $$DeviceTableUpdateCompanionBuilder,
      (DeviceRow, BaseReferences<_$MemukiDatabase, $DeviceTable, DeviceRow>),
      DeviceRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  required CollectionId collectionId,
  required String entityTable,
  required Uint8List entityKey,
  required Hlc hlc,
  Value<int> rowid,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<CollectionId> collectionId,
  Value<String> entityTable,
  Value<Uint8List> entityKey,
  Value<Hlc> hlc,
  Value<int> rowid,
});

class $$OutboxTableFilterComposer
    extends Composer<_$MemukiDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<CollectionId, CollectionId, Uint8List>
  get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$MemukiDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get entityKey => $composableBuilder(
    column: $table.entityKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<CollectionId, Uint8List> get collectionId =>
      $composableBuilder(
        column: $table.collectionId,
        builder: (column) => column,
      );

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get entityKey =>
      $composableBuilder(column: $table.entityKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $OutboxTable,
          OutboxRow,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$MemukiDatabase, $OutboxTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$MemukiDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<CollectionId> collectionId = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<Uint8List> entityKey = const Value.absent(),
                Value<Hlc> hlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                collectionId: collectionId,
                entityTable: entityTable,
                entityKey: entityKey,
                hlc: hlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required CollectionId collectionId,
                required String entityTable,
                required Uint8List entityKey,
                required Hlc hlc,
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                collectionId: collectionId,
                entityTable: entityTable,
                entityKey: entityKey,
                hlc: hlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxRow>(table),
                  BaseReferences<_$MemukiDatabase, $OutboxTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $OutboxTable,
      OutboxRow,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$MemukiDatabase, $OutboxTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$ReviewEventsTableCreateCompanionBuilder =
    ReviewEventsCompanion Function({
      required ReviewEventId id,
      required StudyCardId studyCardId,
      required ReviewEventKind kind,
      required DateTime at,
      Value<Grade?> grade,
      Value<Duration?> responseTime,
      Value<DateTime?> dueBefore,
      Value<DateTime?> dueAfter,
      Value<ReviewEventId?> undoneEventId,
      required String schedulerId,
      required int schedulerVersion,
      required int configVersion,
      required Hlc hlc,
      Value<int> rowid,
    });
typedef $$ReviewEventsTableUpdateCompanionBuilder =
    ReviewEventsCompanion Function({
      Value<ReviewEventId> id,
      Value<StudyCardId> studyCardId,
      Value<ReviewEventKind> kind,
      Value<DateTime> at,
      Value<Grade?> grade,
      Value<Duration?> responseTime,
      Value<DateTime?> dueBefore,
      Value<DateTime?> dueAfter,
      Value<ReviewEventId?> undoneEventId,
      Value<String> schedulerId,
      Value<int> schedulerVersion,
      Value<int> configVersion,
      Value<Hlc> hlc,
      Value<int> rowid,
    });

final class $$ReviewEventsTableReferences
    extends
        BaseReferences<_$MemukiDatabase, $ReviewEventsTable, ReviewEventRow> {
  $$ReviewEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudyCardsTable _studyCardIdTable(_$MemukiDatabase db) => db
      .studyCards
      .createAlias('review_events__study_card_id__study_cards__id');

  $$StudyCardsTableProcessedTableManager get studyCardId {
    final $_column = $_itemColumn<Uint8List>('study_card_id')!;

    final manager = $$StudyCardsTableTableManager(
      $_db,
      $_db.studyCards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studyCardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ReviewEventsTable _undoneEventIdTable(_$MemukiDatabase db) => db
      .reviewEvents
      .createAlias('review_events__undone_event_id__review_events__id');

  $$ReviewEventsTableProcessedTableManager? get undoneEventId {
    final $_column = $_itemColumn<Uint8List>('undone_event_id');
    if ($_column == null) return null;
    final manager = $$ReviewEventsTableTableManager(
      $_db,
      $_db.reviewEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_undoneEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SchedulingStatesTable, List<SchedulingStateRow>>
  _schedulingStatesRefsTable(_$MemukiDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.schedulingStates,
        aliasName: 'review_events__id__scheduling_states__last_event_id',
      );

  $$SchedulingStatesTableProcessedTableManager get schedulingStatesRefs {
    final manager = $$SchedulingStatesTableTableManager(
      $_db,
      $_db.schedulingStates,
    ).filter((f) => f.lastEventId.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _schedulingStatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReviewEventsTableFilterComposer
    extends Composer<_$MemukiDatabase, $ReviewEventsTable> {
  $$ReviewEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<ReviewEventId, ReviewEventId, Uint8List>
  get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ReviewEventKind, ReviewEventKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get at =>
      $composableBuilder(
        column: $table.at,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Grade?, Grade, String> get grade =>
      $composableBuilder(
        column: $table.grade,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Duration?, Duration, int> get responseTime =>
      $composableBuilder(
        column: $table.responseTime,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get dueBefore =>
      $composableBuilder(
        column: $table.dueBefore,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get dueAfter =>
      $composableBuilder(
        column: $table.dueAfter,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get schedulerId => $composableBuilder(
    column: $table.schedulerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schedulerVersion => $composableBuilder(
    column: $table.schedulerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get configVersion => $composableBuilder(
    column: $table.configVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$StudyCardsTableFilterComposer get studyCardId {
    final $$StudyCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyCardId,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableFilterComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReviewEventsTableFilterComposer get undoneEventId {
    final $$ReviewEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.undoneEventId,
      referencedTable: $db.reviewEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewEventsTableFilterComposer(
            $db: $db,
            $table: $db.reviewEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> schedulingStatesRefs(
    Expression<bool> Function($$SchedulingStatesTableFilterComposer f) f,
  ) {
    final $$SchedulingStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedulingStates,
      getReferencedColumn: (t) => t.lastEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulingStatesTableFilterComposer(
            $db: $db,
            $table: $db.schedulingStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReviewEventsTableOrderingComposer
    extends Composer<_$MemukiDatabase, $ReviewEventsTable> {
  $$ReviewEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseTime => $composableBuilder(
    column: $table.responseTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueBefore => $composableBuilder(
    column: $table.dueBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAfter => $composableBuilder(
    column: $table.dueAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schedulerId => $composableBuilder(
    column: $table.schedulerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schedulerVersion => $composableBuilder(
    column: $table.schedulerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get configVersion => $composableBuilder(
    column: $table.configVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudyCardsTableOrderingComposer get studyCardId {
    final $$StudyCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyCardId,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableOrderingComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReviewEventsTableOrderingComposer get undoneEventId {
    final $$ReviewEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.undoneEventId,
      referencedTable: $db.reviewEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewEventsTableOrderingComposer(
            $db: $db,
            $table: $db.reviewEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewEventsTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $ReviewEventsTable> {
  $$ReviewEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<ReviewEventId, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReviewEventKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Grade?, String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Duration?, int> get responseTime =>
      $composableBuilder(
        column: $table.responseTime,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get dueBefore =>
      $composableBuilder(column: $table.dueBefore, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get dueAfter =>
      $composableBuilder(column: $table.dueAfter, builder: (column) => column);

  GeneratedColumn<String> get schedulerId => $composableBuilder(
    column: $table.schedulerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schedulerVersion => $composableBuilder(
    column: $table.schedulerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get configVersion => $composableBuilder(
    column: $table.configVersion,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  $$StudyCardsTableAnnotationComposer get studyCardId {
    final $$StudyCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyCardId,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReviewEventsTableAnnotationComposer get undoneEventId {
    final $$ReviewEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.undoneEventId,
      referencedTable: $db.reviewEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> schedulingStatesRefs<T extends Object>(
    Expression<T> Function($$SchedulingStatesTableAnnotationComposer a) f,
  ) {
    final $$SchedulingStatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.schedulingStates,
      getReferencedColumn: (t) => t.lastEventId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SchedulingStatesTableAnnotationComposer(
            $db: $db,
            $table: $db.schedulingStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReviewEventsTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $ReviewEventsTable,
          ReviewEventRow,
          $$ReviewEventsTableFilterComposer,
          $$ReviewEventsTableOrderingComposer,
          $$ReviewEventsTableAnnotationComposer,
          $$ReviewEventsTableCreateCompanionBuilder,
          $$ReviewEventsTableUpdateCompanionBuilder,
          (ReviewEventRow, $$ReviewEventsTableReferences),
          ReviewEventRow,
          PrefetchHooks Function({
            bool studyCardId,
            bool undoneEventId,
            bool schedulingStatesRefs,
          })
        > {
  $$ReviewEventsTableTableManager(_$MemukiDatabase db, $ReviewEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<ReviewEventId> id = const Value.absent(),
                Value<StudyCardId> studyCardId = const Value.absent(),
                Value<ReviewEventKind> kind = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<Grade?> grade = const Value.absent(),
                Value<Duration?> responseTime = const Value.absent(),
                Value<DateTime?> dueBefore = const Value.absent(),
                Value<DateTime?> dueAfter = const Value.absent(),
                Value<ReviewEventId?> undoneEventId = const Value.absent(),
                Value<String> schedulerId = const Value.absent(),
                Value<int> schedulerVersion = const Value.absent(),
                Value<int> configVersion = const Value.absent(),
                Value<Hlc> hlc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewEventsCompanion(
                id: id,
                studyCardId: studyCardId,
                kind: kind,
                at: at,
                grade: grade,
                responseTime: responseTime,
                dueBefore: dueBefore,
                dueAfter: dueAfter,
                undoneEventId: undoneEventId,
                schedulerId: schedulerId,
                schedulerVersion: schedulerVersion,
                configVersion: configVersion,
                hlc: hlc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required ReviewEventId id,
                required StudyCardId studyCardId,
                required ReviewEventKind kind,
                required DateTime at,
                Value<Grade?> grade = const Value.absent(),
                Value<Duration?> responseTime = const Value.absent(),
                Value<DateTime?> dueBefore = const Value.absent(),
                Value<DateTime?> dueAfter = const Value.absent(),
                Value<ReviewEventId?> undoneEventId = const Value.absent(),
                required String schedulerId,
                required int schedulerVersion,
                required int configVersion,
                required Hlc hlc,
                Value<int> rowid = const Value.absent(),
              }) => ReviewEventsCompanion.insert(
                id: id,
                studyCardId: studyCardId,
                kind: kind,
                at: at,
                grade: grade,
                responseTime: responseTime,
                dueBefore: dueBefore,
                dueAfter: dueAfter,
                undoneEventId: undoneEventId,
                schedulerId: schedulerId,
                schedulerVersion: schedulerVersion,
                configVersion: configVersion,
                hlc: hlc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReviewEventsTable, ReviewEventRow>(table),
                  $$ReviewEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                studyCardId = false,
                undoneEventId = false,
                schedulingStatesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (schedulingStatesRefs) db.schedulingStates,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (studyCardId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.studyCardId,
                            referencedTable: $$ReviewEventsTableReferences
                                ._studyCardIdTable(db),
                            referencedColumn: $$ReviewEventsTableReferences
                                ._studyCardIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (undoneEventId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.undoneEventId,
                            referencedTable: $$ReviewEventsTableReferences
                                ._undoneEventIdTable(db),
                            referencedColumn: $$ReviewEventsTableReferences
                                ._undoneEventIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (schedulingStatesRefs)
                        await $_getPrefetchedDataByColumns<
                          ReviewEventRow,
                          $ReviewEventsTable,
                          SchedulingStateRow,
                          $SchedulingStatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ReviewEventsTableReferences
                              ._schedulingStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReviewEventsTableReferences(
                                db,
                                table,
                                p0,
                              ).schedulingStatesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'last_event_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ReviewEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $ReviewEventsTable,
      ReviewEventRow,
      $$ReviewEventsTableFilterComposer,
      $$ReviewEventsTableOrderingComposer,
      $$ReviewEventsTableAnnotationComposer,
      $$ReviewEventsTableCreateCompanionBuilder,
      $$ReviewEventsTableUpdateCompanionBuilder,
      (ReviewEventRow, $$ReviewEventsTableReferences),
      ReviewEventRow,
      PrefetchHooks Function({
        bool studyCardId,
        bool undoneEventId,
        bool schedulingStatesRefs,
      })
    >;
typedef $$SchedulingStatesTableCreateCompanionBuilder =
    SchedulingStatesCompanion Function({
      required StudyCardId studyCardId,
      required StudyCardState state,
      Value<DateTime?> due,
      required Duration interval,
      Value<double?> ease,
      required int step,
      required int lapses,
      required int reviewCount,
      Value<ReviewEventId?> lastEventId,
      Value<int> rowid,
    });
typedef $$SchedulingStatesTableUpdateCompanionBuilder =
    SchedulingStatesCompanion Function({
      Value<StudyCardId> studyCardId,
      Value<StudyCardState> state,
      Value<DateTime?> due,
      Value<Duration> interval,
      Value<double?> ease,
      Value<int> step,
      Value<int> lapses,
      Value<int> reviewCount,
      Value<ReviewEventId?> lastEventId,
      Value<int> rowid,
    });

final class $$SchedulingStatesTableReferences
    extends
        BaseReferences<
          _$MemukiDatabase,
          $SchedulingStatesTable,
          SchedulingStateRow
        > {
  $$SchedulingStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudyCardsTable _studyCardIdTable(_$MemukiDatabase db) => db
      .studyCards
      .createAlias('scheduling_states__study_card_id__study_cards__id');

  $$StudyCardsTableProcessedTableManager get studyCardId {
    final $_column = $_itemColumn<Uint8List>('study_card_id')!;

    final manager = $$StudyCardsTableTableManager(
      $_db,
      $_db.studyCards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studyCardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ReviewEventsTable _lastEventIdTable(_$MemukiDatabase db) => db
      .reviewEvents
      .createAlias('scheduling_states__last_event_id__review_events__id');

  $$ReviewEventsTableProcessedTableManager? get lastEventId {
    final $_column = $_itemColumn<Uint8List>('last_event_id');
    if ($_column == null) return null;
    final manager = $$ReviewEventsTableTableManager(
      $_db,
      $_db.reviewEvents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lastEventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SchedulingStatesTableFilterComposer
    extends Composer<_$MemukiDatabase, $SchedulingStatesTable> {
  $$SchedulingStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<StudyCardState, StudyCardState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get due =>
      $composableBuilder(
        column: $table.due,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Duration, Duration, int> get interval =>
      $composableBuilder(
        column: $table.interval,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get ease => $composableBuilder(
    column: $table.ease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );

  $$StudyCardsTableFilterComposer get studyCardId {
    final $$StudyCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyCardId,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableFilterComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReviewEventsTableFilterComposer get lastEventId {
    final $$ReviewEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastEventId,
      referencedTable: $db.reviewEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewEventsTableFilterComposer(
            $db: $db,
            $table: $db.reviewEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulingStatesTableOrderingComposer
    extends Composer<_$MemukiDatabase, $SchedulingStatesTable> {
  $$SchedulingStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ease => $composableBuilder(
    column: $table.ease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get step => $composableBuilder(
    column: $table.step,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudyCardsTableOrderingComposer get studyCardId {
    final $$StudyCardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyCardId,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableOrderingComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReviewEventsTableOrderingComposer get lastEventId {
    final $$ReviewEventsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastEventId,
      referencedTable: $db.reviewEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewEventsTableOrderingComposer(
            $db: $db,
            $table: $db.reviewEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulingStatesTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $SchedulingStatesTable> {
  $$SchedulingStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<StudyCardState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Duration, int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<double> get ease =>
      $composableBuilder(column: $table.ease, builder: (column) => column);

  GeneratedColumn<int> get step =>
      $composableBuilder(column: $table.step, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );

  $$StudyCardsTableAnnotationComposer get studyCardId {
    final $$StudyCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studyCardId,
      referencedTable: $db.studyCards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudyCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.studyCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReviewEventsTableAnnotationComposer get lastEventId {
    final $$ReviewEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastEventId,
      referencedTable: $db.reviewEvents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SchedulingStatesTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $SchedulingStatesTable,
          SchedulingStateRow,
          $$SchedulingStatesTableFilterComposer,
          $$SchedulingStatesTableOrderingComposer,
          $$SchedulingStatesTableAnnotationComposer,
          $$SchedulingStatesTableCreateCompanionBuilder,
          $$SchedulingStatesTableUpdateCompanionBuilder,
          (SchedulingStateRow, $$SchedulingStatesTableReferences),
          SchedulingStateRow,
          PrefetchHooks Function({bool studyCardId, bool lastEventId})
        > {
  $$SchedulingStatesTableTableManager(
    _$MemukiDatabase db,
    $SchedulingStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchedulingStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchedulingStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchedulingStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<StudyCardId> studyCardId = const Value.absent(),
                Value<StudyCardState> state = const Value.absent(),
                Value<DateTime?> due = const Value.absent(),
                Value<Duration> interval = const Value.absent(),
                Value<double?> ease = const Value.absent(),
                Value<int> step = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<ReviewEventId?> lastEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchedulingStatesCompanion(
                studyCardId: studyCardId,
                state: state,
                due: due,
                interval: interval,
                ease: ease,
                step: step,
                lapses: lapses,
                reviewCount: reviewCount,
                lastEventId: lastEventId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required StudyCardId studyCardId,
                required StudyCardState state,
                Value<DateTime?> due = const Value.absent(),
                required Duration interval,
                Value<double?> ease = const Value.absent(),
                required int step,
                required int lapses,
                required int reviewCount,
                Value<ReviewEventId?> lastEventId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchedulingStatesCompanion.insert(
                studyCardId: studyCardId,
                state: state,
                due: due,
                interval: interval,
                ease: ease,
                step: step,
                lapses: lapses,
                reviewCount: reviewCount,
                lastEventId: lastEventId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchedulingStatesTable, SchedulingStateRow>(
                    table,
                  ),
                  $$SchedulingStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studyCardId = false, lastEventId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (studyCardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.studyCardId,
                        referencedTable: $$SchedulingStatesTableReferences
                            ._studyCardIdTable(db),
                        referencedColumn: $$SchedulingStatesTableReferences
                            ._studyCardIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (lastEventId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.lastEventId,
                        referencedTable: $$SchedulingStatesTableReferences
                            ._lastEventIdTable(db),
                        referencedColumn: $$SchedulingStatesTableReferences
                            ._lastEventIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SchedulingStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $SchedulingStatesTable,
      SchedulingStateRow,
      $$SchedulingStatesTableFilterComposer,
      $$SchedulingStatesTableOrderingComposer,
      $$SchedulingStatesTableAnnotationComposer,
      $$SchedulingStatesTableCreateCompanionBuilder,
      $$SchedulingStatesTableUpdateCompanionBuilder,
      (SchedulingStateRow, $$SchedulingStatesTableReferences),
      SchedulingStateRow,
      PrefetchHooks Function({bool studyCardId, bool lastEventId})
    >;
typedef $$FieldDefinitionsTableCreateCompanionBuilder =
    FieldDefinitionsCompanion Function({
      required Hlc hlc,
      Value<bool> deleted,
      required FieldDefinitionId id,
      required NoteTypeId noteTypeId,
      required int position,
      required String name,
      required FieldType type,
      Value<int> rowid,
    });
typedef $$FieldDefinitionsTableUpdateCompanionBuilder =
    FieldDefinitionsCompanion Function({
      Value<Hlc> hlc,
      Value<bool> deleted,
      Value<FieldDefinitionId> id,
      Value<NoteTypeId> noteTypeId,
      Value<int> position,
      Value<String> name,
      Value<FieldType> type,
      Value<int> rowid,
    });

final class $$FieldDefinitionsTableReferences
    extends
        BaseReferences<
          _$MemukiDatabase,
          $FieldDefinitionsTable,
          FieldDefinitionRow
        > {
  $$FieldDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NoteTypesTable _noteTypeIdTable(_$MemukiDatabase db) => db.noteTypes
      .createAlias('field_definitions__note_type_id__note_types__id');

  $$NoteTypesTableProcessedTableManager get noteTypeId {
    final $_column = $_itemColumn<Uint8List>('note_type_id')!;

    final manager = $$NoteTypesTableTableManager(
      $_db,
      $_db.noteTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$NoteFieldsTable, List<NoteFieldRow>>
  _noteFieldsRefsTable(_$MemukiDatabase db) => MultiTypedResultKey.fromTable(
    db.noteFields,
    aliasName: 'field_definitions__id__note_fields__field_id',
  );

  $$NoteFieldsTableProcessedTableManager get noteFieldsRefs {
    final manager = $$NoteFieldsTableTableManager(
      $_db,
      $_db.noteFields,
    ).filter((f) => f.fieldId.id.sqlEquals($_itemColumn<Uint8List>('id')!));

    final cache = $_typedResult.readTableOrNull(_noteFieldsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FieldDefinitionsTableFilterComposer
    extends Composer<_$MemukiDatabase, $FieldDefinitionsTable> {
  $$FieldDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    FieldDefinitionId,
    FieldDefinitionId,
    Uint8List
  >
  get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FieldType, FieldType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$NoteTypesTableFilterComposer get noteTypeId {
    final $$NoteTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteTypeId,
      referencedTable: $db.noteTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTypesTableFilterComposer(
            $db: $db,
            $table: $db.noteTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> noteFieldsRefs(
    Expression<bool> Function($$NoteFieldsTableFilterComposer f) f,
  ) {
    final $$NoteFieldsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteFields,
      getReferencedColumn: (t) => t.fieldId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteFieldsTableFilterComposer(
            $db: $db,
            $table: $db.noteFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FieldDefinitionsTableOrderingComposer
    extends Composer<_$MemukiDatabase, $FieldDefinitionsTable> {
  $$FieldDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  $$NoteTypesTableOrderingComposer get noteTypeId {
    final $$NoteTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteTypeId,
      referencedTable: $db.noteTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTypesTableOrderingComposer(
            $db: $db,
            $table: $db.noteTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FieldDefinitionsTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $FieldDefinitionsTable> {
  $$FieldDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FieldDefinitionId, Uint8List> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FieldType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  $$NoteTypesTableAnnotationComposer get noteTypeId {
    final $$NoteTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteTypeId,
      referencedTable: $db.noteTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.noteTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> noteFieldsRefs<T extends Object>(
    Expression<T> Function($$NoteFieldsTableAnnotationComposer a) f,
  ) {
    final $$NoteFieldsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.noteFields,
      getReferencedColumn: (t) => t.fieldId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NoteFieldsTableAnnotationComposer(
            $db: $db,
            $table: $db.noteFields,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FieldDefinitionsTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $FieldDefinitionsTable,
          FieldDefinitionRow,
          $$FieldDefinitionsTableFilterComposer,
          $$FieldDefinitionsTableOrderingComposer,
          $$FieldDefinitionsTableAnnotationComposer,
          $$FieldDefinitionsTableCreateCompanionBuilder,
          $$FieldDefinitionsTableUpdateCompanionBuilder,
          (FieldDefinitionRow, $$FieldDefinitionsTableReferences),
          FieldDefinitionRow,
          PrefetchHooks Function({bool noteTypeId, bool noteFieldsRefs})
        > {
  $$FieldDefinitionsTableTableManager(
    _$MemukiDatabase db,
    $FieldDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldDefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<FieldDefinitionId> id = const Value.absent(),
                Value<NoteTypeId> noteTypeId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<FieldType> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldDefinitionsCompanion(
                hlc: hlc,
                deleted: deleted,
                id: id,
                noteTypeId: noteTypeId,
                position: position,
                name: name,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required FieldDefinitionId id,
                required NoteTypeId noteTypeId,
                required int position,
                required String name,
                required FieldType type,
                Value<int> rowid = const Value.absent(),
              }) => FieldDefinitionsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                id: id,
                noteTypeId: noteTypeId,
                position: position,
                name: name,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FieldDefinitionsTable, FieldDefinitionRow>(
                    table,
                  ),
                  $$FieldDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({noteTypeId = false, noteFieldsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (noteFieldsRefs) db.noteFields],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (noteTypeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.noteTypeId,
                            referencedTable: $$FieldDefinitionsTableReferences
                                ._noteTypeIdTable(db),
                            referencedColumn: $$FieldDefinitionsTableReferences
                                ._noteTypeIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (noteFieldsRefs)
                        await $_getPrefetchedDataByColumns<
                          FieldDefinitionRow,
                          $FieldDefinitionsTable,
                          NoteFieldRow,
                          $NoteFieldsTable
                        >(
                          currentTable: table,
                          referencedTable: $$FieldDefinitionsTableReferences
                              ._noteFieldsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FieldDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).noteFieldsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'field_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FieldDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $FieldDefinitionsTable,
      FieldDefinitionRow,
      $$FieldDefinitionsTableFilterComposer,
      $$FieldDefinitionsTableOrderingComposer,
      $$FieldDefinitionsTableAnnotationComposer,
      $$FieldDefinitionsTableCreateCompanionBuilder,
      $$FieldDefinitionsTableUpdateCompanionBuilder,
      (FieldDefinitionRow, $$FieldDefinitionsTableReferences),
      FieldDefinitionRow,
      PrefetchHooks Function({bool noteTypeId, bool noteFieldsRefs})
    >;
typedef $$NoteFieldsTableCreateCompanionBuilder = NoteFieldsCompanion Function({
  required Hlc hlc,
  Value<bool> deleted,
  required NoteId noteId,
  required FieldDefinitionId fieldId,
  required String value,
  Value<int> rowid,
});
typedef $$NoteFieldsTableUpdateCompanionBuilder = NoteFieldsCompanion Function({
  Value<Hlc> hlc,
  Value<bool> deleted,
  Value<NoteId> noteId,
  Value<FieldDefinitionId> fieldId,
  Value<String> value,
  Value<int> rowid,
});

final class $$NoteFieldsTableReferences
    extends BaseReferences<_$MemukiDatabase, $NoteFieldsTable, NoteFieldRow> {
  $$NoteFieldsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NotesTable _noteIdTable(_$MemukiDatabase db) =>
      db.notes.createAlias('note_fields__note_id__notes__id');

  $$NotesTableProcessedTableManager get noteId {
    final $_column = $_itemColumn<Uint8List>('note_id')!;

    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_noteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FieldDefinitionsTable _fieldIdTable(_$MemukiDatabase db) => db
      .fieldDefinitions
      .createAlias('note_fields__field_id__field_definitions__id');

  $$FieldDefinitionsTableProcessedTableManager get fieldId {
    final $_column = $_itemColumn<Uint8List>('field_id')!;

    final manager = $$FieldDefinitionsTableTableManager(
      $_db,
      $_db.fieldDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fieldIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NoteFieldsTableFilterComposer
    extends Composer<_$MemukiDatabase, $NoteFieldsTable> {
  $$NoteFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Hlc, Hlc, String> get hlc =>
      $composableBuilder(
        column: $table.hlc,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$NotesTableFilterComposer get noteId {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FieldDefinitionsTableFilterComposer get fieldId {
    final $$FieldDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.fieldDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.fieldDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteFieldsTableOrderingComposer
    extends Composer<_$MemukiDatabase, $NoteFieldsTable> {
  $$NoteFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$NotesTableOrderingComposer get noteId {
    final $$NotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableOrderingComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FieldDefinitionsTableOrderingComposer get fieldId {
    final $$FieldDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.fieldDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.fieldDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteFieldsTableAnnotationComposer
    extends Composer<_$MemukiDatabase, $NoteFieldsTable> {
  $$NoteFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Hlc, String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$NotesTableAnnotationComposer get noteId {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.noteId,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FieldDefinitionsTableAnnotationComposer get fieldId {
    final $$FieldDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fieldId,
      referencedTable: $db.fieldDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FieldDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.fieldDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NoteFieldsTableTableManager
    extends
        RootTableManager<
          _$MemukiDatabase,
          $NoteFieldsTable,
          NoteFieldRow,
          $$NoteFieldsTableFilterComposer,
          $$NoteFieldsTableOrderingComposer,
          $$NoteFieldsTableAnnotationComposer,
          $$NoteFieldsTableCreateCompanionBuilder,
          $$NoteFieldsTableUpdateCompanionBuilder,
          (NoteFieldRow, $$NoteFieldsTableReferences),
          NoteFieldRow,
          PrefetchHooks Function({bool noteId, bool fieldId})
        > {
  $$NoteFieldsTableTableManager(_$MemukiDatabase db, $NoteFieldsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteFieldsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteFieldsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Hlc> hlc = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<NoteId> noteId = const Value.absent(),
                Value<FieldDefinitionId> fieldId = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteFieldsCompanion(
                hlc: hlc,
                deleted: deleted,
                noteId: noteId,
                fieldId: fieldId,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Hlc hlc,
                Value<bool> deleted = const Value.absent(),
                required NoteId noteId,
                required FieldDefinitionId fieldId,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => NoteFieldsCompanion.insert(
                hlc: hlc,
                deleted: deleted,
                noteId: noteId,
                fieldId: fieldId,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NoteFieldsTable, NoteFieldRow>(table),
                  $$NoteFieldsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({noteId = false, fieldId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (noteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.noteId,
                        referencedTable: $$NoteFieldsTableReferences
                            ._noteIdTable(db),
                        referencedColumn: $$NoteFieldsTableReferences
                            ._noteIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (fieldId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.fieldId,
                        referencedTable: $$NoteFieldsTableReferences
                            ._fieldIdTable(db),
                        referencedColumn: $$NoteFieldsTableReferences
                            ._fieldIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NoteFieldsTableProcessedTableManager =
    ProcessedTableManager<
      _$MemukiDatabase,
      $NoteFieldsTable,
      NoteFieldRow,
      $$NoteFieldsTableFilterComposer,
      $$NoteFieldsTableOrderingComposer,
      $$NoteFieldsTableAnnotationComposer,
      $$NoteFieldsTableCreateCompanionBuilder,
      $$NoteFieldsTableUpdateCompanionBuilder,
      (NoteFieldRow, $$NoteFieldsTableReferences),
      NoteFieldRow,
      PrefetchHooks Function({bool noteId, bool fieldId})
    >;

class $MemukiDatabaseManager {
  final _$MemukiDatabase _db;
  $MemukiDatabaseManager(this._db);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$NoteTypesTableTableManager get noteTypes =>
      $$NoteTypesTableTableManager(_db, _db.noteTypes);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$NoteTagsTableTableManager get noteTags =>
      $$NoteTagsTableTableManager(_db, _db.noteTags);
  $$StudyCardTemplatesTableTableManager get studyCardTemplates =>
      $$StudyCardTemplatesTableTableManager(_db, _db.studyCardTemplates);
  $$StudyCardsTableTableManager get studyCards =>
      $$StudyCardsTableTableManager(_db, _db.studyCards);
  $$MediaAssetsTableTableManager get mediaAssets =>
      $$MediaAssetsTableTableManager(_db, _db.mediaAssets);
  $$DeviceTableTableManager get device =>
      $$DeviceTableTableManager(_db, _db.device);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$ReviewEventsTableTableManager get reviewEvents =>
      $$ReviewEventsTableTableManager(_db, _db.reviewEvents);
  $$SchedulingStatesTableTableManager get schedulingStates =>
      $$SchedulingStatesTableTableManager(_db, _db.schedulingStates);
  $$FieldDefinitionsTableTableManager get fieldDefinitions =>
      $$FieldDefinitionsTableTableManager(_db, _db.fieldDefinitions);
  $$NoteFieldsTableTableManager get noteFields =>
      $$NoteFieldsTableTableManager(_db, _db.noteFields);
}
