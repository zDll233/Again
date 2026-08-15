import 'package:again/common/paths.dart';
import 'package:drift/drift.dart';

// These additional imports are necessary to open the sqlite3 database
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

class TVoiceItem extends Table {
  TextColumn get title => text()();
  TextColumn get filePath => text()();
  TextColumn get voiceWorkPath =>
      text().references(TVoiceWork, #directoryPath)();

  @override
  Set<Column> get primaryKey => {filePath};
}

class TVoiceWork extends Table {
  TextColumn get title => text()();
  TextColumn get sourceId => text()();
  TextColumn get directoryPath => text()();
  TextColumn get coverPath => text()();
  TextColumn get category =>
      text().references(TVoiceWorkCategory, #description)();
  DateTimeColumn get createdAt => dateTime().nullable()();
  // 历史遗留列: 曾用于增量扫描签名, Windows 目录 mtime 不可靠已弃用,
  // 变化检测改为扫描结果与 DB 条目集合对比。保留以兼容 schema v2。
  TextColumn get scanSignature => text().nullable()();

  @override
  Set<Column> get primaryKey => {directoryPath};
}

class TVoiceWorkCategory extends Table {
  TextColumn get description => text()();

  @override
  Set<Column> get primaryKey => {description};
}

class TCV extends Table {
  TextColumn get cvName => text()();

