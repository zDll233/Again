import 'package:again/utils/json_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final configFilePath = p.join('config', 'config.json');
final historyFilePath = p.join('history', 'last_played.json');
final deleteScriptPath = p.join('scripts', 'delete.ps1');
final sqliteDatabasePath = p.join('data', 'storage', 'again_voiceworks.db');

final configProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(filePath: configFilePath);
});

final historyProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(filePath: historyFilePath);
});
