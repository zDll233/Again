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
}