  @override
  Set<Column> get primaryKey => {cvName};
}

class TVoiceCV extends Table {
  TextColumn get voiceWorkPath =>
      text().references(TVoiceWork, #directoryPath)();
  TextColumn get cvName => text().references(TCV, #cvName)();

  @override
  Set<Column> get primaryKey => {voiceWorkPath, cvName};
}

@DriftDatabase(
    tables: [TVoiceItem, TVoiceWork, TVoiceWorkCategory, TCV, TVoiceCV])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? connection})
      : super(connection ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // Make sure that foreign keys are enabled
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(tVoiceWork, tVoiceWork.scanSignature);
        }
      },
    );
  }

  // insert
  Future<void> insertVoiceWorkBatch(List<TVoiceWorkCompanion> vwc) async {
    await batch((batch) {
      // functions in a batch don't have to be awaited - just
      // await the whole batch afterwards.
      batch.insertAll(tVoiceWork, vwc, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> insertVoiceItemBatch(List<TVoiceItemCompanion> vic) async {
    await batch((batch) {
      batch.insertAll(tVoiceItem, vic, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> insertVoiceWorkCategoryBatch(
      List<TVoiceWorkCategoryCompanion> vwcc) async {
    await batch((batch) {
      batch.insertAll(tVoiceWorkCategory, vwcc,
          mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> insertCvBatch(List<TCVCompanion> cvc) async {
    await batch((batch) {
      batch.insertAll(tcv, cvc, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> upsertVoiceWork(TVoiceWorkCompanion vwc) async {
    await into(tVoiceWork).insertOnConflictUpdate(vwc);
  }

  Future<void> deleteVoiceItemsOfWork(String vwPath) async {
    await (delete(tVoiceItem)
          ..where((t) => t.voiceWorkPath.equals(vwPath)))
        .go();
  }

  Future<void> deleteVoiceWorkCvsWithPath(String vwPath) async {
    await (delete(tVoiceCV)
          ..where((t) => t.voiceWorkPath.equals(vwPath)))
        .go();
  }

  Future<void> deleteVoiceWorkWithPath(String vwPath) async {
    await (delete(tVoiceWork)
          ..where((t) => t.directoryPath.equals(vwPath)))
        .go();
  }

  Future<void> deleteCategories(Iterable<String> descriptions) async {
    await (delete(tVoiceWorkCategory)
          ..where((t) => t.description.isIn(descriptions)))
        .go();
  }

  Future<void> deleteAllCvs() async {
    await delete(tVoiceCV).go();
    await delete(tcv).go();
  }

  Future<void> insertVoiceCvBatch(List<TVoiceCVCompanion> vcc) async {
    await batch((batch) {
      batch.insertAll(tVoiceCV, vcc, mode: InsertMode.insertOrIgnore);
    });
  }

  // select
  Future<List<TVoiceWorkData>> selectVoiceWorkData(String vwPath) =>
      (select(tVoiceWork)
            ..where((tVoiceWork) => (tVoiceWork.directoryPath.equals(vwPath))))
          .get();

  Future<List<TVoiceWorkData>> get selectAllVoiceWorks =>
      select(tVoiceWork).get();

  Future<List<TVoiceItemData>> get selectAllVoiceItems =>
      select(tVoiceItem).get();

  Future<List<TCVData>> selectAllCv() async => select(tcv).get();

  /// 按作品数倒序返回 CV 名列表; category 非空时限定该分类下的作品。
  Future<List<String>> selectCvsOrderedByCount(String? category) async {
    final query = select(tVoiceCV).join([
      innerJoin(
        tVoiceWork,
        tVoiceWork.directoryPath.equalsExp(tVoiceCV.voiceWorkPath),
      ),
    ]);
    if (category != null) {
      query.where(tVoiceWork.category.equals(category));
    }
    final rows = await query.get();

    final counts = <String, int>{};
    for (final row in rows) {
      final cv = row.readTable(tVoiceCV).cvName;
      counts[cv] = (counts[cv] ?? 0) + 1;
    }
    final sorted = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return sorted;
  }

  Future<List<TVoiceWorkCategoryData>> selectAllCategory() async =>
      select(tVoiceWorkCategory).get();

  Future<List<TVoiceItemData>> selectSingleWorkVoiceItems(
      TVoiceWorkData voiceWorkData) {
    return (select(tVoiceItem)
          ..where((voiceItem) =>
              voiceItem.voiceWorkPath.equals(voiceWorkData.title)))
        .get();
  }

  Future<List<TVoiceItemData>> selectSingleWorkVoiceItemsWithPath(
      String vwPath) {
    return (select(tVoiceItem)
          ..where((voiceItem) => voiceItem.voiceWorkPath.equals(vwPath)))
        .get();
  }

  // 根据CV筛选出VoiceWork
  Future<List<TVoiceWorkData>> selectVwWithCv(String cvName) async {
    final query = await (select(tVoiceWork).join([
      innerJoin(
        tVoiceCV,
        tVoiceCV.voiceWorkPath.equalsExp(tVoiceWork.directoryPath),
      ),
    ])
          ..where(tVoiceCV.cvName.equals(cvName)))
        .get();

    return query.map((row) => row.readTable(tVoiceWork)).toList();
  }

  // 根据类别筛选出VoiceWork
  Future<List<TVoiceWorkData>> selectVwWithCategory(String category) async {
    final query = await (select(tVoiceWork).join([
      innerJoin(
        tVoiceWorkCategory,
        tVoiceWorkCategory.description.equalsExp(tVoiceWork.category),
      ),
    ])
          ..where(tVoiceWork.category.equals(category)))
        .get();

    return query.map((row) => row.readTable(tVoiceWork)).toList();
  }

  // 根据CV和类别筛选出VoiceWork
  Future<List<TVoiceWorkData>> selectVwWithCvAndCategory(
      String cvName, String category) async {
    final query = await (select(tVoiceWork).join([
      innerJoin(
        tVoiceCV,
        tVoiceCV.voiceWorkPath.equalsExp(tVoiceWork.directoryPath),
      ),
      innerJoin(
        tVoiceWorkCategory,
        tVoiceWorkCategory.description.equalsExp(tVoiceWork.category),
      ),
    ])
          ..where(tVoiceCV.cvName.equals(cvName) &
              tVoiceWork.category.equals(category)))
        .get();

    return query.map((row) => row.readTable(tVoiceWork)).toList();
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.

    final file = File(await sqliteDbPath());

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
