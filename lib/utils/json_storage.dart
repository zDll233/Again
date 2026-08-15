import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:again/utils/log.dart';

class JsonStorage {
  /// 固定路径; 与 [pathResolver] 二选一。
  final String? filePath;

  /// 懒解析路径 (Android 需异步取应用目录, Windows 保持相对路径)。
  final Future<String> Function()? pathResolver;

  JsonStorage({this.filePath, this.pathResolver});

  /// 写队列: 读改写操作串行执行, 避免并发覆盖 (如排序切换与窗口记忆同时写)。
  Future<void> _queue = Future<void>.value();

  Future<String> _resolvePath() async {
    if (filePath != null) {
      return filePath!;
    }
    final resolver = pathResolver;
    if (resolver == null) {
      throw StateError('JsonStorage: filePath and pathResolver are both null');
    }
    return resolver();
  }

  Future<Map<String, dynamic>> read() async {
    final filePath = await _resolvePath();
    try {
      final file = File(filePath);
      final contents = await file.readAsString();
      return json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      Log.error('Error reading "$filePath".\n$e.');
      return {};
    }
  }

  /// 读改写合并写入 (串行化, 不会互相覆盖)。
  Future<Map<String, dynamic>> mutate(
      FutureOr<Map<String, dynamic>> Function(Map<String, dynamic> old)
          update) {
    final prev = _queue;
    final next = prev.then((_) async {
      final old = await read();
      final updated = await update(old);
      await _writeRaw(updated);
      return updated;
    });
    _queue = next;
    return next;
  }

  Future<void> write(Map<String, dynamic> data) =>
      mutate((_) => data).then((_) {});

  Future<void> _writeRaw(Map<String, dynamic> data) async {
    final filePath = await _resolvePath();
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final contents = json.encode(data);
    await file.writeAsString(contents);
  }
}
