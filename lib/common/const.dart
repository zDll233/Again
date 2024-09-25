import 'package:again/utils/json_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

const double titleBarHeight = 50.0;
const double playerWidgetHeight = 90.0;

const List<String> audioExtensions = [
  '.mp3',
  '.wav',
  '.aac',
  '.flac',
  '.ogg',
  '.m4a',
];

const List<String> imgExtensions = [
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
];

final configFilePath = p.join('config', 'config.json');
final historyFilePath = p.join('history', 'last_played.json');
final deleteScriptPath = p.join('scripts', 'delete.ps1');
final sqliteDatabasePath = p.join('data', 'storage', 'again_voiceworks.db');

final configJsonProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(filePath: configFilePath);
});

final historyJsonProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(filePath: historyFilePath);
});
