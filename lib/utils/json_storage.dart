import 'dart:io';
import 'dart:convert';

import 'package:again/utils/log.dart';

class JsonStorage {
  /// 固定路径; 与 [pathResolver] 二选一。
  final String? filePath;

  /// 懒解析路径 (Android 需异步取应用目录, Windows 保持相对路径)。
  final Future<String> Function()? pathResolver;

  JsonStorage({this.filePath, this.pathResolver});

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

  Future<void> write(Map<String, dynamic> data) async {
    final filePath = await _resolvePath();
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    final contents = json.encode(data);
    await file.writeAsString(contents);
  }
}
