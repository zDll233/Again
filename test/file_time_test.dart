import 'dart:io';

import 'package:again/utils/file_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('取到的是创建时间, 不是修改时间', () async {
    final dir = Directory.systemTemp.createTempSync('again_file_time');
    try {
      // 先记下创建时刻的 mtime (Windows 上 dart:io 的 FileStat 只有秒级精度),
      // 再改动 mtime。必须改完才取时间 —— 此时两者不同, 才能区分读到了哪个。
      final before = FileStat.statSync(dir.path);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      File(p.join(dir.path, 'tmp.txt')).createSync();
      final after = FileStat.statSync(dir.path);

      expect(after.modified.difference(before.modified).inMilliseconds,
          greaterThanOrEqualTo(1000),
          reason: '前置条件: 增删子项应把目录 mtime 推到 1 秒之后');

      final picked = creationOrModifiedTime(after);
      if (!Platform.isWindows) {
        // 非 Windows 没有创建时间 API: 明确回退 mtime
        expect(picked, after.modified);
        return;
      }

      // 应落在创建时刻; 若贴近改动后的 mtime 说明取错了字段
      expect(picked.difference(before.modified).inMilliseconds.abs(),
          lessThan(1000),
          reason: '应贴近创建时刻; 若贴近改动后的 mtime 说明取错字段');
      expect(picked, isNot(after.modified));

      // 文件同理: 写入内容后创建时间不变 (mtime 会变)
      final file = File(p.join(dir.path, 'tmp.txt'));
      final fileBefore = file.statSync();
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      file.writeAsStringSync('x');
      final fileAfter = file.statSync();
      expect(fileAfter.modified.difference(fileBefore.modified).inMilliseconds,
          greaterThanOrEqualTo(1000),
          reason: '前置条件: 写文件应把文件 mtime 推到 1 秒之后');
      expect(creationOrModifiedTime(fileAfter), fileBefore.changed,
          reason: '写内容不应改变"取到的时间"');
    } finally {
      dir.deleteSync(recursive: true);
    }
  });
}
