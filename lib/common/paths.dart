import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 应用数据根目录 (config/data/history 的父目录)。
/// Windows: CWD — 保持现有相对路径布局 (config/, data/, history/);
/// Android: 应用文档目录 (无 CWD 概念)。
Future<Directory> getAppDataRoot() async {
  if (!Platform.isAndroid) {
    return Directory.current;
  }
  return getApplicationDocumentsDirectory();
}

Future<String> configFilePath() async =>
    p.join((await getAppDataRoot()).path, 'config', 'config.json');

Future<String> historyFilePath() async =>
    p.join((await getAppDataRoot()).path, 'history', 'last_played.json');

Future<String> sqliteDbPath() async => p.join(
    (await getAppDataRoot()).path, 'data', 'storage', 'again_voiceworks.db');
