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

    final result = scanRoot(tempRoot.path, {});

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

  test('签名一致的作品跳过内部扫描 (增量)', () {
    final categoryDir = Directory(p.join(tempRoot.path, '分类A'))
      ..createSync();
    final workDir = Directory(p.join(categoryDir.path, 'cv1-作品名'))
      ..createSync();
    File(p.join(workDir.path, 'track1.mp3')).createSync();
    final signature = dirScanSignature(workDir);

    final result = scanRoot(tempRoot.path, {p.normalize(workDir.path): signature});

    final work = result.works.single;
    expect(work.sourceId, isEmpty);
    expect(work.coverPath, isEmpty);
    expect(work.items, isEmpty);
  });

  test('签名不一致时重新扫描内部', () {
    final categoryDir = Directory(p.join(tempRoot.path, '分类A'))
      ..createSync();
    final workDir = Directory(p.join(categoryDir.path, 'cv1-作品名'))
      ..createSync();
    File(p.join(workDir.path, 'track1.mp3')).createSync();

    final result = scanRoot(tempRoot.path, {p.normalize(workDir.path): '0|0'});

    final work = result.works.single;
    expect(work.sourceId, isEmpty);
    expect(
      work.items.map((e) => e.title),
      unorderedEquals(['track1']),
    );
  });

  test('sourceId 为空时不合法目录不产生 sourceId', () {
    final categoryDir = Directory(p.join(tempRoot.path, '分类A'))
      ..createSync();
    final workDir = Directory(p.join(categoryDir.path, 'cv1-作品名'))
      ..createSync();
    Directory(p.join(workDir.path, '不是sourceId的目录')).createSync();

    final result = scanRoot(tempRoot.path, {});

    expect(result.works.single.sourceId, isEmpty);
  });
}
