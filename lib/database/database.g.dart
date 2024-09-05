// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: invalid_use_of_internal_member, unnecessary_null_comparison

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
  TVoiceWorkCategoryData copyWithCompanion(TVoiceWorkCategoryCompanion data) {
    return TVoiceWorkCategoryData(
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

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
  static const VerificationMeta _directoryPathMeta =
      const VerificationMeta('directoryPath');
  @override
  late final GeneratedColumn<String> directoryPath = GeneratedColumn<String>(
      'directory_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _coverPathMeta =
      const VerificationMeta('coverPath');
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
      'cover_path', aliasedName, false,
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
      [title, directoryPath, coverPath, category, createdAt];
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
    if (data.containsKey('directory_path')) {
      context.handle(
          _directoryPathMeta,
          directoryPath.isAcceptableOrUnknown(
              data['directory_path']!, _directoryPathMeta));
    } else if (isInserting) {
      context.missing(_directoryPathMeta);
    }
    if (data.containsKey('cover_path')) {
      context.handle(_coverPathMeta,
          coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));
    } else if (isInserting) {
      context.missing(_coverPathMeta);
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
  Set<GeneratedColumn> get $primaryKey => {directoryPath};
  @override
  TVoiceWorkData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TVoiceWorkData(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      directoryPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}directory_path'])!,
      coverPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_path'])!,
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
  final String directoryPath;
  final String coverPath;
  final String category;
  final DateTime? createdAt;
  const TVoiceWorkData(
      {required this.title,
      required this.directoryPath,
      required this.coverPath,
      required this.category,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['directory_path'] = Variable<String>(directoryPath);
    map['cover_path'] = Variable<String>(coverPath);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  TVoiceWorkCompanion toCompanion(bool nullToAbsent) {
    return TVoiceWorkCompanion(
      title: Value(title),
      directoryPath: Value(directoryPath),
      coverPath: Value(coverPath),
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
      directoryPath: serializer.fromJson<String>(json['directoryPath']),
      coverPath: serializer.fromJson<String>(json['coverPath']),
      category: serializer.fromJson<String>(json['category']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'directoryPath': serializer.toJson<String>(directoryPath),
      'coverPath': serializer.toJson<String>(coverPath),
      'category': serializer.toJson<String>(category),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  TVoiceWorkData copyWith(
          {String? title,
          String? directoryPath,
          String? coverPath,
          String? category,
          Value<DateTime?> createdAt = const Value.absent()}) =>
      TVoiceWorkData(
        title: title ?? this.title,
        directoryPath: directoryPath ?? this.directoryPath,
        coverPath: coverPath ?? this.coverPath,
        category: category ?? this.category,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  TVoiceWorkData copyWithCompanion(TVoiceWorkCompanion data) {
    return TVoiceWorkData(
      title: data.title.present ? data.title.value : this.title,
      directoryPath: data.directoryPath.present
          ? data.directoryPath.value
          : this.directoryPath,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      category: data.category.present ? data.category.value : this.category,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TVoiceWorkData(')
          ..write('title: $title, ')
          ..write('directoryPath: $directoryPath, ')
          ..write('coverPath: $coverPath, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(title, directoryPath, coverPath, category, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TVoiceWorkData &&
          other.title == this.title &&
          other.directoryPath == this.directoryPath &&
          other.coverPath == this.coverPath &&
          other.category == this.category &&
          other.createdAt == this.createdAt);
}

class TVoiceWorkCompanion extends UpdateCompanion<TVoiceWorkData> {
  final Value<String> title;
  final Value<String> directoryPath;
  final Value<String> coverPath;
  final Value<String> category;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const TVoiceWorkCompanion({
    this.title = const Value.absent(),
    this.directoryPath = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TVoiceWorkCompanion.insert({
    required String title,
    required String directoryPath,
    required String coverPath,
    required String category,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        directoryPath = Value(directoryPath),
        coverPath = Value(coverPath),
        category = Value(category);
  static Insertable<TVoiceWorkData> custom({
    Expression<String>? title,
    Expression<String>? directoryPath,
    Expression<String>? coverPath,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (directoryPath != null) 'directory_path': directoryPath,
      if (coverPath != null) 'cover_path': coverPath,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TVoiceWorkCompanion copyWith(
      {Value<String>? title,
      Value<String>? directoryPath,
      Value<String>? coverPath,
      Value<String>? category,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return TVoiceWorkCompanion(
      title: title ?? this.title,
      directoryPath: directoryPath ?? this.directoryPath,
      coverPath: coverPath ?? this.coverPath,
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
    if (directoryPath.present) {
      map['directory_path'] = Variable<String>(directoryPath.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
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
          ..write('directoryPath: $directoryPath, ')
          ..write('coverPath: $coverPath, ')
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
  static const VerificationMeta _voiceWorkPathMeta =
      const VerificationMeta('voiceWorkPath');
  @override
  late final GeneratedColumn<String> voiceWorkPath = GeneratedColumn<String>(
      'voice_work_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_voice_work (directory_path)'));
  @override
  List<GeneratedColumn> get $columns => [title, filePath, voiceWorkPath];
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
    if (data.containsKey('voice_work_path')) {
      context.handle(
          _voiceWorkPathMeta,
          voiceWorkPath.isAcceptableOrUnknown(
              data['voice_work_path']!, _voiceWorkPathMeta));
    } else if (isInserting) {
      context.missing(_voiceWorkPathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {filePath};
  @override
  TVoiceItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TVoiceItemData(
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      voiceWorkPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}voice_work_path'])!,
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
  final String voiceWorkPath;
  const TVoiceItemData(
      {required this.title,
      required this.filePath,
      required this.voiceWorkPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['file_path'] = Variable<String>(filePath);
    map['voice_work_path'] = Variable<String>(voiceWorkPath);
    return map;
  }

  TVoiceItemCompanion toCompanion(bool nullToAbsent) {
    return TVoiceItemCompanion(
      title: Value(title),
      filePath: Value(filePath),
      voiceWorkPath: Value(voiceWorkPath),
    );
  }

  factory TVoiceItemData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TVoiceItemData(
      title: serializer.fromJson<String>(json['title']),
      filePath: serializer.fromJson<String>(json['filePath']),
      voiceWorkPath: serializer.fromJson<String>(json['voiceWorkPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'filePath': serializer.toJson<String>(filePath),
      'voiceWorkPath': serializer.toJson<String>(voiceWorkPath),
    };
  }

  TVoiceItemData copyWith(
          {String? title, String? filePath, String? voiceWorkPath}) =>
      TVoiceItemData(
        title: title ?? this.title,
        filePath: filePath ?? this.filePath,
        voiceWorkPath: voiceWorkPath ?? this.voiceWorkPath,
      );
  TVoiceItemData copyWithCompanion(TVoiceItemCompanion data) {
    return TVoiceItemData(
      title: data.title.present ? data.title.value : this.title,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      voiceWorkPath: data.voiceWorkPath.present
          ? data.voiceWorkPath.value
          : this.voiceWorkPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TVoiceItemData(')
          ..write('title: $title, ')
          ..write('filePath: $filePath, ')
          ..write('voiceWorkPath: $voiceWorkPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, filePath, voiceWorkPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TVoiceItemData &&
          other.title == this.title &&
          other.filePath == this.filePath &&
          other.voiceWorkPath == this.voiceWorkPath);
}

class TVoiceItemCompanion extends UpdateCompanion<TVoiceItemData> {
  final Value<String> title;
  final Value<String> filePath;
  final Value<String> voiceWorkPath;
  final Value<int> rowid;
  const TVoiceItemCompanion({
    this.title = const Value.absent(),
    this.filePath = const Value.absent(),
    this.voiceWorkPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TVoiceItemCompanion.insert({
    required String title,
    required String filePath,
    required String voiceWorkPath,
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        filePath = Value(filePath),
        voiceWorkPath = Value(voiceWorkPath);
  static Insertable<TVoiceItemData> custom({
    Expression<String>? title,
    Expression<String>? filePath,
    Expression<String>? voiceWorkPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (filePath != null) 'file_path': filePath,
      if (voiceWorkPath != null) 'voice_work_path': voiceWorkPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TVoiceItemCompanion copyWith(
      {Value<String>? title,
      Value<String>? filePath,
      Value<String>? voiceWorkPath,
      Value<int>? rowid}) {
    return TVoiceItemCompanion(
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      voiceWorkPath: voiceWorkPath ?? this.voiceWorkPath,
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
    if (voiceWorkPath.present) {
      map['voice_work_path'] = Variable<String>(voiceWorkPath.value);
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
          ..write('voiceWorkPath: $voiceWorkPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TCVTable extends TCV with TableInfo<$TCVTable, TCVData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TCVTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cvNameMeta = const VerificationMeta('cvName');
  @override
  late final GeneratedColumn<String> cvName = GeneratedColumn<String>(
      'cv_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cvName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tcv';
  @override
  VerificationContext validateIntegrity(Insertable<TCVData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cv_name')) {
      context.handle(_cvNameMeta,
          cvName.isAcceptableOrUnknown(data['cv_name']!, _cvNameMeta));
    } else if (isInserting) {
      context.missing(_cvNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cvName};
  @override
  TCVData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TCVData(
      cvName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cv_name'])!,
    );
  }

  @override
  $TCVTable createAlias(String alias) {
    return $TCVTable(attachedDatabase, alias);
  }
}

class TCVData extends DataClass implements Insertable<TCVData> {
  final String cvName;
  const TCVData({required this.cvName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cv_name'] = Variable<String>(cvName);
    return map;
  }

  TCVCompanion toCompanion(bool nullToAbsent) {
    return TCVCompanion(
      cvName: Value(cvName),
    );
  }

  factory TCVData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TCVData(
      cvName: serializer.fromJson<String>(json['cvName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cvName': serializer.toJson<String>(cvName),
    };
  }

  TCVData copyWith({String? cvName}) => TCVData(
        cvName: cvName ?? this.cvName,
      );
  TCVData copyWithCompanion(TCVCompanion data) {
    return TCVData(
      cvName: data.cvName.present ? data.cvName.value : this.cvName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TCVData(')
          ..write('cvName: $cvName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => cvName.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TCVData && other.cvName == this.cvName);
}

class TCVCompanion extends UpdateCompanion<TCVData> {
  final Value<String> cvName;
  final Value<int> rowid;
  const TCVCompanion({
    this.cvName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TCVCompanion.insert({
    required String cvName,
    this.rowid = const Value.absent(),
  }) : cvName = Value(cvName);
  static Insertable<TCVData> custom({
    Expression<String>? cvName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cvName != null) 'cv_name': cvName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TCVCompanion copyWith({Value<String>? cvName, Value<int>? rowid}) {
    return TCVCompanion(
      cvName: cvName ?? this.cvName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cvName.present) {
      map['cv_name'] = Variable<String>(cvName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TCVCompanion(')
          ..write('cvName: $cvName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TVoiceCVTable extends TVoiceCV
    with TableInfo<$TVoiceCVTable, TVoiceCVData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TVoiceCVTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _voiceWorkPathMeta =
      const VerificationMeta('voiceWorkPath');
  @override
  late final GeneratedColumn<String> voiceWorkPath = GeneratedColumn<String>(
      'voice_work_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES t_voice_work (directory_path)'));
  static const VerificationMeta _cvNameMeta = const VerificationMeta('cvName');
  @override
  late final GeneratedColumn<String> cvName = GeneratedColumn<String>(
      'cv_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES tcv (cv_name)'));
  @override
  List<GeneratedColumn> get $columns => [voiceWorkPath, cvName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 't_voice_c_v';
  @override
  VerificationContext validateIntegrity(Insertable<TVoiceCVData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('voice_work_path')) {
      context.handle(
          _voiceWorkPathMeta,
          voiceWorkPath.isAcceptableOrUnknown(
              data['voice_work_path']!, _voiceWorkPathMeta));
    } else if (isInserting) {
      context.missing(_voiceWorkPathMeta);
    }
    if (data.containsKey('cv_name')) {
      context.handle(_cvNameMeta,
          cvName.isAcceptableOrUnknown(data['cv_name']!, _cvNameMeta));
    } else if (isInserting) {
      context.missing(_cvNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {voiceWorkPath, cvName};
  @override
  TVoiceCVData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TVoiceCVData(
      voiceWorkPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}voice_work_path'])!,
      cvName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cv_name'])!,
    );
  }

  @override
  $TVoiceCVTable createAlias(String alias) {
    return $TVoiceCVTable(attachedDatabase, alias);
  }
}

class TVoiceCVData extends DataClass implements Insertable<TVoiceCVData> {
  final String voiceWorkPath;
  final String cvName;
  const TVoiceCVData({required this.voiceWorkPath, required this.cvName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['voice_work_path'] = Variable<String>(voiceWorkPath);
    map['cv_name'] = Variable<String>(cvName);
    return map;
  }

  TVoiceCVCompanion toCompanion(bool nullToAbsent) {
    return TVoiceCVCompanion(
      voiceWorkPath: Value(voiceWorkPath),
      cvName: Value(cvName),
    );
  }

  factory TVoiceCVData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TVoiceCVData(
      voiceWorkPath: serializer.fromJson<String>(json['voiceWorkPath']),
      cvName: serializer.fromJson<String>(json['cvName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'voiceWorkPath': serializer.toJson<String>(voiceWorkPath),
      'cvName': serializer.toJson<String>(cvName),
    };
  }

  TVoiceCVData copyWith({String? voiceWorkPath, String? cvName}) =>
      TVoiceCVData(
        voiceWorkPath: voiceWorkPath ?? this.voiceWorkPath,
        cvName: cvName ?? this.cvName,
      );
  TVoiceCVData copyWithCompanion(TVoiceCVCompanion data) {
    return TVoiceCVData(
      voiceWorkPath: data.voiceWorkPath.present
          ? data.voiceWorkPath.value
          : this.voiceWorkPath,
      cvName: data.cvName.present ? data.cvName.value : this.cvName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TVoiceCVData(')
          ..write('voiceWorkPath: $voiceWorkPath, ')
          ..write('cvName: $cvName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(voiceWorkPath, cvName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TVoiceCVData &&
          other.voiceWorkPath == this.voiceWorkPath &&
          other.cvName == this.cvName);
}

class TVoiceCVCompanion extends UpdateCompanion<TVoiceCVData> {
  final Value<String> voiceWorkPath;
  final Value<String> cvName;
  final Value<int> rowid;
  const TVoiceCVCompanion({
    this.voiceWorkPath = const Value.absent(),
    this.cvName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TVoiceCVCompanion.insert({
    required String voiceWorkPath,
    required String cvName,
    this.rowid = const Value.absent(),
  })  : voiceWorkPath = Value(voiceWorkPath),
        cvName = Value(cvName);
  static Insertable<TVoiceCVData> custom({
    Expression<String>? voiceWorkPath,
    Expression<String>? cvName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (voiceWorkPath != null) 'voice_work_path': voiceWorkPath,
      if (cvName != null) 'cv_name': cvName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TVoiceCVCompanion copyWith(
      {Value<String>? voiceWorkPath,
      Value<String>? cvName,
      Value<int>? rowid}) {
    return TVoiceCVCompanion(
      voiceWorkPath: voiceWorkPath ?? this.voiceWorkPath,
      cvName: cvName ?? this.cvName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (voiceWorkPath.present) {
      map['voice_work_path'] = Variable<String>(voiceWorkPath.value);
    }
    if (cvName.present) {
      map['cv_name'] = Variable<String>(cvName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TVoiceCVCompanion(')
          ..write('voiceWorkPath: $voiceWorkPath, ')
          ..write('cvName: $cvName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TVoiceWorkCategoryTable tVoiceWorkCategory =
      $TVoiceWorkCategoryTable(this);
  late final $TVoiceWorkTable tVoiceWork = $TVoiceWorkTable(this);
  late final $TVoiceItemTable tVoiceItem = $TVoiceItemTable(this);
  late final $TCVTable tcv = $TCVTable(this);
  late final $TVoiceCVTable tVoiceCV = $TVoiceCVTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [tVoiceWorkCategory, tVoiceWork, tVoiceItem, tcv, tVoiceCV];
}

typedef $$TVoiceWorkCategoryTableCreateCompanionBuilder
    = TVoiceWorkCategoryCompanion Function({
  required String description,
  Value<int> rowid,
});
typedef $$TVoiceWorkCategoryTableUpdateCompanionBuilder
    = TVoiceWorkCategoryCompanion Function({
  Value<String> description,
  Value<int> rowid,
});

final class $$TVoiceWorkCategoryTableReferences extends BaseReferences<
    _$AppDatabase, $TVoiceWorkCategoryTable, TVoiceWorkCategoryData> {
  $$TVoiceWorkCategoryTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TVoiceWorkTable, List<TVoiceWorkData>>
      _tVoiceWorkRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tVoiceWork,
              aliasName: $_aliasNameGenerator(
                  db.tVoiceWorkCategory.description, db.tVoiceWork.category));

  $$TVoiceWorkTableProcessedTableManager get tVoiceWorkRefs {
    final manager = $$TVoiceWorkTableTableManager($_db, $_db.tVoiceWork)
        .filter((f) => f.category.description($_item.description));

    final cache = $_typedResult.readTableOrNull(_tVoiceWorkRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
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

class $$TVoiceWorkCategoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceWorkCategoryTable,
    TVoiceWorkCategoryData,
    $$TVoiceWorkCategoryTableFilterComposer,
    $$TVoiceWorkCategoryTableOrderingComposer,
    $$TVoiceWorkCategoryTableCreateCompanionBuilder,
    $$TVoiceWorkCategoryTableUpdateCompanionBuilder,
    (TVoiceWorkCategoryData, $$TVoiceWorkCategoryTableReferences),
    TVoiceWorkCategoryData,
    PrefetchHooks Function({bool tVoiceWorkRefs})> {
  $$TVoiceWorkCategoryTableTableManager(
      _$AppDatabase db, $TVoiceWorkCategoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TVoiceWorkCategoryTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$TVoiceWorkCategoryTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> description = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceWorkCategoryCompanion(
            description: description,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String description,
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceWorkCategoryCompanion.insert(
            description: description,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TVoiceWorkCategoryTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({tVoiceWorkRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tVoiceWorkRefs) db.tVoiceWork],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tVoiceWorkRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TVoiceWorkCategoryTableReferences
                            ._tVoiceWorkRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TVoiceWorkCategoryTableReferences(db, table, p0)
                                .tVoiceWorkRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.category == item.description),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TVoiceWorkCategoryTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TVoiceWorkCategoryTable,
    TVoiceWorkCategoryData,
    $$TVoiceWorkCategoryTableFilterComposer,
    $$TVoiceWorkCategoryTableOrderingComposer,
    $$TVoiceWorkCategoryTableCreateCompanionBuilder,
    $$TVoiceWorkCategoryTableUpdateCompanionBuilder,
    (TVoiceWorkCategoryData, $$TVoiceWorkCategoryTableReferences),
    TVoiceWorkCategoryData,
    PrefetchHooks Function({bool tVoiceWorkRefs})>;
typedef $$TVoiceWorkTableCreateCompanionBuilder = TVoiceWorkCompanion Function({
  required String title,
  required String directoryPath,
  required String coverPath,
  required String category,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$TVoiceWorkTableUpdateCompanionBuilder = TVoiceWorkCompanion Function({
  Value<String> title,
  Value<String> directoryPath,
  Value<String> coverPath,
  Value<String> category,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

final class $$TVoiceWorkTableReferences
    extends BaseReferences<_$AppDatabase, $TVoiceWorkTable, TVoiceWorkData> {
  $$TVoiceWorkTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TVoiceWorkCategoryTable _categoryTable(_$AppDatabase db) =>
      db.tVoiceWorkCategory.createAlias($_aliasNameGenerator(
          db.tVoiceWork.category, db.tVoiceWorkCategory.description));

  $$TVoiceWorkCategoryTableProcessedTableManager? get category {
    if ($_item.category == null) return null;
    final manager =
        $$TVoiceWorkCategoryTableTableManager($_db, $_db.tVoiceWorkCategory)
            .filter((f) => f.description($_item.category));
    final item = $_typedResult.readTableOrNull(_categoryTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TVoiceItemTable, List<TVoiceItemData>>
      _tVoiceItemRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tVoiceItem,
              aliasName: $_aliasNameGenerator(
                  db.tVoiceWork.title, db.tVoiceItem.voiceWorkTitle));

  $$TVoiceItemTableProcessedTableManager get tVoiceItemRefs {
    final manager = $$TVoiceItemTableTableManager($_db, $_db.tVoiceItem)
        .filter((f) => f.voiceWorkTitle.title($_item.title));

    final cache = $_typedResult.readTableOrNull(_tVoiceItemRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TVoiceCVTable, List<TVoiceCVData>>
      _tVoiceCVRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.tVoiceCV,
          aliasName:
              $_aliasNameGenerator(db.tVoiceWork.title, db.tVoiceCV.vkTitle));

  $$TVoiceCVTableProcessedTableManager get tVoiceCVRefs {
    final manager = $$TVoiceCVTableTableManager($_db, $_db.tVoiceCV)
        .filter((f) => f.vkTitle.title($_item.title));

    final cache = $_typedResult.readTableOrNull(_tVoiceCVRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TVoiceWorkTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TVoiceWorkTable> {
  $$TVoiceWorkTableFilterComposer(super.$state);
  ColumnFilters<String> get title => $state.composableBuilder(
      column: $state.table.title,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get directoryPath => $state.composableBuilder(
      column: $state.table.directoryPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get coverPath => $state.composableBuilder(
      column: $state.table.coverPath,
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
        getCurrentColumn: (t) => t.directoryPath,
        referencedTable: $state.db.tVoiceItem,
        getReferencedColumn: (t) => t.voiceWorkPath,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceItemTableFilterComposer(ComposerState($state.db,
                $state.db.tVoiceItem, joinBuilder, parentComposers)));
    return f(composer);
  }

  ComposableFilter tVoiceCVRefs(
      ComposableFilter Function($$TVoiceCVTableFilterComposer f) f) {
    final $$TVoiceCVTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.directoryPath,
        referencedTable: $state.db.tVoiceCV,
        getReferencedColumn: (t) => t.voiceWorkPath,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceCVTableFilterComposer(ComposerState(
                $state.db, $state.db.tVoiceCV, joinBuilder, parentComposers)));
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

  ColumnOrderings<String> get directoryPath => $state.composableBuilder(
      column: $state.table.directoryPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get coverPath => $state.composableBuilder(
      column: $state.table.coverPath,
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

class $$TVoiceWorkTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceWorkTable,
    TVoiceWorkData,
    $$TVoiceWorkTableFilterComposer,
    $$TVoiceWorkTableOrderingComposer,
    $$TVoiceWorkTableCreateCompanionBuilder,
    $$TVoiceWorkTableUpdateCompanionBuilder,
    (TVoiceWorkData, $$TVoiceWorkTableReferences),
    TVoiceWorkData,
    PrefetchHooks Function(
        {bool category, bool tVoiceItemRefs, bool tVoiceCVRefs})> {
  $$TVoiceWorkTableTableManager(_$AppDatabase db, $TVoiceWorkTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TVoiceWorkTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TVoiceWorkTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> title = const Value.absent(),
            Value<String> diretoryPath = const Value.absent(),
            Value<String> coverPath = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceWorkCompanion(
            title: title,
            diretoryPath: diretoryPath,
            coverPath: coverPath,
            category: category,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String title,
            required String diretoryPath,
            required String coverPath,
            required String category,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceWorkCompanion.insert(
            title: title,
            diretoryPath: diretoryPath,
            coverPath: coverPath,
            category: category,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TVoiceWorkTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {category = false,
              tVoiceItemRefs = false,
              tVoiceCVRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tVoiceItemRefs) db.tVoiceItem,
                if (tVoiceCVRefs) db.tVoiceCV
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (category) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.category,
                    referencedTable:
                        $$TVoiceWorkTableReferences._categoryTable(db),
                    referencedColumn: $$TVoiceWorkTableReferences
                        ._categoryTable(db)
                        .description,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tVoiceItemRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$TVoiceWorkTableReferences
                            ._tVoiceItemRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TVoiceWorkTableReferences(db, table, p0)
                                .tVoiceItemRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.voiceWorkTitle == item.title),
                        typedResults: items),
                  if (tVoiceCVRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TVoiceWorkTableReferences._tVoiceCVRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TVoiceWorkTableReferences(db, table, p0)
                                .tVoiceCVRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.vkTitle == item.title),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TVoiceWorkTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TVoiceWorkTable,
    TVoiceWorkData,
    $$TVoiceWorkTableFilterComposer,
    $$TVoiceWorkTableOrderingComposer,
    $$TVoiceWorkTableCreateCompanionBuilder,
    $$TVoiceWorkTableUpdateCompanionBuilder,
    (TVoiceWorkData, $$TVoiceWorkTableReferences),
    TVoiceWorkData,
    PrefetchHooks Function(
        {bool category, bool tVoiceItemRefs, bool tVoiceCVRefs})>;
typedef $$TVoiceItemTableCreateCompanionBuilder = TVoiceItemCompanion Function({
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

final class $$TVoiceItemTableReferences
    extends BaseReferences<_$AppDatabase, $TVoiceItemTable, TVoiceItemData> {
  $$TVoiceItemTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TVoiceWorkTable _voiceWorkTitleTable(_$AppDatabase db) =>
      db.tVoiceWork.createAlias($_aliasNameGenerator(
          db.tVoiceItem.voiceWorkTitle, db.tVoiceWork.title));

  $$TVoiceWorkTableProcessedTableManager? get voiceWorkTitle {
    if ($_item.voiceWorkTitle == null) return null;
    final manager = $$TVoiceWorkTableTableManager($_db, $_db.tVoiceWork)
        .filter((f) => f.title($_item.voiceWorkTitle));
    final item = $_typedResult.readTableOrNull(_voiceWorkTitleTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
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

  $$TVoiceWorkTableFilterComposer get voiceWorkPath {
    final $$TVoiceWorkTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $state.db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
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

  $$TVoiceWorkTableOrderingComposer get voiceWorkPath {
    final $$TVoiceWorkTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $state.db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceWorkTableOrderingComposer(ComposerState($state.db,
                $state.db.tVoiceWork, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TVoiceItemTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceItemTable,
    TVoiceItemData,
    $$TVoiceItemTableFilterComposer,
    $$TVoiceItemTableOrderingComposer,
    $$TVoiceItemTableCreateCompanionBuilder,
    $$TVoiceItemTableUpdateCompanionBuilder,
    (TVoiceItemData, $$TVoiceItemTableReferences),
    TVoiceItemData,
    PrefetchHooks Function({bool voiceWorkTitle})> {
  $$TVoiceItemTableTableManager(_$AppDatabase db, $TVoiceItemTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TVoiceItemTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TVoiceItemTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
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
          createCompanionCallback: ({
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
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TVoiceItemTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({voiceWorkTitle = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (voiceWorkTitle) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.voiceWorkTitle,
                    referencedTable:
                        $$TVoiceItemTableReferences._voiceWorkTitleTable(db),
                    referencedColumn: $$TVoiceItemTableReferences
                        ._voiceWorkTitleTable(db)
                        .title,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TVoiceItemTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TVoiceItemTable,
    TVoiceItemData,
    $$TVoiceItemTableFilterComposer,
    $$TVoiceItemTableOrderingComposer,
    $$TVoiceItemTableCreateCompanionBuilder,
    $$TVoiceItemTableUpdateCompanionBuilder,
    (TVoiceItemData, $$TVoiceItemTableReferences),
    TVoiceItemData,
    PrefetchHooks Function({bool voiceWorkTitle})>;
typedef $$TCVTableCreateCompanionBuilder = TCVCompanion Function({
  required String cvName,
  Value<int> rowid,
});
typedef $$TCVTableUpdateCompanionBuilder = TCVCompanion Function({
  Value<String> cvName,
  Value<int> rowid,
});

final class $$TCVTableReferences
    extends BaseReferences<_$AppDatabase, $TCVTable, TCVData> {
  $$TCVTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TVoiceCVTable, List<TVoiceCVData>>
      _tVoiceCVRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.tVoiceCV,
          aliasName: $_aliasNameGenerator(db.tcv.cvName, db.tVoiceCV.cvName));

  $$TVoiceCVTableProcessedTableManager get tVoiceCVRefs {
    final manager = $$TVoiceCVTableTableManager($_db, $_db.tVoiceCV)
        .filter((f) => f.cvName.cvName($_item.cvName));

    final cache = $_typedResult.readTableOrNull(_tVoiceCVRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TCVTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TCVTable> {
  $$TCVTableFilterComposer(super.$state);
  ColumnFilters<String> get cvName => $state.composableBuilder(
      column: $state.table.cvName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter tVoiceCVRefs(
      ComposableFilter Function($$TVoiceCVTableFilterComposer f) f) {
    final $$TVoiceCVTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cvName,
        referencedTable: $state.db.tVoiceCV,
        getReferencedColumn: (t) => t.cvName,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceCVTableFilterComposer(ComposerState(
                $state.db, $state.db.tVoiceCV, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$TCVTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TCVTable> {
  $$TCVTableOrderingComposer(super.$state);
  ColumnOrderings<String> get cvName => $state.composableBuilder(
      column: $state.table.cvName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$TCVTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TCVTable,
    TCVData,
    $$TCVTableFilterComposer,
    $$TCVTableOrderingComposer,
    $$TCVTableCreateCompanionBuilder,
    $$TCVTableUpdateCompanionBuilder,
    (TCVData, $$TCVTableReferences),
    TCVData,
    PrefetchHooks Function({bool tVoiceCVRefs})> {
  $$TCVTableTableManager(_$AppDatabase db, $TCVTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$TCVTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TCVTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> cvName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TCVCompanion(
            cvName: cvName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cvName,
            Value<int> rowid = const Value.absent(),
          }) =>
              TCVCompanion.insert(
            cvName: cvName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TCVTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tVoiceCVRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tVoiceCVRefs) db.tVoiceCV],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tVoiceCVRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TCVTableReferences._tVoiceCVRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TCVTableReferences(db, table, p0).tVoiceCVRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.cvName == item.cvName),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TCVTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TCVTable,
    TCVData,
    $$TCVTableFilterComposer,
    $$TCVTableOrderingComposer,
    $$TCVTableCreateCompanionBuilder,
    $$TCVTableUpdateCompanionBuilder,
    (TCVData, $$TCVTableReferences),
    TCVData,
    PrefetchHooks Function({bool tVoiceCVRefs})>;
typedef $$TVoiceCVTableCreateCompanionBuilder = TVoiceCVCompanion Function({
  required String vkTitle,
  required String cvName,
  Value<int> rowid,
});
typedef $$TVoiceCVTableUpdateCompanionBuilder = TVoiceCVCompanion Function({
  Value<String> vkTitle,
  Value<String> cvName,
  Value<int> rowid,
});

final class $$TVoiceCVTableReferences
    extends BaseReferences<_$AppDatabase, $TVoiceCVTable, TVoiceCVData> {
  $$TVoiceCVTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TVoiceWorkTable _vkTitleTable(_$AppDatabase db) =>
      db.tVoiceWork.createAlias(
          $_aliasNameGenerator(db.tVoiceCV.vkTitle, db.tVoiceWork.title));

  $$TVoiceWorkTableProcessedTableManager? get vkTitle {
    if ($_item.vkTitle == null) return null;
    final manager = $$TVoiceWorkTableTableManager($_db, $_db.tVoiceWork)
        .filter((f) => f.title($_item.vkTitle));
    final item = $_typedResult.readTableOrNull(_vkTitleTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TCVTable _cvNameTable(_$AppDatabase db) => db.tcv
      .createAlias($_aliasNameGenerator(db.tVoiceCV.cvName, db.tcv.cvName));

  $$TCVTableProcessedTableManager? get cvName {
    if ($_item.cvName == null) return null;
    final manager = $$TCVTableTableManager($_db, $_db.tcv)
        .filter((f) => f.cvName($_item.cvName));
    final item = $_typedResult.readTableOrNull(_cvNameTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TVoiceCVTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TVoiceCVTable> {
  $$TVoiceCVTableFilterComposer(super.$state);
  $$TVoiceWorkTableFilterComposer get voiceWorkPath {
    final $$TVoiceWorkTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $state.db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceWorkTableFilterComposer(ComposerState($state.db,
                $state.db.tVoiceWork, joinBuilder, parentComposers)));
    return composer;
  }

  $$TCVTableFilterComposer get cvName {
    final $$TCVTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cvName,
        referencedTable: $state.db.tcv,
        getReferencedColumn: (t) => t.cvName,
        builder: (joinBuilder, parentComposers) => $$TCVTableFilterComposer(
            ComposerState(
                $state.db, $state.db.tcv, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TVoiceCVTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TVoiceCVTable> {
  $$TVoiceCVTableOrderingComposer(super.$state);
  $$TVoiceWorkTableOrderingComposer get voiceWorkPath {
    final $$TVoiceWorkTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $state.db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
        builder: (joinBuilder, parentComposers) =>
            $$TVoiceWorkTableOrderingComposer(ComposerState($state.db,
                $state.db.tVoiceWork, joinBuilder, parentComposers)));
    return composer;
  }

  $$TCVTableOrderingComposer get cvName {
    final $$TCVTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cvName,
        referencedTable: $state.db.tcv,
        getReferencedColumn: (t) => t.cvName,
        builder: (joinBuilder, parentComposers) => $$TCVTableOrderingComposer(
            ComposerState(
                $state.db, $state.db.tcv, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TVoiceCVTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceCVTable,
    TVoiceCVData,
    $$TVoiceCVTableFilterComposer,
    $$TVoiceCVTableOrderingComposer,
    $$TVoiceCVTableCreateCompanionBuilder,
    $$TVoiceCVTableUpdateCompanionBuilder,
    (TVoiceCVData, $$TVoiceCVTableReferences),
    TVoiceCVData,
    PrefetchHooks Function({bool vkTitle, bool cvName})> {
  $$TVoiceCVTableTableManager(_$AppDatabase db, $TVoiceCVTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TVoiceCVTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TVoiceCVTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> vkTitle = const Value.absent(),
            Value<String> cvName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceCVCompanion(
            vkTitle: vkTitle,
            cvName: cvName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String vkTitle,
            required String cvName,
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceCVCompanion.insert(
            vkTitle: vkTitle,
            cvName: cvName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TVoiceCVTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({vkTitle = false, cvName = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (vkTitle) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.vkTitle,
                    referencedTable:
                        $$TVoiceCVTableReferences._vkTitleTable(db),
                    referencedColumn:
                        $$TVoiceCVTableReferences._vkTitleTable(db).title,
                  ) as T;
                }
                if (cvName) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cvName,
                    referencedTable: $$TVoiceCVTableReferences._cvNameTable(db),
                    referencedColumn:
                        $$TVoiceCVTableReferences._cvNameTable(db).cvName,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TVoiceCVTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TVoiceCVTable,
    TVoiceCVData,
    $$TVoiceCVTableFilterComposer,
    $$TVoiceCVTableOrderingComposer,
    $$TVoiceCVTableCreateCompanionBuilder,
    $$TVoiceCVTableUpdateCompanionBuilder,
    (TVoiceCVData, $$TVoiceCVTableReferences),
    TVoiceCVData,
    PrefetchHooks Function({bool vkTitle, bool cvName})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TVoiceWorkCategoryTableTableManager get tVoiceWorkCategory =>
      $$TVoiceWorkCategoryTableTableManager(_db, _db.tVoiceWorkCategory);
  $$TVoiceWorkTableTableManager get tVoiceWork =>
      $$TVoiceWorkTableTableManager(_db, _db.tVoiceWork);
  $$TVoiceItemTableTableManager get tVoiceItem =>
      $$TVoiceItemTableTableManager(_db, _db.tVoiceItem);
  $$TCVTableTableManager get tcv => $$TCVTableTableManager(_db, _db.tcv);
  $$TVoiceCVTableTableManager get tVoiceCV =>
      $$TVoiceCVTableTableManager(_db, _db.tVoiceCV);
}
