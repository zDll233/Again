import 'package:drift/drift.dart';

// These additional imports are necessary to open the sqlite3 database
import 'dart:io';
import 'package:drift/native.dart';
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
  // IntColumn get voiceCounts => integer()(); TODO：需要一个触发器，每添加一个voiceItem，count++.
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

@DriftDatabase(tables: [TVoiceItem, TVoiceWork, TVoiceWorkCategory])
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
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'again_voiceworks.db'));

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
