import 'dart:async';
import 'dart:io';

import 'package:again/utils/json_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late String path;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('again_json_storage');
    path = '${tempDir.path}/config.json';
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('并发 mutate (不同实例) 不会丢键', () async {
    await JsonStorage(filePath: path).write({'base': true});

    await Future.wait([
      for (var i = 0; i < 20; i++)
        JsonStorage(filePath: path).mutate((config) => {...config, 'key$i': i}),
    ]);

    final data = await JsonStorage(filePath: path).read();
    expect(data['base'], isTrue);
    for (var i = 0; i < 20; i++) {
      expect(data['key$i'], i);
    }
    // 临时文件不应残留
    expect(
      tempDir.listSync().where((e) => e.path.contains('.tmp')),
      isEmpty,
    );
  });

  test('原子替换: 写入期间读取不会拿到空配置/半截 JSON', () async {
    final writer = JsonStorage(filePath: path);
    await writer.write({'value': 0, 'filler': 'x' * 4096});

    final stop = Completer<void>();
    final reads = <Map<String, dynamic>>[];
    final reader = () async {
      while (!stop.isCompleted) {
        // 每次用新实例读取, 模拟启动时多个 provider 各自 read 的情况。
        reads.add(await JsonStorage(filePath: path).read());
        await Future<void>.delayed(Duration.zero);
      }
    }();

    for (var i = 1; i <= 100; i++) {
      await writer.write({'value': i, 'filler': 'x' * 4096});
    }
    stop.complete();
    await reader;

    expect(reads, isNotEmpty);
    for (final data in reads) {
      expect(data.containsKey('value'), isTrue, reason: '读到空配置会回退默认值');
    }
  });

  test('文件不存在时返回空配置', () async {
    expect(await JsonStorage(filePath: path).read(), isEmpty);
  });
}
