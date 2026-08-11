import 'dart:io';

import 'package:again/services/database/voice_updater.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempRoot;

  setUp(() {
    tempRoot = Directory.systemTemp.createTempSync('again_scan_test');
  });

  tearDown(() {
    tempRoot.deleteSync(recursive: true);
  });

  test('扫描完整作品: sourceId/封面/音频条目', () {
    final categoryDir = Directory(p.join(tempRoot.path, '分类A'))
      ..createSync();
    final workDir = Directory(p.join(categoryDir.path, 'cv1&cv2-作品名'))
      ..createSync();
    Directory(p.join(workDir.path, 'RJ123456')).createSync();
    File(p.join(workDir.path, 'cover.jpg')).createSync();
    File(p.join(workDir.path, 'track1.mp3')).createSync();
    File(p.join(workDir.path, 'track2.wav')).createSync();

    final result = scanRoot(tempRoot.path);

    expect(result.categoryNames, ['分类A']);
    expect(result.works, hasLength(1));

    final work = result.works.single;
    expect(work.title, 'cv1&cv2-作品名');
    expect(work.sourceId, 'RJ123456');
    expect(work.coverPath, p.join(workDir.path, 'cover.jpg'));
    expect(
      work.items.map((e) => e.title),
      unorderedEquals(['track1', 'track2']),
    );
  });

  test('sourceId 为空时不合法目录不产生 sourceId', () {
    final categoryDir = Directory(p.join(tempRoot.path, '分类A'))
      ..createSync();
    final workDir = Directory(p.join(categoryDir.path, 'cv1-作品名'))
      ..createSync();
    Directory(p.join(workDir.path, '不是sourceId的目录')).createSync();

    final result = scanRoot(tempRoot.path);

    expect(result.works.single.sourceId, isEmpty);
  });

  test('深层音频也被收集', () {
    final categoryDir = Directory(p.join(tempRoot.path, '分类A'))
      ..createSync();
    final workDir = Directory(p.join(categoryDir.path, 'cv1-作品名'))
      ..createSync();
    Directory(p.join(workDir.path, 'RJ123456')).createSync();
    File(p.join(workDir.path, 'RJ123456', 'track1.mp3')).createSync();
    File(p.join(workDir.path, 'track2.mp3')).createSync();

    final result = scanRoot(tempRoot.path);

    expect(
      result.works.single.items.map((e) => e.title),
      unorderedEquals(['track1', 'track2']),
    );
  });
}
