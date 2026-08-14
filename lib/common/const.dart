import 'package:again/utils/json_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double TITLEBAR_HEIGHT = 40.0;
const double PLAYER_WIDGET_HEIGHT = 90.0;

const List<String> AUDIO_EXTENSIONS = [
  '.mp3',
  '.wav',
  '.aac',
  '.flac',
  '.ogg',
  '.m4a',
];

const List<String> IMG_EXTENSIONS = [
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
];

const CONFIG_FILE_PATH = 'config/config.json';
const HISTORY_FILE_PATH = 'history/last_played.json';
const DELETE_SCRIPT_PATH = 'scripts/delete.ps1';
const SQLITE_DB_PATH = 'data/storage/again_voiceworks.db';

/// 窗口背景效果模式 (config.json `windowEffect`)。
const String WINDOW_EFFECT_TRANSPARENT = 'transparent';
const String WINDOW_EFFECT_ACRYLIC = 'acrylic';
const String WINDOW_EFFECT_OPAQUE = 'opaque';

/// 默认主题色 (config.json `themeSeedColor` 缺省值, #RRGGBB)。
const String kDefaultThemeSeedHex = '#00BCD4';

final configJsonProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(filePath: CONFIG_FILE_PATH);
});

final historyJsonProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(filePath: HISTORY_FILE_PATH);
});
