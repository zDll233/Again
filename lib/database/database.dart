import 'package:again/controller/controller.dart';
import 'package:drift/drift.dart';

// These additional imports are necessary to open the sqlite3 database
import 'dart:io';
import 'package:drift/native.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart';

class TVoiceItem extends Table {
  TextColumn get title => text()();
  TextColumn get filePath => text()();
  TextColumn get voiceWorkTitle => text().references(TVoiceWork, #title)();

  @override
  Set<Column> get primaryKey => {title};
}

class TVoiceWork extends Table {
  TextColumn get title => text()();
  TextColumn get diretoryPath => text()();
  TextColumn get category =>
      text().references(TVoiceWorkCategory, #description)();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {title};
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
  TextColumn get vkTitle => text().references(TVoiceWork, #title)();
  TextColumn get cvName => text().references(TCV, #cvName)();

  @override
  Set<Column> get primaryKey => {vkTitle, cvName};
}

@DriftDatabase(
    tables: [TVoiceItem, TVoiceWork, TVoiceWorkCategory, TCV, TVoiceCV])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // Make sure that foreign keys are enabled
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // insert
  Future<void> insertMultipleVoiceWorks(List<TVoiceWorkCompanion> vkc) async {
    await batch((batch) {
      // functions in a batch don't have to be awaited - just
      // await the whole batch afterwards.
      batch.insertAll(tVoiceWork, vkc, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> insertMultipleVoiceItems(List<TVoiceItemCompanion> vic) async {
    await batch((batch) {
      batch.insertAll(tVoiceItem, vic, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> insertMultipleVoiceWorkCategories(
      List<TVoiceWorkCategoryCompanion> vkcc) async {
    await batch((batch) {
      batch.insertAll(tVoiceWorkCategory, vkcc,
          mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> insertMultipleCvs(List<TCVCompanion> cvc) async {
    await batch((batch) {
      batch.insertAll(tcv, cvc, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<void> insertMultipleVoiceCvs(List<TVoiceCVCompanion> vcc) async {
    await batch((batch) {
      batch.insertAll(tVoiceCV, vcc, mode: InsertMode.insertOrIgnore);
    });
  }

  // select
  Future<List<TVoiceWorkData>> get selectAllVoiceWorks =>
      select(tVoiceWork).get();

  Future<List<TVoiceItemData>> get selectAllVoiceItems =>
      select(tVoiceItem).get();

  Future<List<TCVData>> selectAllCv() async => select(tcv).get();

  Future<List<TVoiceWorkCategoryData>> selectAllCategory() async =>
      select(tVoiceWorkCategory).get();

  Future<List<TVoiceItemData>> selectSingleWorkVoiceItems(
      TVoiceWorkData voiceWorkData) {
    return (select(tVoiceItem)
          ..where((voiceItem) =>
              voiceItem.voiceWorkTitle.equals(voiceWorkData.title)))
        .get();
  }

  Future<List<TVoiceItemData>> selectSingleWorkVoiceItemsWithString(
      String vkTitle) {
    return (select(tVoiceItem)
          ..where((voiceItem) => voiceItem.voiceWorkTitle.equals(vkTitle)))
        .get();
  }

  // 根据CV筛选出VoiceWork
  Future<List<TVoiceWorkData>> selectVkWithCv(String cvName) async {
    var query = await (select(tVoiceWork).join([
      innerJoin(tVoiceCV, tVoiceCV.vkTitle.equalsExp(tVoiceWork.title)),
    ])
          ..where(tVoiceCV.cvName.equals(cvName)))
        .get();

    return query.map((row) => row.readTable(tVoiceWork)).toList();
  }

  // 根据类别筛选出VoiceWork
  Future<List<TVoiceWorkData>> selectVkWithCategory(String category) async {
    var query = await (select(tVoiceWork).join([
      innerJoin(tVoiceWorkCategory,
          tVoiceWorkCategory.description.equalsExp(tVoiceWork.category)),
    ])
          ..where(tVoiceWork.category.equals(category)))
        .get();

    return query.map((row) => row.readTable(tVoiceWork)).toList();
  }

  // 根据CV和类别筛选出VoiceWork
  Future<List<TVoiceWorkData>> selectVkWithCvAndCategory(
      String cvName, String category) async {
    var query = await (select(tVoiceWork).join([
      innerJoin(tVoiceCV, tVoiceCV.vkTitle.equalsExp(tVoiceWork.title)),
      innerJoin(tVoiceWorkCategory,
          tVoiceWorkCategory.description.equalsExp(tVoiceWork.category)),
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

    final Controller c = Get.find();
    const fileName = 'again_voiceworks.db';
    final filePath = p.normalize(
        p.join(c.cdb.currentDir.path, c.cdb.directoryPath, fileName));

    final file = File(filePath);

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
