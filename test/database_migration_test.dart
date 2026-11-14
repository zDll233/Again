import 'package:again/services/database/db/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('schema v4 -> v5: 删除 scan_signature 且保留作品/音轨数据', () async {
    final raw = sqlite3.openInMemory();
    // 最小化的 v4 表结构 (含已弃用的 scan_signature 列)。
    raw.execute('CREATE TABLE t_voice_work_category ('
        'description TEXT NOT NULL, PRIMARY KEY (description))');
    raw.execute('CREATE TABLE t_voice_work ('
        'title TEXT NOT NULL, '
        'source_id TEXT NOT NULL, '
        'directory_path TEXT NOT NULL, '
        'cover_path TEXT NOT NULL, '
        'category TEXT NOT NULL REFERENCES t_voice_work_category (description), '
        'created_at INTEGER, '
        'scan_signature TEXT, '
        'PRIMARY KEY (directory_path))');
    raw.execute('CREATE TABLE t_voice_item ('
        'title TEXT NOT NULL, '
        'file_path TEXT NOT NULL, '
        'voice_work_path TEXT NOT NULL REFERENCES t_voice_work (directory_path), '
        'created_at INTEGER, '
        'PRIMARY KEY (file_path))');
    raw.execute('CREATE TABLE tcv ('
        'cv_name TEXT NOT NULL, PRIMARY KEY (cv_name))');
    raw.execute('CREATE TABLE t_voice_c_v ('
        'voice_work_path TEXT NOT NULL REFERENCES t_voice_work (directory_path), '
        'cv_name TEXT NOT NULL REFERENCES t_cv (cv_name), '
        'PRIMARY KEY (voice_work_path, cv_name))');

    raw.execute("INSERT INTO t_voice_work_category VALUES ('分类A')");
    raw.execute('INSERT INTO t_voice_work '
        "VALUES ('作品1', 'RJ123456', '/root/作品1', '/root/c.jpg', '分类A', 1700000000, 'sig')");
    raw.execute('INSERT INTO t_voice_item '
        "VALUES ('track1', '/root/作品1/track1.mp3', '/root/作品1', 1700000000)");
    raw.execute("INSERT INTO tcv VALUES ('cv1')");
    raw.execute("INSERT INTO t_voice_c_v VALUES ('/root/作品1', 'cv1')");
    raw.execute('PRAGMA user_version = 4');

    final db = AppDatabase(connection: NativeDatabase.opened(raw));
    addTearDown(db.close);

    final works = await db.selectAllVoiceWorks;
    expect(works, hasLength(1));
    expect(works.single.title, '作品1');
    expect(works.single.createdAt, isNotNull);

    final items = await db.selectAllVoiceItems;
    expect(items, hasLength(1));
    expect(items.single.title, 'track1');

    final cvs = await db.selectAllCv();
    expect(cvs.map((e) => e.cvName), ['cv1']);

    final columns = raw.select('PRAGMA table_info(t_voice_work)');
    expect(
      columns.any((row) => row['name'] == 'scan_signature'),
      isFalse,
      reason: 'v5 迁移应删除已弃用的 scan_signature 列',
    );
    expect(
        await db
            .customSelect('PRAGMA user_version')
            .getSingle()
            .then((row) => row.read<int>('user_version')),
        5);
  });
}
