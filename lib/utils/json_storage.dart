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

  /// 同一路径的读写队列, 跨 [JsonStorage] 实例共享。
  ///
  /// 配置/历史 provider 可能被多个调用点各自实例化; 只靠实例字段串行化时,
  /// 启动阶段恢复排序等并发写会互相覆盖, 甚至因读到写了一半的文件
  /// 而把配置当成空对象 (回退默认值)。按真实文件路径排队可避免该竞态,
  /// 同时避免 Windows 上「读取句柄未关 → rename 覆盖失败」。
  static final Map<String, Future<void>> _queues = {};

  /// 临时文件序号, 避免同一进程内并发写同一路径时临时文件重名。
  static int _tempFileSeq = 0;

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

  /// 按路径串行执行 [action]。读与写都走同一个队列, 保证读到的永远是
  /// 完整文件, 且不会与 rename 撞车。
  Future<T> _enqueue<T>(String path, Future<T> Function() action) async {
    final previous = _queues[path] ?? Future<void>.value();
    final completion = Completer<void>();
    _queues[path] = completion.future;
    try {
      await previous;
      return await action();
    } finally {
      completion.complete();
      if (identical(_queues[path], completion.future)) {
        _queues.remove(path);
      }
    }
  }

  Future<Map<String, dynamic>> read() async {
    final path = await _resolvePath();
    return _enqueue(path, () => _readRaw(path));
  }

  Future<Map<String, dynamic>> _readRaw(String path) async {
    for (var attempt = 0;; attempt++) {
      try {
        final contents = await File(path).readAsString();
        final decoded = json.decode(contents);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('JSON root is not an object');
        }
        return decoded;
      } on PathNotFoundException {
        // 文件尚不存在 (首次运行) — 空配置, 不记错误日志。
        return {};
      } catch (e) {
        // 读写已串行化, 这里主要兜底外部进程/杀毒软件造成的瞬时占用;
        // 短暂重试后仍失败才回退空配置。
        if (attempt >= 2) {
          Log.error('Error reading "$path".\n$e.');
          return {};
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    }
  }

  /// 读改写合并写入 (同一路径串行执行, 不会互相覆盖)。
  ///
  /// 注意: [update] 回调在队列内执行, 不要在回调里再调用本对象的
  /// [read]/[mutate] (会等待自己而死锁)。
  Future<Map<String, dynamic>> mutate(
      FutureOr<Map<String, dynamic>> Function(Map<String, dynamic> old)
          update) async {
    final path = await _resolvePath();
    return _enqueue(path, () async {
      final old = await _readRaw(path);
      final updated = await update(old);
      await _writeRaw(path, updated);
      return updated;
    });
  }

  Future<void> write(Map<String, dynamic> data) =>
      mutate((_) => data).then((_) {});

  /// 原子写入: 先写同目录临时文件, 再 rename 覆盖目标文件。
  ///
  /// 直接 [File.writeAsString] 会先截断目标文件, 此时其它读者 (另一处
  /// provider / 另一个 JsonStorage 实例) 可能读到空内容或半截 JSON,
  /// 表现为「启动时偶发没读到配置, 全用默认值」。rename 在同一文件系统内
  /// 是原子的, 读者只会看到完整的旧文件或完整的新文件。
  Future<void> _writeRaw(String path, Map<String, dynamic> data) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    final temp = File('$path.tmp${pid}_${_tempFileSeq++}');
    try {
      await temp.writeAsString(json.encode(data), flush: true);
      for (var attempt = 0;; attempt++) {
        try {
          await temp.rename(path);
          return;
        } on FileSystemException {
          // Windows 上目标文件可能被外部句柄短暂占用; 重试后仍失败则抛出。
          if (attempt >= 4) rethrow;
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      }
    } finally {
      if (await temp.exists()) {
        try {
          await temp.delete();
        } catch (_) {
          // 临时文件清理失败不影响写入结果; 下次写入会使用新的临时文件名。
        }
      }
    }
  }
}
