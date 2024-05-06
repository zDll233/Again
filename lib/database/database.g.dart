// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TVoiceWorkCategoryTable extends TVoiceWorkCategory
    with TableInfo<$TVoiceWorkCategoryTable, TVoiceWorkCategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TVoiceWorkCategoryTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 't_voice_work_category';
  @override
  VerificationContext validateIntegrity(
      Insertable<TVoiceWorkCategoryData> instance,
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
  TVoiceWorkCategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TVoiceWorkCategoryData(
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $TVoiceWorkCategoryTable createAlias(String alias) {
    return $TVoiceWorkCategoryTable(attachedDatabase, alias);
  }
}

class TVoiceWorkCategoryData extends DataClass
    implements Insertable<TVoiceWorkCategoryData> {
  final String description;
  const TVoiceWorkCategoryData({required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['description'] = Variable<String>(description);
    return map;
  }

  TVoiceWorkCategoryCompanion toCompanion(bool nullToAbsent) {
    return TVoiceWorkCategoryCompanion(
      description: Value(description),
    );
  }

  factory TVoiceWorkCategoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TVoiceWorkCategoryData(
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

  TVoiceWorkCategoryData copyWith({String? description}) =>
      TVoiceWorkCategoryData(
        description: description ?? this.description,
      );
  @override
  String toString() {
    return (StringBuffer('TVoiceWorkCategoryData(')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => description.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TVoiceWorkCategoryData &&
          other.description == this.description);
}

class TVoiceWorkCategoryCompanion
    extends UpdateCompanion<TVoiceWorkCategoryData> {
  final Value<String> description;
  final Value<int> rowid;
  const TVoiceWorkCategoryCompanion({
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TVoiceWorkCategoryCompanion.insert({
    required String description,
    this.rowid = const Value.absent(),
  }) : description = Value(description);
  static Insertable<TVoiceWorkCategoryData> custom({
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TVoiceWorkCategoryCompanion copyWith(
      {Value<String>? description, Value<int>? rowid}) {
    return TVoiceWorkCategoryCompanion(
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
    return (StringBuffer('TVoiceWorkCategoryCompanion(')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TVoiceWorkTable extends TVoiceWork
    with TableInfo<$TVoiceWorkTable, TVoiceWorkData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TVoiceWorkTable(this.attachedDatabase, [this._alias]);
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
          'REFERENCES t_voice_work_category (description)'));
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
  static const String $name = 't_voice_work';
  @override
  VerificationContext validateIntegrity(Insertable<TVoiceWorkData> instance,
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
  TVoiceWorkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TVoiceWorkData(
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
  $TVoiceWorkTable createAlias(String alias) {
    return $TVoiceWorkTable(attachedDatabase, alias);
  }
}

class TVoiceWorkData extends DataClass implements Insertable<TVoiceWorkData> {
  final String title;
  final String diretoryPath;
  final String category;
  final DateTime? createdAt;
  const TVoiceWorkData(
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

  TVoiceWorkCompanion toCompanion(bool nullToAbsent) {
    return TVoiceWorkCompanion(
      title: Value(title),
      diretoryPath: Value(diretoryPath),
      category: Value(category),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory TVoiceWorkData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TVoiceWorkData(
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

  TVoiceWorkData copyWith(
          {String? title,
          String? diretoryPath,
          String? category,
          Value<DateTime?> createdAt = const Value.absent()}) =>
      TVoiceWorkData(
        title: title ?? this.title,
        diretoryPath: diretoryPath ?? this.diretoryPath,
        category: category ?? this.category,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('TVoiceWorkData(')
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
      (other is TVoiceWorkData &&
          other.title == this.title &&
          other.diretoryPath == this.diretoryPath &&
          other.category == this.category &&
          other.createdAt == this.createdAt);
}

class TVoiceWorkCompanion extends UpdateCompanion<TVoiceWorkData> {
  final Value<String> title;
  final Value<String> diretoryPath;
  final Value<String> category;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const TVoiceWorkCompanion({
    this.title = const Value.absent(),
    this.diretoryPath = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TVoiceWorkCompanion.insert({
    required String title,
    required String diretoryPath,
    required String category,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        diretoryPath = Value(diretoryPath),
        category = Value(category);
  static Insertable<TVoiceWorkData> custom({
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

  TVoiceWorkCompanion copyWith(
      {Value<String>? title,
      Value<String>? diretoryPath,
      Value<String>? category,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return TVoiceWorkCompanion(
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
    return (StringBuffer('TVoiceWorkCompanion(')
          ..write('title: $title, ')
          ..write('diretoryPath: $diretoryPath, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TVoiceItemTable extends TVoiceItem
    with TableInfo<$TVoiceItemTable, TVoiceItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TVoiceItemTable(this.attachedDatabase, [this._alias]);
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
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_voice_work (title)'));
  @override
  List<GeneratedColumn> get $columns => [title, filePath, voiceWorkTitle];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_voice_item';
  @override
  VerificationContext validateIntegrity(Insertable<TVoiceItemData> instance,
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
  TVoiceItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TVoiceItemData(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      voiceWorkTitle: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}voice_work_title'])!,
    );
  }

  @override
  $TVoiceItemTable createAlias(String alias) {
    return $TVoiceItemTable(attachedDatabase, alias);
  }
}

class TVoiceItemData extends DataClass implements Insertable<TVoiceItemData> {
  final String title;
  final String filePath;
  final String voiceWorkTitle;
  const TVoiceItemData(
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

  TVoiceItemCompanion toCompanion(bool nullToAbsent) {
    return TVoiceItemCompanion(
      title: Value(title),
      filePath: Value(filePath),
      voiceWorkTitle: Value(voiceWorkTitle),
    );
  }

  factory TVoiceItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TVoiceItemData(
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

  TVoiceItemData copyWith(
          {String? title, String? filePath, String? voiceWorkTitle}) =>
      TVoiceItemData(
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        voiceWorkTitle: voiceWorkTitle ?? this.voiceWorkTitle,
      );
  @override
  String toString() {
    return (StringBuffer('TVoiceItemData(')
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
      (other is TVoiceItemData &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.voiceWorkTitle == this.voiceWorkTitle);
}

class TVoiceItemCompanion extends UpdateCompanion<TVoiceItemData> {
  final Value<String> title;
  final Value<String> filePath;
  final Value<String> voiceWorkTitle;
  final Value<int> rowid;
  const TVoiceItemCompanion({
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.voiceWorkTitle = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TVoiceItemCompanion.insert({
    required String title,
    required String filePath,
    required String voiceWorkTitle,
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        filePath = Value(filePath),
        voiceWorkTitle = Value(voiceWorkTitle);
  static Insertable<TVoiceItemData> custom({
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

  TVoiceItemCompanion copyWith(
      {Value<String>? title,
      Value<String>? filePath,
      Value<String>? voiceWorkTitle,
      Value<int>? rowid}) {
    return TVoiceItemCompanion(
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
    return (StringBuffer('TVoiceItemCompanion(')
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
  late final $TVoiceWorkCategoryTable tVoiceWorkCategory =
      $TVoiceWorkCategoryTable(this);
  late final $TVoiceWorkTable tVoiceWork = $TVoiceWorkTable(this);
  late final $TVoiceItemTable tVoiceItem = $TVoiceItemTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tVoiceWorkCategory, tVoiceWork, tVoiceItem];
}

typedef $$TVoiceWorkCategoryTableInsertCompanionBuilder
    = TVoiceWorkCategoryCompanion Function({
  required String description,
  Value<int> rowid,
});
typedef $$TVoiceWorkCategoryTableUpdateCompanionBuilder
    = TVoiceWorkCategoryCompanion Function({
  Value<String> description,
  Value<int> rowid,
});

class $$TVoiceWorkCategoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceWorkCategoryTable,
    TVoiceWorkCategoryData,
    $$TVoiceWorkCategoryTableFilterComposer,
    $$TVoiceWorkCategoryTableOrderingComposer,
    $$TVoiceWorkCategoryTableProcessedTableManager,
    $$TVoiceWorkCategoryTableInsertCompanionBuilder,
    $$TVoiceWorkCategoryTableUpdateCompanionBuilder> {
  $$TVoiceWorkCategoryTableTableManager(
      _$AppDatabase db, $TVoiceWorkCategoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TVoiceWorkCategoryTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$TVoiceWorkCategoryTableOrderingComposer(
              ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$TVoiceWorkCategoryTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceWorkCategoryCompanion(
            description: description,
            rowid: rowid,
          ),
          getInsertCompanionBuilder: ({
            required String description,
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceWorkCategoryCompanion.insert(
            description: description,
            rowid: rowid,
          ),
        ));
}

class $$TVoiceWorkCategoryTableProcessedTableManager
    extends ProcessedTableManager<
        _$AppDatabase,
        $TVoiceWorkCategoryTable,
        TVoiceWorkCategoryData,
        $$TVoiceWorkCategoryTableFilterComposer,
        $$TVoiceWorkCategoryTableOrderingComposer,
        $$TVoiceWorkCategoryTableProcessedTableManager,
        $$TVoiceWorkCategoryTableInsertCompanionBuilder,
        $$TVoiceWorkCategoryTableUpdateCompanionBuilder> {
  $$TVoiceWorkCategoryTableProcessedTableManager(super.$state);
}

class $$TVoiceWorkCategoryTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TVoiceWorkCategoryTable> {
  $$TVoiceWorkCategoryTableFilterComposer(super.$state);
  ColumnFilters<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter tVoiceWorkRefs(
      ComposableFilter Function($$TVoiceWorkTableFilterComposer f) f) {
    final $$TVoiceWorkTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.description,
        referencedTable: $state.db.tVoiceWork,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceWorkTableFilterComposer(ComposerState($state.db,
                $state.db.tVoiceWork, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$TVoiceWorkCategoryTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TVoiceWorkCategoryTable> {
  $$TVoiceWorkCategoryTableOrderingComposer(super.$state);
  ColumnOrderings<String> get description => $state.composableBuilder(
      column: $state.table.description,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TVoiceWorkTableInsertCompanionBuilder = TVoiceWorkCompanion Function({
  required String title,
  required String diretoryPath,
  required String category,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$TVoiceWorkTableUpdateCompanionBuilder = TVoiceWorkCompanion Function({
  Value<String> title,
  Value<String> diretoryPath,
  Value<String> category,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

class $$TVoiceWorkTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceWorkTable,
    TVoiceWorkData,
    $$TVoiceWorkTableFilterComposer,
    $$TVoiceWorkTableOrderingComposer,
    $$TVoiceWorkTableProcessedTableManager,
    $$TVoiceWorkTableInsertCompanionBuilder,
    $$TVoiceWorkTableUpdateCompanionBuilder> {
  $$TVoiceWorkTableTableManager(_$AppDatabase db, $TVoiceWorkTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TVoiceWorkTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TVoiceWorkTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$TVoiceWorkTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> title = const Value.absent(),
            Value<String> diretoryPath = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceWorkCompanion(
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
              TVoiceWorkCompanion.insert(
            title: title,
            diretoryPath: diretoryPath,
            category: category,
            createdAt: createdAt,
            rowid: rowid,
          ),
        ));
}

class $$TVoiceWorkTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $TVoiceWorkTable,
    TVoiceWorkData,
    $$TVoiceWorkTableFilterComposer,
    $$TVoiceWorkTableOrderingComposer,
    $$TVoiceWorkTableProcessedTableManager,
    $$TVoiceWorkTableInsertCompanionBuilder,
    $$TVoiceWorkTableUpdateCompanionBuilder> {
  $$TVoiceWorkTableProcessedTableManager(super.$state);
}

class $$TVoiceWorkTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TVoiceWorkTable> {
  $$TVoiceWorkTableFilterComposer(super.$state);
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

  $$TVoiceWorkCategoryTableFilterComposer get category {
    final $$TVoiceWorkCategoryTableFilterComposer composer = $state
        .composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.category,
            referencedTable: $state.db.tVoiceWorkCategory,
            getReferencedColumn: (t) => t.description,
            builder: (joinBuilder, parentComposers) =>
                $$TVoiceWorkCategoryTableFilterComposer(ComposerState(
                    $state.db,
                    $state.db.tVoiceWorkCategory,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }

  ComposableFilter tVoiceItemRefs(
      ComposableFilter Function($$TVoiceItemTableFilterComposer f) f) {
    final $$TVoiceItemTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.title,
        referencedTable: $state.db.tVoiceItem,
        getReferencedColumn: (t) => t.voiceWorkTitle,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceItemTableFilterComposer(ComposerState($state.db,
                $state.db.tVoiceItem, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$TVoiceWorkTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TVoiceWorkTable> {
  $$TVoiceWorkTableOrderingComposer(super.$state);
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

  $$TVoiceWorkCategoryTableOrderingComposer get category {
    final $$TVoiceWorkCategoryTableOrderingComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.category,
            referencedTable: $state.db.tVoiceWorkCategory,
            getReferencedColumn: (t) => t.description,
            builder: (joinBuilder, parentComposers) =>
                $$TVoiceWorkCategoryTableOrderingComposer(ComposerState(
                    $state.db,
                    $state.db.tVoiceWorkCategory,
                    joinBuilder,
                    parentComposers)));
    return composer;
  }
}

typedef $$TVoiceItemTableInsertCompanionBuilder = TVoiceItemCompanion Function({
  required String title,
  required String filePath,
  required String voiceWorkTitle,
  Value<int> rowid,
});
typedef $$TVoiceItemTableUpdateCompanionBuilder = TVoiceItemCompanion Function({
  Value<String> title,
  Value<String> filePath,
  Value<String> voiceWorkTitle,
  Value<int> rowid,
});

class $$TVoiceItemTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceItemTable,
    TVoiceItemData,
    $$TVoiceItemTableFilterComposer,
    $$TVoiceItemTableOrderingComposer,
    $$TVoiceItemTableProcessedTableManager,
    $$TVoiceItemTableInsertCompanionBuilder,
    $$TVoiceItemTableUpdateCompanionBuilder> {
  $$TVoiceItemTableTableManager(_$AppDatabase db, $TVoiceItemTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TVoiceItemTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TVoiceItemTableOrderingComposer(ComposerState(db, table)),
          getChildManagerBuilder: (p) =>
              $$TVoiceItemTableProcessedTableManager(p),
          getUpdateCompanionBuilder: ({
            Value<String> title = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> voiceWorkTitle = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceItemCompanion(
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
              TVoiceItemCompanion.insert(
            title: title,
            filePath: filePath,
            voiceWorkTitle: voiceWorkTitle,
            rowid: rowid,
          ),
        ));
}

class $$TVoiceItemTableProcessedTableManager extends ProcessedTableManager<
    _$AppDatabase,
    $TVoiceItemTable,
    TVoiceItemData,
    $$TVoiceItemTableFilterComposer,
    $$TVoiceItemTableOrderingComposer,
    $$TVoiceItemTableProcessedTableManager,
    $$TVoiceItemTableInsertCompanionBuilder,
    $$TVoiceItemTableUpdateCompanionBuilder> {
  $$TVoiceItemTableProcessedTableManager(super.$state);
}

class $$TVoiceItemTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TVoiceItemTable> {
  $$TVoiceItemTableFilterComposer(super.$state);
  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$TVoiceWorkTableFilterComposer get voiceWorkTitle {
    final $$TVoiceWorkTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkTitle,
        referencedTable: $state.db.tVoiceWork,
        getReferencedColumn: (t) => t.title,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceWorkTableFilterComposer(ComposerState($state.db,
                $state.db.tVoiceWork, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TVoiceItemTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TVoiceItemTable> {
  $$TVoiceItemTableOrderingComposer(super.$state);
  ColumnOrderings<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$TVoiceWorkTableOrderingComposer get voiceWorkTitle {
    final $$TVoiceWorkTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkTitle,
        referencedTable: $state.db.tVoiceWork,
        getReferencedColumn: (t) => t.title,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceWorkTableOrderingComposer(ComposerState($state.db,
                $state.db.tVoiceWork, joinBuilder, parentComposers)));
    return composer;
  }
}

class _$AppDatabaseManager {
  final _$AppDatabase _db;
  _$AppDatabaseManager(this._db);
  $$TVoiceWorkCategoryTableTableManager get tVoiceWorkCategory =>
      $$TVoiceWorkCategoryTableTableManager(_db, _db.tVoiceWorkCategory);
  $$TVoiceWorkTableTableManager get tVoiceWork =>
      $$TVoiceWorkTableTableManager(_db, _db.tVoiceWork);
  $$TVoiceItemTableTableManager get tVoiceItem =>
      $$TVoiceItemTableTableManager(_db, _db.tVoiceItem);
}
