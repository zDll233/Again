// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VoiceWorkCategoryTable extends VoiceWorkCategory
    with TableInfo<$VoiceWorkCategoryTable, VoiceWorkCategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceWorkCategoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [description];
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
  Set<GeneratedColumn> get $primaryKey => {description};
  @override
  VoiceWorkCategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceWorkCategoryData(
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
  final String description;
  const VoiceWorkCategoryData({required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['description'] = Variable<String>(description);
    return map;
  }

  VoiceWorkCategoryCompanion toCompanion(bool nullToAbsent) {
    return VoiceWorkCategoryCompanion(
      description: Value(description),
    );
  }

  factory VoiceWorkCategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceWorkCategoryData(
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'description': serializer.toJson<String>(description),
    };
  }

  VoiceWorkCategoryData copyWith({String? description}) =>
      VoiceWorkCategoryData(
        description: description ?? this.description,
      );
  @override
  String toString() {
    return (StringBuffer('VoiceWorkCategoryData(')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => description.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceWorkCategoryData && other.description == this.description);
}

class VoiceWorkCategoryCompanion
    extends UpdateCompanion<VoiceWorkCategoryData> {
  final Value<String> description;
  final Value<int> rowid;
  const VoiceWorkCategoryCompanion({
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoiceWorkCategoryCompanion.insert({
    required String description,
    this.rowid = const Value.absent(),
  }) : description = Value(description);
  static Insertable<VoiceWorkCategoryData> custom({
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoiceWorkCategoryCompanion copyWith(
      {Value<String>? description, Value<int>? rowid}) {
    return VoiceWorkCategoryCompanion(
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceWorkCategoryCompanion(')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES voice_work_category (description)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [title, diretoryPath, category, createdAt];
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
  Set<GeneratedColumn> get $primaryKey => {title};
  @override
  VoiceWorkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceWorkData(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      diretoryPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diretory_path'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
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
  final String title;
  final String diretoryPath;
  final String category;
  final DateTime? createdAt;
  const VoiceWorkData(
      {required this.title,
      required this.diretoryPath,
      required this.category,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['diretory_path'] = Variable<String>(diretoryPath);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  VoiceWorkCompanion toCompanion(bool nullToAbsent) {
    return VoiceWorkCompanion(
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
      title: serializer.fromJson<String>(json['title']),
      diretoryPath: serializer.fromJson<String>(json['diretoryPath']),
      category: serializer.fromJson<String>(json['category']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'diretoryPath': serializer.toJson<String>(diretoryPath),
      'category': serializer.toJson<String>(category),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  VoiceWorkData copyWith(
          {String? title,
          String? diretoryPath,
          String? category,
          Value<DateTime?> createdAt = const Value.absent()}) =>
      VoiceWorkData(
        title: title ?? this.title,
        diretoryPath: diretoryPath ?? this.diretoryPath,
        category: category ?? this.category,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('VoiceWorkData(')
          ..write('title: $title, ')
          ..write('diretoryPath: $diretoryPath, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, diretoryPath, category, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceWorkData &&
          other.title == this.title &&
          other.diretoryPath == this.diretoryPath &&
          other.category == this.category &&
          other.createdAt == this.createdAt);
}

class VoiceWorkCompanion extends UpdateCompanion<VoiceWorkData> {
  final Value<String> title;
  final Value<String> diretoryPath;
  final Value<String> category;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const VoiceWorkCompanion({
    this.title = const Value.absent(),
    this.diretoryPath = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoiceWorkCompanion.insert({
    required String title,
    required String diretoryPath,
    required String category,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        diretoryPath = Value(diretoryPath),
        category = Value(category);
  static Insertable<VoiceWorkData> custom({
    Expression<String>? title,
    Expression<String>? diretoryPath,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (diretoryPath != null) 'diretory_path': diretoryPath,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoiceWorkCompanion copyWith(
      {Value<String>? title,
      Value<String>? diretoryPath,
      Value<String>? category,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return VoiceWorkCompanion(
      title: title ?? this.title,
      diretoryPath: diretoryPath ?? this.diretoryPath,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (diretoryPath.present) {
      map['diretory_path'] = Variable<String>(diretoryPath.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceWorkCompanion(')
          ..write('title: $title, ')
          ..write('diretoryPath: $diretoryPath, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _voiceWorkTitleMeta =
      const VerificationMeta('voiceWorkTitle');
  @override
  late final GeneratedColumn<String> voiceWorkTitle = GeneratedColumn<String>(
      'voice_work_title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES voice_work (title)'));
  @override
  List<GeneratedColumn> get $columns => [title, filePath, voiceWorkTitle];
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
    if (data.containsKey('voice_work_title')) {
      context.handle(
          _voiceWorkTitleMeta,
          voiceWorkTitle.isAcceptableOrUnknown(
              data['voice_work_title']!, _voiceWorkTitleMeta));
    } else if (isInserting) {
      context.missing(_voiceWorkTitleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {title};
  @override
  VoiceItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceItemData(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      voiceWorkTitle: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}voice_work_title'])!,
    );
  }

  @override
  $VoiceItemTable createAlias(String alias) {
    return $VoiceItemTable(attachedDatabase, alias);
  }
}

class VoiceItemData extends DataClass implements Insertable<VoiceItemData> {
  final String title;
  final String filePath;
  final String voiceWorkTitle;
  const VoiceItemData(
      {required this.title,
      required this.filePath,
      required this.voiceWorkTitle});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    map['voice_work_title'] = Variable<String>(voiceWorkTitle);
    return map;
  }

  VoiceItemCompanion toCompanion(bool nullToAbsent) {
    return VoiceItemCompanion(
      title: Value(title),
      filePath: Value(filePath),
      voiceWorkTitle: Value(voiceWorkTitle),
    );
  }

  factory VoiceItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceItemData(
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      voiceWorkTitle: serializer.fromJson<String>(json['voiceWorkTitle']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'voiceWorkTitle': serializer.toJson<String>(voiceWorkTitle),
    };
  }

  VoiceItemData copyWith(
          {String? title, String? filePath, String? voiceWorkTitle}) =>
      VoiceItemData(
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        voiceWorkTitle: voiceWorkTitle ?? this.voiceWorkTitle,
      );
  @override
  String toString() {
    return (StringBuffer('VoiceItemData(')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('voiceWorkTitle: $voiceWorkTitle')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, filePath, voiceWorkTitle);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceItemData &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.voiceWorkTitle == this.voiceWorkTitle);
}

class VoiceItemCompanion extends UpdateCompanion<VoiceItemData> {
  final Value<String> title;
  final Value<String> filePath;
  final Value<String> voiceWorkTitle;
  final Value<int> rowid;
  const VoiceItemCompanion({
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.voiceWorkTitle = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoiceItemCompanion.insert({
    required String title,
    required String filePath,
    required String voiceWorkTitle,
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        filePath = Value(filePath),
        voiceWorkTitle = Value(voiceWorkTitle);
  static Insertable<VoiceItemData> custom({
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? voiceWorkTitle,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (voiceWorkTitle != null) 'voice_work_title': voiceWorkTitle,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoiceItemCompanion copyWith(
      {Value<String>? title,
      Value<String>? filePath,
      Value<String>? voiceWorkTitle,
      Value<int>? rowid}) {
    return VoiceItemCompanion(
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      voiceWorkTitle: voiceWorkTitle ?? this.voiceWorkTitle,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (voiceWorkTitle.present) {
      map['voice_work_title'] = Variable<String>(voiceWorkTitle.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceItemCompanion(')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('voiceWorkTitle: $voiceWorkTitle, ')
          ..write('rowid: $rowid')
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
  required String description,
  Value<int> rowid,
});
typedef $$VoiceWorkCategoryTableUpdateCompanionBuilder
    = VoiceWorkCategoryCompanion Function({
  Value<String> description,
  Value<int> rowid,
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
            Value<String> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VoiceWorkCategoryCompanion(
            description: description,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String description,
            Value<int> rowid = const Value.absent(),
          }) =>
              VoiceWorkCategoryCompanion.insert(
            description: description,
            rowid: rowid,
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
  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter voiceWorkRefs(
      ComposableFilter Function($$VoiceWorkTableFilterComposer f) f) {
    final $$VoiceWorkTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.description,
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
  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$VoiceWorkTableInsertCompanionBuilder = VoiceWorkCompanion Function({
  required String title,
  required String diretoryPath,
  required String category,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$VoiceWorkTableUpdateCompanionBuilder = VoiceWorkCompanion Function({
  Value<String> title,
  Value<String> diretoryPath,
  Value<String> category,
  Value<DateTime?> createdAt,
  Value<int> rowid,
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
            Value<String> title = const Value.absent(),
            Value<String> diretoryPath = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VoiceWorkCompanion(
            title: title,
            diretoryPath: diretoryPath,
            category: category,
            createdAt: createdAt,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String title,
            required String diretoryPath,
            required String category,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VoiceWorkCompanion.insert(
            title: title,
            diretoryPath: diretoryPath,
            category: category,
            createdAt: createdAt,
            rowid: rowid,
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
            getReferencedColumn: (t) => t.description,
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
        getCurrentColumn: (t) => t.title,
        referencedTable: $state.db.voiceItem,
        getReferencedColumn: (t) => t.voiceWorkTitle,
        builder: (joinBuilder, parentComposers) =>
            $$VoiceItemTableFilterComposer(ComposerState(
                $state.db, $state.db.voiceItem, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$VoiceWorkTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $VoiceWorkTable> {
  $$VoiceWorkTableOrderingComposer(super.$state);
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
            getReferencedColumn: (t) => t.description,
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
  required String title,
  required String filePath,
  required String voiceWorkTitle,
  Value<int> rowid,
});
typedef $$VoiceItemTableUpdateCompanionBuilder = VoiceItemCompanion Function({
  Value<String> title,
  Value<String> filePath,
  Value<String> voiceWorkTitle,
  Value<int> rowid,
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
            Value<String> title = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> voiceWorkTitle = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VoiceItemCompanion(
            title: title,
            filePath: filePath,
            voiceWorkTitle: voiceWorkTitle,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String title,
            required String filePath,
            required String voiceWorkTitle,
            Value<int> rowid = const Value.absent(),
          }) =>
              VoiceItemCompanion.insert(
            title: title,
            filePath: filePath,
            voiceWorkTitle: voiceWorkTitle,
            rowid: rowid,
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
  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$VoiceWorkTableFilterComposer get voiceWorkTitle {
    final $$VoiceWorkTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkTitle,
        referencedTable: $state.db.voiceWork,
        getReferencedColumn: (t) => t.title,
        builder: (joinBuilder, parentComposers) =>
            $$VoiceWorkTableFilterComposer(ComposerState(
                $state.db, $state.db.voiceWork, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$VoiceItemTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $VoiceItemTable> {
  $$VoiceItemTableOrderingComposer(super.$state);
  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$VoiceWorkTableOrderingComposer get voiceWorkTitle {
    final $$VoiceWorkTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkTitle,
        referencedTable: $state.db.voiceWork,
        getReferencedColumn: (t) => t.title,
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
