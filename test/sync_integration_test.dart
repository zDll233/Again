import 'dart:io';

import 'package:again/services/database/db/database.dart';
import 'package:again/services/database/voice_updater.dart';
import 'package:drift/drift.dart' show LazyDatabase;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late AppDatabase db;
  late Directory libDir;

  setUp(() {
    db = AppDatabase(
      connection: LazyDatabase(() async => NativeDatabase.memory()),
    );

    // 重建测试音声库:
    // 分类A/cv1&cv2-测试作品1/RJ123456/{cover.jpg, track1.mp3}
    // 分类A/cv3-空作品
    // 分类B/cv1-测试作品2/RJ654321/{track1.wav, track2.flac}
    libDir = Directory.systemTemp.createTempSync('again_sync_test');
    final catA = Directory(p.join(libDir.path, '分类A'))..createSync();
    final work1 = Directory(p.join(catA.path, 'cv1&cv2-测试作品1'))
      ..createSync();
    Directory(p.join(work1.path, 'RJ123456')).createSync();
    File(p.join(work1.path, 'RJ123456', 'cover.jpg')).createSync();
    File(p.join(work1.path, 'RJ123456', 'track1.mp3')).createSync();
    Directory(p.join(catA.path, 'cv3-空作品')).createSync();
    final catB = Directory(p.join(libDir.path, '分类B'))..createSync();
    final work2 = Directory(p.join(catB.path, 'cv1-测试作品2'))
      ..createSync();
    Directory(p.join(work2.path, 'RJ654321')).createSync();
    File(p.join(work2.path, 'RJ654321', 'track1.wav')).createSync();
    File(p.join(work2.path, 'RJ654321', 'track2.flac')).createSync();
  });

  tearDown(() async {
    await db.close();
    libDir.deleteSync(recursive: true);
  });

  test('增量同步全流程: 首次/无变化/新增/删除', () async {
    // 1. 首次全量扫描
    await VoiceUpdater(db, libDir.path).update();
    var works = await db.selectAllVoiceWorks;
    var items = await db.selectAllVoiceItems;
    var cats = (await db.selectAllCategory()).map((e) => e.description);
    var cvs = (await db.selectAllCv()).map((e) => e.cvName).toList();
    var vcc = await db.select(db.tVoiceCV).get();

    expect(works, hasLength(3));
    expect(items, hasLength(3));
    expect(cats.toSet(), {'分类A', '分类B'});
    expect(cvs.toSet(), {'cv1', 'cv2', 'cv3'});
    expect(vcc, hasLength(4)); // cv1&cv2-测试作品1 + cv1-测试作品2 + cv3-空作品

    final work1 = works.firstWhere((w) => w.title == 'cv1&cv2-测试作品1');
    expect(work1.category, '分类A');
    expect(work1.sourceId, 'RJ123456');
    expect(work1.coverPath, endsWith('cover.jpg'));
    expect(work1.createdAt, isNotNull);

    // 2. 二次扫描: 无变化, 数据保持
    await VoiceUpdater(db, libDir.path).update();
    works = await db.selectAllVoiceWorks;
    expect(works, hasLength(3));

    // 3. 向 cv3-空作品 添加音频文件 -> 仅该作品更新
    File(p.join(libDir.path, '分类A', 'cv3-空作品', 'new_track.ogg'))
        .createSync();
    await VoiceUpdater(db, libDir.path).update();
    items = await db.selectAllVoiceItems;
    expect(items, hasLength(4));
    expect(
      items.where((i) => i.title == 'new_track'),
      hasLength(1),
    );

    // 4. 删除整个 分类B -> 作品/条目/分类清理
    Directory(p.join(libDir.path, '分类B')).deleteSync(recursive: true);
    await VoiceUpdater(db, libDir.path).update();
    works = await db.selectAllVoiceWorks;
    items = await db.selectAllVoiceItems;
    cats = (await db.selectAllCategory()).map((e) => e.description);
    cvs = (await db.selectAllCv()).map((e) => e.cvName).toList();
    vcc = await db.select(db.tVoiceCV).get();

    expect(works, hasLength(2));
    expect(items, hasLength(2));
    expect(cats, isNot(contains('分类B')));
    expect(cvs.toSet(), {'cv1', 'cv2', 'cv3'}); // cv1 仍属于测试作品1
    expect(vcc, hasLength(3));
    expect(vcc.where((v) => v.cvName == 'cv1'), hasLength(1));
  });

  test('CV 列表: 分类限定 + 作品数倒序', () async {
    // 分类A: cv1&cv2-测试作品1, cv3-空作品, cv1-作品
    // 分类B: cv1-测试作品2
    Directory(p.join(libDir.path, '分类A', 'cv1-作品')).createSync();
    await VoiceUpdater(db, libDir.path).update();

    // 全部: cv1(3) cv2(1) cv3(1), 按作品数倒序
    var cvs = await db.selectCvsOrderedByCount(null);
    expect(cvs, ['cv1', 'cv2', 'cv3']);

    // 仅分类B: cv1
    cvs = await db.selectCvsOrderedByCount('分类B');
    expect(cvs, ['cv1']);
  });

  test('深层文件删除: 子目录中的音频被删除后能检测到', () async {
    // 作品结构: 分类A/cv1-作品/RJ1/track1.mp3 + track2.mp3
    final catA = Directory(p.join(libDir.path, '分类A'))..createSync();
    final work = Directory(p.join(catA.path, 'cv1-作品'))..createSync();
    final sub = Directory(p.join(work.path, 'RJ1'))..createSync();
    File(p.join(sub.path, 'track1.mp3')).createSync();
    File(p.join(sub.path, 'track2.mp3')).createSync();

    Future<List<dynamic>> itemsOfWork() async => (await db.selectAllVoiceItems)
        .where((i) => i.voiceWorkPath == work.path)
        .toList();

    await VoiceUpdater(db, libDir.path).update();
    expect(await itemsOfWork(), hasLength(2));

    // 删除子目录中的一个音频(顶层子项数不变, 只有深层 mtime 变化)
    File(p.join(sub.path, 'track1.mp3')).deleteSync();
    await VoiceUpdater(db, libDir.path).update();

    final items = await itemsOfWork();
    expect(items, hasLength(1));
    expect(items.single.title, 'track2');
  });

  test('同一作品内增删混合: 换了一个文件', () async {
    final catA = Directory(p.join(libDir.path, '分类A'))..createSync();
    final work = Directory(p.join(catA.path, 'cv1-作品'))..createSync();
    final sub = Directory(p.join(work.path, 'RJ1'))..createSync();
    File(p.join(sub.path, 'track1.mp3')).createSync();
    File(p.join(sub.path, 'track2.mp3')).createSync();

    Future<List<dynamic>> itemsOfWork() async => (await db.selectAllVoiceItems)
        .where((i) => i.voiceWorkPath == work.path)
        .toList();

    await VoiceUpdater(db, libDir.path).update();
    expect(await itemsOfWork(), hasLength(2));

    // 删除 track1 并新增 track3: 顶层 count 不变
    File(p.join(sub.path, 'track1.mp3')).deleteSync();
    File(p.join(sub.path, 'track3.mp3')).createSync();
    await VoiceUpdater(db, libDir.path).update();

    final items = await itemsOfWork();
    expect(items.map((i) => i.title).toSet(), {'track2', 'track3'});
  });

  test('CV 差量: 作品改名后旧 CV 清理、新 CV 建立, 共享 CV 不受影响', () async {
    await VoiceUpdater(db, libDir.path).update();
    expect((await db.selectAllCv()).map((e) => e.cvName).toSet(),
        {'cv1', 'cv2', 'cv3'});

    // 改名 cv1&cv2-测试作品1 -> cv2&cv4-测试作品1 (路径变化, 整作品重写)
    final oldDir =
        Directory(p.join(libDir.path, '分类A', 'cv1&cv2-测试作品1'));
    final newDir =
        Directory(p.join(libDir.path, '分类A', 'cv2&cv4-测试作品1'));
    await oldDir.rename(newDir.path);

    await VoiceUpdater(db, libDir.path).update();

    // cv1 仍被作品2 引用 → 保留; cv2 仍在改名后作品; cv3 空作品; cv4 新增
    final cvs = (await db.selectAllCv()).map((e) => e.cvName).toSet();
    expect(cvs, {'cv1', 'cv2', 'cv3', 'cv4'});

    final vcc = await db.select(db.tVoiceCV).get();
    // 旧路径关系删除, 新路径重建: cv2/cv4; 作品2(cv1)、空作品(cv3) 保留
    expect(vcc, hasLength(4));
    final newWorkCvs = vcc
        .where((v) => v.voiceWorkPath == newDir.path)
        .map((v) => v.cvName)
        .toSet();
    expect(newWorkCvs, {'cv2', 'cv4'});
    // 其他作品关系不动
    expect(
        vcc.where((v) => v.voiceWorkPath != newDir.path).map((v) => v.cvName),
        containsAll(['cv1', 'cv3']));
  });

  test('CV 差量: 删除唯一持有某 CV 的作品后孤立 CV 被清理', () async {
    await VoiceUpdater(db, libDir.path).update();

    // cv2 只属于作品1, cv3 只属于空作品 → 删除后应被清理
    Directory(p.join(libDir.path, '分类A', 'cv1&cv2-测试作品1'))
        .deleteSync(recursive: true);
    Directory(p.join(libDir.path, '分类A', 'cv3-空作品'))
        .deleteSync(recursive: true);

    await VoiceUpdater(db, libDir.path).update();

    final cvs = (await db.selectAllCv()).map((e) => e.cvName).toSet();
    expect(cvs, {'cv1'}); // cv1 仍被作品2 引用
    final vcc = await db.select(db.tVoiceCV).get();
    expect(vcc, hasLength(1));
    expect(vcc.single.cvName, 'cv1');
  });

  test('schema v3: 全部查询索引已创建', () async {
    final rows = await db
        .customSelect(
            "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE '%Index'")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll([
        'tVoiceItemVoiceWorkPathIndex',
        'tVoiceWorkCategoryIndex',
        'tVoiceCVVoiceWorkPathIndex',
        'tVoiceCVCvNameIndex',
      ]),
    );
  });
}
