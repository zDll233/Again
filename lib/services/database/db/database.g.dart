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
  static const VerificationMeta _rjMeta = const VerificationMeta('rj');
  @override
  late final GeneratedColumn<String> rj = GeneratedColumn<String>(
      'rj', aliasedName, false,
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
      [title, rj, directoryPath, coverPath, category, createdAt];
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
    if (data.containsKey('rj')) {
      context.handle(_rjMeta, rj.isAcceptableOrUnknown(data['rj']!, _rjMeta));
    } else if (isInserting) {
      context.missing(_rjMeta);
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
      rj: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rj'])!,
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
  final String rj;
  final String directoryPath;
  final String coverPath;
  final String category;
  final DateTime? createdAt;
  const TVoiceWorkData(
      {required this.title,
      required this.rj,
      required this.directoryPath,
      required this.coverPath,
      required this.category,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['rj'] = Variable<String>(rj);
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
      rj: Value(rj),
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
      rj: serializer.fromJson<String>(json['rj']),
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
      'rj': serializer.toJson<String>(rj),
      'directoryPath': serializer.toJson<String>(directoryPath),
      'coverPath': serializer.toJson<String>(coverPath),
      'category': serializer.toJson<String>(category),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  TVoiceWorkData copyWith(
          {String? title,
          String? rj,
          String? directoryPath,
          String? coverPath,
          String? category,
          Value<DateTime?> createdAt = const Value.absent()}) =>
      TVoiceWorkData(
        title: title ?? this.title,
        rj: rj ?? this.rj,
        directoryPath: directoryPath ?? this.directoryPath,
        coverPath: coverPath ?? this.coverPath,
        category: category ?? this.category,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  TVoiceWorkData copyWithCompanion(TVoiceWorkCompanion data) {
    return TVoiceWorkData(
      title: data.title.present ? data.title.value : this.title,
      rj: data.rj.present ? data.rj.value : this.rj,
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
          ..write('rj: $rj, ')
          ..write('directoryPath: $directoryPath, ')
          ..write('coverPath: $coverPath, ')
          ..write('category: $category, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(title, rj, directoryPath, coverPath, category, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TVoiceWorkData &&
          other.title == this.title &&
          other.rj == this.rj &&
          other.directoryPath == this.directoryPath &&
          other.coverPath == this.coverPath &&
          other.category == this.category &&
          other.createdAt == this.createdAt);
}

class TVoiceWorkCompanion extends UpdateCompanion<TVoiceWorkData> {
  final Value<String> title;
  final Value<String> rj;
  final Value<String> directoryPath;
  final Value<String> coverPath;
  final Value<String> category;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const TVoiceWorkCompanion({
    this.title = const Value.absent(),
    this.rj = const Value.absent(),
    this.directoryPath = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.category = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TVoiceWorkCompanion.insert({
    required String title,
    required String rj,
    required String directoryPath,
    required String coverPath,
    required String category,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : title = Value(title),
        rj = Value(rj),
        directoryPath = Value(directoryPath),
        coverPath = Value(coverPath),
        category = Value(category);
  static Insertable<TVoiceWorkData> custom({
    Expression<String>? title,
    Expression<String>? rj,
    Expression<String>? directoryPath,
    Expression<String>? coverPath,
    Expression<String>? category,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (rj != null) 'rj': rj,
      if (directoryPath != null) 'directory_path': directoryPath,
      if (coverPath != null) 'cover_path': coverPath,
      if (category != null) 'category': category,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TVoiceWorkCompanion copyWith(
      {Value<String>? title,
      Value<String>? rj,
      Value<String>? directoryPath,
      Value<String>? coverPath,
      Value<String>? category,
      Value<DateTime?>? createdAt,
      Value<int>? rowid}) {
    return TVoiceWorkCompanion(
      title: title ?? this.title,
      rj: rj ?? this.rj,
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
    if (rj.present) {
      map['rj'] = Variable<String>(rj.value);
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
          ..write('rj: $rj, ')
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
    extends Composer<_$AppDatabase, $TVoiceWorkCategoryTable> {
  $$TVoiceWorkCategoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  Expression<bool> tVoiceWorkRefs(
      Expression<bool> Function($$TVoiceWorkTableFilterComposer f) f) {
    final $$TVoiceWorkTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.description,
        referencedTable: $db.tVoiceWork,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkTableFilterComposer(
              $db: $db,
              $table: $db.tVoiceWork,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TVoiceWorkCategoryTableOrderingComposer
    extends Composer<_$AppDatabase, $TVoiceWorkCategoryTable> {
  $$TVoiceWorkCategoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$TVoiceWorkCategoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $TVoiceWorkCategoryTable> {
  $$TVoiceWorkCategoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  Expression<T> tVoiceWorkRefs<T extends Object>(
      Expression<T> Function($$TVoiceWorkTableAnnotationComposer a) f) {
    final $$TVoiceWorkTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.description,
        referencedTable: $db.tVoiceWork,
        getReferencedColumn: (t) => t.category,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkTableAnnotationComposer(
              $db: $db,
              $table: $db.tVoiceWork,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TVoiceWorkCategoryTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceWorkCategoryTable,
    TVoiceWorkCategoryData,
    $$TVoiceWorkCategoryTableFilterComposer,
    $$TVoiceWorkCategoryTableOrderingComposer,
    $$TVoiceWorkCategoryTableAnnotationComposer,
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
          createFilteringComposer: () =>
              $$TVoiceWorkCategoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TVoiceWorkCategoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TVoiceWorkCategoryTableAnnotationComposer(
                  $db: db, $table: table),
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
    $$TVoiceWorkCategoryTableAnnotationComposer,
    $$TVoiceWorkCategoryTableCreateCompanionBuilder,
    $$TVoiceWorkCategoryTableUpdateCompanionBuilder,
    (TVoiceWorkCategoryData, $$TVoiceWorkCategoryTableReferences),
    TVoiceWorkCategoryData,
    PrefetchHooks Function({bool tVoiceWorkRefs})>;
typedef $$TVoiceWorkTableCreateCompanionBuilder = TVoiceWorkCompanion Function({
  required String title,
  required String rj,
  required String directoryPath,
  required String coverPath,
  required String category,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$TVoiceWorkTableUpdateCompanionBuilder = TVoiceWorkCompanion Function({
  Value<String> title,
  Value<String> rj,
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
                  db.tVoiceWork.directoryPath, db.tVoiceItem.voiceWorkPath));

  $$TVoiceItemTableProcessedTableManager get tVoiceItemRefs {
    final manager = $$TVoiceItemTableTableManager($_db, $_db.tVoiceItem)
        .filter((f) => f.voiceWorkPath.directoryPath($_item.directoryPath));

    final cache = $_typedResult.readTableOrNull(_tVoiceItemRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TVoiceCVTable, List<TVoiceCVData>>
      _tVoiceCVRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.tVoiceCV,
              aliasName: $_aliasNameGenerator(
                  db.tVoiceWork.directoryPath, db.tVoiceCV.voiceWorkPath));

  $$TVoiceCVTableProcessedTableManager get tVoiceCVRefs {
    final manager = $$TVoiceCVTableTableManager($_db, $_db.tVoiceCV)
        .filter((f) => f.voiceWorkPath.directoryPath($_item.directoryPath));

    final cache = $_typedResult.readTableOrNull(_tVoiceCVRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TVoiceWorkTableFilterComposer
    extends Composer<_$AppDatabase, $TVoiceWorkTable> {
  $$TVoiceWorkTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rj => $composableBuilder(
      column: $table.rj, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get directoryPath => $composableBuilder(
      column: $table.directoryPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TVoiceWorkCategoryTableFilterComposer get category {
    final $$TVoiceWorkCategoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.tVoiceWorkCategory,
        getReferencedColumn: (t) => t.description,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkCategoryTableFilterComposer(
              $db: $db,
              $table: $db.tVoiceWorkCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> tVoiceItemRefs(
      Expression<bool> Function($$TVoiceItemTableFilterComposer f) f) {
    final $$TVoiceItemTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.directoryPath,
        referencedTable: $db.tVoiceItem,
        getReferencedColumn: (t) => t.voiceWorkPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceItemTableFilterComposer(
              $db: $db,
              $table: $db.tVoiceItem,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> tVoiceCVRefs(
      Expression<bool> Function($$TVoiceCVTableFilterComposer f) f) {
    final $$TVoiceCVTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.directoryPath,
        referencedTable: $db.tVoiceCV,
        getReferencedColumn: (t) => t.voiceWorkPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceCVTableFilterComposer(
              $db: $db,
              $table: $db.tVoiceCV,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TVoiceWorkTableOrderingComposer
    extends Composer<_$AppDatabase, $TVoiceWorkTable> {
  $$TVoiceWorkTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rj => $composableBuilder(
      column: $table.rj, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get directoryPath => $composableBuilder(
      column: $table.directoryPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TVoiceWorkCategoryTableOrderingComposer get category {
    final $$TVoiceWorkCategoryTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.category,
        referencedTable: $db.tVoiceWorkCategory,
        getReferencedColumn: (t) => t.description,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkCategoryTableOrderingComposer(
              $db: $db,
              $table: $db.tVoiceWorkCategory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TVoiceWorkTableAnnotationComposer
    extends Composer<_$AppDatabase, $TVoiceWorkTable> {
  $$TVoiceWorkTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get rj =>
      $composableBuilder(column: $table.rj, builder: (column) => column);

  GeneratedColumn<String> get directoryPath => $composableBuilder(
      column: $table.directoryPath, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TVoiceWorkCategoryTableAnnotationComposer get category {
    final $$TVoiceWorkCategoryTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.category,
            referencedTable: $db.tVoiceWorkCategory,
            getReferencedColumn: (t) => t.description,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TVoiceWorkCategoryTableAnnotationComposer(
                  $db: $db,
                  $table: $db.tVoiceWorkCategory,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  Expression<T> tVoiceItemRefs<T extends Object>(
      Expression<T> Function($$TVoiceItemTableAnnotationComposer a) f) {
    final $$TVoiceItemTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.directoryPath,
        referencedTable: $db.tVoiceItem,
        getReferencedColumn: (t) => t.voiceWorkPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceItemTableAnnotationComposer(
              $db: $db,
              $table: $db.tVoiceItem,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> tVoiceCVRefs<T extends Object>(
      Expression<T> Function($$TVoiceCVTableAnnotationComposer a) f) {
    final $$TVoiceCVTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.directoryPath,
        referencedTable: $db.tVoiceCV,
        getReferencedColumn: (t) => t.voiceWorkPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceCVTableAnnotationComposer(
              $db: $db,
              $table: $db.tVoiceCV,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TVoiceWorkTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceWorkTable,
    TVoiceWorkData,
    $$TVoiceWorkTableFilterComposer,
    $$TVoiceWorkTableOrderingComposer,
    $$TVoiceWorkTableAnnotationComposer,
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
          createFilteringComposer: () =>
              $$TVoiceWorkTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TVoiceWorkTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TVoiceWorkTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> title = const Value.absent(),
            Value<String> rj = const Value.absent(),
            Value<String> directoryPath = const Value.absent(),
            Value<String> coverPath = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceWorkCompanion(
            title: title,
            rj: rj,
            directoryPath: directoryPath,
            coverPath: coverPath,
            category: category,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String title,
            required String rj,
            required String directoryPath,
            required String coverPath,
            required String category,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceWorkCompanion.insert(
            title: title,
            rj: rj,
            directoryPath: directoryPath,
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
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.voiceWorkPath == item.directoryPath),
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
                            (item, referencedItems) => referencedItems.where(
                                (e) => e.voiceWorkPath == item.directoryPath),
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
    $$TVoiceWorkTableAnnotationComposer,
    $$TVoiceWorkTableCreateCompanionBuilder,
    $$TVoiceWorkTableUpdateCompanionBuilder,
    (TVoiceWorkData, $$TVoiceWorkTableReferences),
    TVoiceWorkData,
    PrefetchHooks Function(
        {bool category, bool tVoiceItemRefs, bool tVoiceCVRefs})>;
typedef $$TVoiceItemTableCreateCompanionBuilder = TVoiceItemCompanion Function({
  required String title,
  required String filePath,
  required String voiceWorkPath,
  Value<int> rowid,
});
typedef $$TVoiceItemTableUpdateCompanionBuilder = TVoiceItemCompanion Function({
  Value<String> title,
  Value<String> filePath,
  Value<String> voiceWorkPath,
  Value<int> rowid,
});

final class $$TVoiceItemTableReferences
    extends BaseReferences<_$AppDatabase, $TVoiceItemTable, TVoiceItemData> {
  $$TVoiceItemTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TVoiceWorkTable _voiceWorkPathTable(_$AppDatabase db) =>
      db.tVoiceWork.createAlias($_aliasNameGenerator(
          db.tVoiceItem.voiceWorkPath, db.tVoiceWork.directoryPath));

  $$TVoiceWorkTableProcessedTableManager? get voiceWorkPath {
    final manager = $$TVoiceWorkTableTableManager($_db, $_db.tVoiceWork)
        .filter((f) => f.directoryPath($_item.voiceWorkPath));
    final item = $_typedResult.readTableOrNull(_voiceWorkPathTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TVoiceItemTableFilterComposer
    extends Composer<_$AppDatabase, $TVoiceItemTable> {
  $$TVoiceItemTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  $$TVoiceWorkTableFilterComposer get voiceWorkPath {
    final $$TVoiceWorkTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkTableFilterComposer(
              $db: $db,
              $table: $db.tVoiceWork,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TVoiceItemTableOrderingComposer
    extends Composer<_$AppDatabase, $TVoiceItemTable> {
  $$TVoiceItemTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  $$TVoiceWorkTableOrderingComposer get voiceWorkPath {
    final $$TVoiceWorkTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkTableOrderingComposer(
              $db: $db,
              $table: $db.tVoiceWork,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TVoiceItemTableAnnotationComposer
    extends Composer<_$AppDatabase, $TVoiceItemTable> {
  $$TVoiceItemTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  $$TVoiceWorkTableAnnotationComposer get voiceWorkPath {
    final $$TVoiceWorkTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkTableAnnotationComposer(
              $db: $db,
              $table: $db.tVoiceWork,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TVoiceItemTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceItemTable,
    TVoiceItemData,
    $$TVoiceItemTableFilterComposer,
    $$TVoiceItemTableOrderingComposer,
    $$TVoiceItemTableAnnotationComposer,
    $$TVoiceItemTableCreateCompanionBuilder,
    $$TVoiceItemTableUpdateCompanionBuilder,
    (TVoiceItemData, $$TVoiceItemTableReferences),
    TVoiceItemData,
    PrefetchHooks Function({bool voiceWorkPath})> {
  $$TVoiceItemTableTableManager(_$AppDatabase db, $TVoiceItemTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TVoiceItemTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TVoiceItemTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TVoiceItemTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> title = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<String> voiceWorkPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceItemCompanion(
            title: title,
            filePath: filePath,
            voiceWorkPath: voiceWorkPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String title,
            required String filePath,
            required String voiceWorkPath,
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceItemCompanion.insert(
            title: title,
            filePath: filePath,
            voiceWorkPath: voiceWorkPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TVoiceItemTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({voiceWorkPath = false}) {
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
                      dynamic,
                      dynamic>>(state) {
                if (voiceWorkPath) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.voiceWorkPath,
                    referencedTable:
                        $$TVoiceItemTableReferences._voiceWorkPathTable(db),
                    referencedColumn: $$TVoiceItemTableReferences
                        ._voiceWorkPathTable(db)
                        .directoryPath,
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
    $$TVoiceItemTableAnnotationComposer,
    $$TVoiceItemTableCreateCompanionBuilder,
    $$TVoiceItemTableUpdateCompanionBuilder,
    (TVoiceItemData, $$TVoiceItemTableReferences),
    TVoiceItemData,
    PrefetchHooks Function({bool voiceWorkPath})>;
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

class $$TCVTableFilterComposer extends Composer<_$AppDatabase, $TCVTable> {
  $$TCVTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cvName => $composableBuilder(
      column: $table.cvName, builder: (column) => ColumnFilters(column));

  Expression<bool> tVoiceCVRefs(
      Expression<bool> Function($$TVoiceCVTableFilterComposer f) f) {
    final $$TVoiceCVTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cvName,
        referencedTable: $db.tVoiceCV,
        getReferencedColumn: (t) => t.cvName,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceCVTableFilterComposer(
              $db: $db,
              $table: $db.tVoiceCV,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TCVTableOrderingComposer extends Composer<_$AppDatabase, $TCVTable> {
  $$TCVTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cvName => $composableBuilder(
      column: $table.cvName, builder: (column) => ColumnOrderings(column));
}

class $$TCVTableAnnotationComposer extends Composer<_$AppDatabase, $TCVTable> {
  $$TCVTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cvName =>
      $composableBuilder(column: $table.cvName, builder: (column) => column);

  Expression<T> tVoiceCVRefs<T extends Object>(
      Expression<T> Function($$TVoiceCVTableAnnotationComposer a) f) {
    final $$TVoiceCVTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cvName,
        referencedTable: $db.tVoiceCV,
        getReferencedColumn: (t) => t.cvName,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceCVTableAnnotationComposer(
              $db: $db,
              $table: $db.tVoiceCV,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TCVTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TCVTable,
    TCVData,
    $$TCVTableFilterComposer,
    $$TCVTableOrderingComposer,
    $$TCVTableAnnotationComposer,
    $$TCVTableCreateCompanionBuilder,
    $$TCVTableUpdateCompanionBuilder,
    (TCVData, $$TCVTableReferences),
    TCVData,
    PrefetchHooks Function({bool tVoiceCVRefs})> {
  $$TCVTableTableManager(_$AppDatabase db, $TCVTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TCVTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TCVTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TCVTableAnnotationComposer($db: db, $table: table),
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
    $$TCVTableAnnotationComposer,
    $$TCVTableCreateCompanionBuilder,
    $$TCVTableUpdateCompanionBuilder,
    (TCVData, $$TCVTableReferences),
    TCVData,
    PrefetchHooks Function({bool tVoiceCVRefs})>;
typedef $$TVoiceCVTableCreateCompanionBuilder = TVoiceCVCompanion Function({
  required String voiceWorkPath,
  required String cvName,
  Value<int> rowid,
});
typedef $$TVoiceCVTableUpdateCompanionBuilder = TVoiceCVCompanion Function({
  Value<String> voiceWorkPath,
  Value<String> cvName,
  Value<int> rowid,
});

final class $$TVoiceCVTableReferences
    extends BaseReferences<_$AppDatabase, $TVoiceCVTable, TVoiceCVData> {
  $$TVoiceCVTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TVoiceWorkTable _voiceWorkPathTable(_$AppDatabase db) =>
      db.tVoiceWork.createAlias($_aliasNameGenerator(
          db.tVoiceCV.voiceWorkPath, db.tVoiceWork.directoryPath));

  $$TVoiceWorkTableProcessedTableManager? get voiceWorkPath {
    final manager = $$TVoiceWorkTableTableManager($_db, $_db.tVoiceWork)
        .filter((f) => f.directoryPath($_item.voiceWorkPath));
    final item = $_typedResult.readTableOrNull(_voiceWorkPathTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TCVTable _cvNameTable(_$AppDatabase db) => db.tcv
      .createAlias($_aliasNameGenerator(db.tVoiceCV.cvName, db.tcv.cvName));

  $$TCVTableProcessedTableManager? get cvName {
    final manager = $$TCVTableTableManager($_db, $_db.tcv)
        .filter((f) => f.cvName($_item.cvName));
    final item = $_typedResult.readTableOrNull(_cvNameTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TVoiceCVTableFilterComposer
    extends Composer<_$AppDatabase, $TVoiceCVTable> {
  $$TVoiceCVTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TVoiceWorkTableFilterComposer get voiceWorkPath {
    final $$TVoiceWorkTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkTableFilterComposer(
              $db: $db,
              $table: $db.tVoiceWork,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TCVTableFilterComposer get cvName {
    final $$TCVTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cvName,
        referencedTable: $db.tcv,
        getReferencedColumn: (t) => t.cvName,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TCVTableFilterComposer(
              $db: $db,
              $table: $db.tcv,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TVoiceCVTableOrderingComposer
    extends Composer<_$AppDatabase, $TVoiceCVTable> {
  $$TVoiceCVTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TVoiceWorkTableOrderingComposer get voiceWorkPath {
    final $$TVoiceWorkTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkTableOrderingComposer(
              $db: $db,
              $table: $db.tVoiceWork,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TCVTableOrderingComposer get cvName {
    final $$TCVTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cvName,
        referencedTable: $db.tcv,
        getReferencedColumn: (t) => t.cvName,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TCVTableOrderingComposer(
              $db: $db,
              $table: $db.tcv,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TVoiceCVTableAnnotationComposer
    extends Composer<_$AppDatabase, $TVoiceCVTable> {
  $$TVoiceCVTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TVoiceWorkTableAnnotationComposer get voiceWorkPath {
    final $$TVoiceWorkTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.voiceWorkPath,
        referencedTable: $db.tVoiceWork,
        getReferencedColumn: (t) => t.directoryPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TVoiceWorkTableAnnotationComposer(
              $db: $db,
              $table: $db.tVoiceWork,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TCVTableAnnotationComposer get cvName {
    final $$TCVTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cvName,
        referencedTable: $db.tcv,
        getReferencedColumn: (t) => t.cvName,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TCVTableAnnotationComposer(
              $db: $db,
              $table: $db.tcv,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TVoiceCVTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TVoiceCVTable,
    TVoiceCVData,
    $$TVoiceCVTableFilterComposer,
    $$TVoiceCVTableOrderingComposer,
    $$TVoiceCVTableAnnotationComposer,
    $$TVoiceCVTableCreateCompanionBuilder,
    $$TVoiceCVTableUpdateCompanionBuilder,
    (TVoiceCVData, $$TVoiceCVTableReferences),
    TVoiceCVData,
    PrefetchHooks Function({bool voiceWorkPath, bool cvName})> {
  $$TVoiceCVTableTableManager(_$AppDatabase db, $TVoiceCVTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TVoiceCVTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TVoiceCVTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TVoiceCVTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> voiceWorkPath = const Value.absent(),
            Value<String> cvName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceCVCompanion(
            voiceWorkPath: voiceWorkPath,
            cvName: cvName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String voiceWorkPath,
            required String cvName,
            Value<int> rowid = const Value.absent(),
          }) =>
              TVoiceCVCompanion.insert(
            voiceWorkPath: voiceWorkPath,
            cvName: cvName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TVoiceCVTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({voiceWorkPath = false, cvName = false}) {
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
                      dynamic,
                      dynamic>>(state) {
                if (voiceWorkPath) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.voiceWorkPath,
                    referencedTable:
                        $$TVoiceCVTableReferences._voiceWorkPathTable(db),
                    referencedColumn: $$TVoiceCVTableReferences
                        ._voiceWorkPathTable(db)
                        .directoryPath,
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
    $$TVoiceCVTableAnnotationComposer,
    $$TVoiceCVTableCreateCompanionBuilder,
    $$TVoiceCVTableUpdateCompanionBuilder,
    (TVoiceCVData, $$TVoiceCVTableReferences),
    TVoiceCVData,
    PrefetchHooks Function({bool voiceWorkPath, bool cvName})>;

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
