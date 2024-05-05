// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VoiceWorkCategoryTable extends VoiceWorkCategory
    with TableInfo<$VoiceWorkCategoryTable, VoiceWorkCategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceWorkCategoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_work_category';
  @override
  VerificationContext validateIntegrity(
      Insertable<VoiceWorkCategoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoiceWorkCategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceWorkCategoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $VoiceWorkCategoryTable createAlias(String alias) {
    return $VoiceWorkCategoryTable(attachedDatabase, alias);
  }
}

class VoiceWorkCategoryData extends DataClass
    implements Insertable<VoiceWorkCategoryData> {
  final int id;
  final String description;
  const VoiceWorkCategoryData({required this.id, required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['description'] = Variable<String>(description);
    return map;
  }

  VoiceWorkCategoryCompanion toCompanion(bool nullToAbsent) {
    return VoiceWorkCategoryCompanion(
      id: Value(id),
      description: Value(description),
    );
  }

  factory VoiceWorkCategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceWorkCategoryData(
      id: serializer.fromJson<int>(json['id']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'description': serializer.toJson<String>(description),
    };
  }

  VoiceWorkCategoryData copyWith({int? id, String? description}) =>
      VoiceWorkCategoryData(
        id: id ?? this.id,
        description: description ?? this.description,
      );
  @override
  String toString() {
    return (StringBuffer('VoiceWorkCategoryData(')
          ..write('id: $id, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceWorkCategoryData &&
          other.id == this.id &&
          other.description == this.description);
}

class VoiceWorkCategoryCompanion
    extends UpdateCompanion<VoiceWorkCategoryData> {
  final Value<int> id;
  final Value<String> description;
  const VoiceWorkCategoryCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
  });
  VoiceWorkCategoryCompanion.insert({
    this.id = const Value.absent(),
    required String description,
  }) : description = Value(description);
  static Insertable<VoiceWorkCategoryData> custom({
    Expression<int>? id,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
    });
  }

  VoiceWorkCategoryCompanion copyWith(
      {Value<int>? id, Value<String>? description}) {
    return VoiceWorkCategoryCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceWorkCategoryCompanion(')
          ..write('id: $id, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $VoiceWorkTable extends VoiceWork
    with TableInfo<$VoiceWorkTable, VoiceWorkData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceWorkTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _diretoryPathMeta =
      const VerificationMeta('diretoryPath');
  @override
  late final GeneratedColumn<String> diretoryPath = GeneratedColumn<String>(
      'diretory_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<int> category = GeneratedColumn<int>(
      'category', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES voice_work_category (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, diretoryPath, category, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_work';
  @override
  VerificationContext validateIntegrity(Insertable<VoiceWorkData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('diretory_path')) {
      context.handle(
          _diretoryPathMeta,
          diretoryPath.isAcceptableOrUnknown(
              data['diretory_path']!, _diretoryPathMeta));
    } else if (isInserting) {
      context.missing(_diretoryPathMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoiceWorkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceWorkData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      diretoryPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diretory_path'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $VoiceWorkTable createAlias(String alias) {
    return $VoiceWorkTable(attachedDatabase, alias);
  }
}

class VoiceWorkData extends DataClass implements Insertable<VoiceWorkData> {
  final int id;
  final String title;
  final String diretoryPath;
  final int category;
  final DateTime? createdAt;
  const VoiceWorkData(
      {required this.id,
      required this.title,
      required this.diretoryPath,
      required this.category,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['diretory_path'] = Variable<String>(diretoryPath);
    map['category'] = Variable<int>(category);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  VoiceWorkCompanion toCompanion(bool nullToAbsent) {
    return VoiceWorkCompanion(
      id: Value(id),
      title: Value(title),
      diretoryPath: Value(diretoryPath),
      category: Value(category),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory VoiceWorkData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceWorkData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      diretoryPath: serializer.fromJson<String>(json['diretoryPath']),
      category: serializer.fromJson<int>(json['category']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'diretoryPath': serializer.toJson<String>(diretoryPath),
      'category': serializer.toJson<int>(category),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  VoiceWorkData copyWith(
          {int? id,
          String? title,
          String? diretoryPath,
          int? category,
          Value<DateTime?> createdAt = const Value.absent()}) =>
      VoiceWorkData(
        id: id ?? this.id,
        title: title ?? this.title,
        diretoryPath: diretoryPath ?? this.diretoryPath,
        category: category ?? this.category,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('VoiceWorkData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('diretoryPath: $diretoryPath, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, diretoryPath, category, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceWorkData &&
          other.id == this.id &&
          other.title == this.title &&
          other.diretoryPath == this.diretoryPath &&
          other.category == this.category &&
          other.createdAt == this.createdAt);
}

class VoiceWorkCompanion extends UpdateCompanion<VoiceWorkData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> diretoryPath;
  final Value<int> category;
  final Value<DateTime?> createdAt;
  const VoiceWorkCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.diretoryPath = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VoiceWorkCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String diretoryPath,
    required int category,
    this.createdAt = const Value.absent(),
  })  : title = Value(title),
        diretoryPath = Value(diretoryPath),
        category = Value(category);
  static Insertable<VoiceWorkData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? diretoryPath,
    Expression<int>? category,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (diretoryPath != null) 'diretory_path': diretoryPath,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VoiceWorkCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? diretoryPath,
      Value<int>? category,
      Value<DateTime?>? createdAt}) {
    return VoiceWorkCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      diretoryPath: diretoryPath ?? this.diretoryPath,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (diretoryPath.present) {
      map['diretory_path'] = Variable<String>(diretoryPath.value);
    }
    if (category.present) {
      map['category'] = Variable<int>(category.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceWorkCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('diretoryPath: $diretoryPath, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VoiceItemTable extends VoiceItem
    with TableInfo<$VoiceItemTable, VoiceItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceItemTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _voiceWorkIdMeta =
      const VerificationMeta('voiceWorkId');
  @override
  late final GeneratedColumn<int> voiceWorkId = GeneratedColumn<int>(
      'voice_work_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES voice_work (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, title, filePath, voiceWorkId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_item';
  @override
  VerificationContext validateIntegrity(Insertable<VoiceItemData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('voice_work_id')) {
      context.handle(
          _voiceWorkIdMeta,
          voiceWorkId.isAcceptableOrUnknown(
              data['voice_work_id']!, _voiceWorkIdMeta));
    } else if (isInserting) {
      context.missing(_voiceWorkIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoiceItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceItemData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      voiceWorkId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}voice_work_id'])!,
    );
  }

  @override
  $VoiceItemTable createAlias(String alias) {
    return $VoiceItemTable(attachedDatabase, alias);
  }
}

class VoiceItemData extends DataClass implements Insertable<VoiceItemData> {
  final int id;
  final String title;
  final String filePath;
  final int voiceWorkId;
  const VoiceItemData(
      {required this.id,
      required this.title,
      required this.filePath,
      required this.voiceWorkId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    map['voice_work_id'] = Variable<int>(voiceWorkId);
    return map;
  }

  VoiceItemCompanion toCompanion(bool nullToAbsent) {
    return VoiceItemCompanion(
      id: Value(id),
      title: Value(title),
      filePath: Value(filePath),
      voiceWorkId: Value(voiceWorkId),
    );
  }

  factory VoiceItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceItemData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      voiceWorkId: serializer.fromJson<int>(json['voiceWorkId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'voiceWorkId': serializer.toJson<int>(voiceWorkId),
    };
  }

  VoiceItemData copyWith(
          {int? id, String? title, String? filePath, int? voiceWorkId}) =>
      VoiceItemData(
        id: id ?? this.id,
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        voiceWorkId: voiceWorkId ?? this.voiceWorkId,
      );
  @override
  String toString() {
    return (StringBuffer('VoiceItemData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('voiceWorkId: $voiceWorkId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, filePath, voiceWorkId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceItemData &&
          other.id == this.id &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.voiceWorkId == this.voiceWorkId);
}

class VoiceItemCompanion extends UpdateCompanion<VoiceItemData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> filePath;
  final Value<int> voiceWorkId;
  const VoiceItemCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.voiceWorkId = const Value.absent(),
  });
  VoiceItemCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String filePath,
    required int voiceWorkId,
  })  : title = Value(title),
        filePath = Value(filePath),
        voiceWorkId = Value(voiceWorkId);
  static Insertable<VoiceItemData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<int>? voiceWorkId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (voiceWorkId != null) 'voice_work_id': voiceWorkId,
    });
  }

  VoiceItemCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? filePath,
      Value<int>? voiceWorkId}) {
    return VoiceItemCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      voiceWorkId: voiceWorkId ?? this.voiceWorkId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (voiceWorkId.present) {
      map['voice_work_id'] = Variable<int>(voiceWorkId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceItemCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('voiceWorkId: $voiceWorkId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  _$AppDatabaseManager get managers => _$AppDatabaseManager(this);
  late final $VoiceWorkCategoryTable voiceWorkCategory =
      $VoiceWorkCategoryTable(this);
  late final $VoiceWorkTable voiceWork = $VoiceWorkTable(this);
  late final $VoiceItemTable voiceItem = $VoiceItemTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [voiceWorkCategory, voiceWork, voiceItem];
}

typedef $$VoiceWorkCategoryTableInsertCompanionBuilder
    = VoiceWorkCategoryCompanion Function({
  Value<int> id,
  required String description,
});
typedef $$VoiceWorkCategoryTableUpdateCompanionBuilder
    = VoiceWorkCategoryCompanion Function({
  Value<int> id,
  Value<String> description,
});

class $$VoiceWorkCategoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VoiceWorkCategoryTable,
    VoiceWorkCategoryData,
    $$VoiceWorkCategoryTableFilterComposer,
    $$VoiceWorkCategoryTableOrderingComposer,
    $$VoiceWorkCategoryTableProcessedTableManager,
    $$VoiceWorkCategoryTableInsertCompanionBuilder,
    $$VoiceWorkCategoryTableUpdateCompanionBuilder> {
  $$VoiceWorkCategoryTableTableManager(
      _$AppDatabase db, $VoiceWorkCategoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$VoiceWorkCategoryTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$VoiceWorkCategoryTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$VoiceWorkCategoryTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> description = const Value.absent(),
          }) =>
              VoiceWorkCategoryCompanion(
            id: id,
            description: description,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String description,
          }) =>
              VoiceWorkCategoryCompanion.insert(
            id: id,
            description: description,
          ),
        ));
}

class $$VoiceWorkCategoryTableProcessedTableManager
    extends ProcessedTableManager<
        _$AppDatabase,
        $VoiceWorkCategoryTable,
        VoiceWorkCategoryData,
        $$VoiceWorkCategoryTableFilterComposer,
        $$VoiceWorkCategoryTableOrderingComposer,
        $$VoiceWorkCategoryTableProcessedTableManager,
        $$VoiceWorkCategoryTableInsertCompanionBuilder,
        $$VoiceWorkCategoryTableUpdateCompanionBuilder> {
  $$VoiceWorkCategoryTableProcessedTableManager(super.$state);
}

class $$VoiceWorkCategoryTableFilterComposer
    extends FilterComposer<_$AppDatabase, $VoiceWorkCategoryTable> {
  $$VoiceWorkCategoryTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter voiceWorkRefs(
      ComposableFilter Function($$VoiceWorkTableFilterComposer f) f) {
    final $$VoiceWorkTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.voiceWork,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder, parentComposers) =>
            $$VoiceWorkTableFilterComposer(ComposerState(
                $state.db, $state.db.voiceWork, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$VoiceWorkCategoryTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $VoiceWorkCategoryTable> {
  $$VoiceWorkCategoryTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$VoiceWorkTableInsertCompanionBuilder = VoiceWorkCompanion Function({
  Value<int> id,
  required String title,
  required String diretoryPath,
  required int category,
  Value<DateTime?> createdAt,
});
typedef $$VoiceWorkTableUpdateCompanionBuilder = VoiceWorkCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> diretoryPath,
  Value<int> category,
  Value<DateTime?> createdAt,
});

class $$VoiceWorkTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VoiceWorkTable,
    VoiceWorkData,
    $$VoiceWorkTableFilterComposer,
    $$VoiceWorkTableOrderingComposer,
    $$VoiceWorkTableProcessedTableManager,
    $$VoiceWorkTableInsertCompanionBuilder,
    $$VoiceWorkTableUpdateCompanionBuilder> {
  $$VoiceWorkTableTableManager(_$AppDatabase db, $VoiceWorkTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$VoiceWorkTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$VoiceWorkTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$VoiceWorkTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> diretoryPath = const Value.absent(),
            Value<int> category = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
          }) =>
              VoiceWorkCompanion(
            id: id,
            title: title,
            diretoryPath: diretoryPath,
            category: category,
            createdAt: createdAt,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String diretoryPath,
            required int category,
            Value<DateTime?> createdAt = const Value.absent(),
          }) =>
              VoiceWorkCompanion.insert(
            id: id,
            title: title,
            diretoryPath: diretoryPath,
            category: category,
            createdAt: createdAt,
          ),
        ));
}

class $$VoiceWorkTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $VoiceWorkTable,
    VoiceWorkData,
    $$VoiceWorkTableFilterComposer,
    $$VoiceWorkTableOrderingComposer,
    $$VoiceWorkTableProcessedTableManager,
    $$VoiceWorkTableInsertCompanionBuilder,
    $$VoiceWorkTableUpdateCompanionBuilder> {
  $$VoiceWorkTableProcessedTableManager(super.$state);
}

class $$VoiceWorkTableFilterComposer
    extends FilterComposer<_$AppDatabase, $VoiceWorkTable> {
  $$VoiceWorkTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get diretoryPath => $state.composableBuilder(
      column: $state.table.diretoryPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$VoiceWorkCategoryTableFilterComposer get category {
    final $$VoiceWorkCategoryTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.category,
            referencedTable: $state.db.voiceWorkCategory,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$VoiceWorkCategoryTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.voiceWorkCategory,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }

  ComposableFilter voiceItemRefs(
      ComposableFilter Function($$VoiceItemTableFilterComposer f) f) {
    final $$VoiceItemTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.voiceItem,
        getReferencedColumn: (t) => t.voiceWorkId,
        builder: (joinBuilder, parentComposers) =>
            $$VoiceItemTableFilterComposer(ComposerState(
                $state.db, $state.db.voiceItem, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$VoiceWorkTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $VoiceWorkTable> {
  $$VoiceWorkTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get diretoryPath => $state.composableBuilder(
      column: $state.table.diretoryPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$VoiceWorkCategoryTableOrderingComposer get category {
    final $$VoiceWorkCategoryTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.category,
            referencedTable: $state.db.voiceWorkCategory,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder, parentComposers) =>
                $$VoiceWorkCategoryTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.voiceWorkCategory,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

typedef $$VoiceItemTableInsertCompanionBuilder = VoiceItemCompanion Function({
  Value<int> id,
  required String title,
  required String filePath,
  required int voiceWorkId,
});
typedef $$VoiceItemTableUpdateCompanionBuilder = VoiceItemCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> filePath,
  Value<int> voiceWorkId,
});

class $$VoiceItemTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VoiceItemTable,
    VoiceItemData,
    $$VoiceItemTableFilterComposer,
    $$VoiceItemTableOrderingComposer,
    $$VoiceItemTableProcessedTableManager,
    $$VoiceItemTableInsertCompanionBuilder,
    $$VoiceItemTableUpdateCompanionBuilder> {
  $$VoiceItemTableTableManager(_$AppDatabase db, $VoiceItemTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$VoiceItemTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$VoiceItemTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$VoiceItemTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<int> voiceWorkId = const Value.absent(),
          }) =>
              VoiceItemCompanion(
            id: id,
            title: title,
            filePath: filePath,
            voiceWorkId: voiceWorkId,
          ),
          getInsertCompanionBuilder: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String filePath,
            required int voiceWorkId,
          }) =>
              VoiceItemCompanion.insert(
            id: id,
            title: title,
            filePath: filePath,
            voiceWorkId: voiceWorkId,
          ),
        ));
}

class $$VoiceItemTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $VoiceItemTable,
    VoiceItemData,
    $$VoiceItemTableFilterComposer,
    $$VoiceItemTableOrderingComposer,
    $$VoiceItemTableProcessedTableManager,
    $$VoiceItemTableInsertCompanionBuilder,
    $$VoiceItemTableUpdateCompanionBuilder> {
  $$VoiceItemTableProcessedTableManager(super.$state);
}

class $$VoiceItemTableFilterComposer
    extends FilterComposer<_$AppDatabase, $VoiceItemTable> {
  $$VoiceItemTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$VoiceWorkTableFilterComposer get voiceWorkId {
    final $$VoiceWorkTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkId,
        referencedTable: $state.db.voiceWork,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$VoiceWorkTableFilterComposer(ComposerState(
                $state.db, $state.db.voiceWork, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$VoiceItemTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $VoiceItemTable> {
  $$VoiceItemTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$VoiceWorkTableOrderingComposer get voiceWorkId {
    final $$VoiceWorkTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkId,
        referencedTable: $state.db.voiceWork,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$VoiceWorkTableOrderingComposer(ComposerState(
                $state.db, $state.db.voiceWork, joinBuilder, parentComposers)));
    return composer;
  }
}

class _$AppDatabaseManager {
  final _$AppDatabase _db;
  _$AppDatabaseManager(this._db);
  $$VoiceWorkCategoryTableTableManager get voiceWorkCategory =>
      $$VoiceWorkCategoryTableTableManager(_db, _db.voiceWorkCategory);
  $$VoiceWorkTableTableManager get voiceWork =>
      $$VoiceWorkTableTableManager(_db, _db.voiceWork);
  $$VoiceItemTableTableManager get voiceItem =>
      $$VoiceItemTableTableManager(_db, _db.voiceItem);
}
