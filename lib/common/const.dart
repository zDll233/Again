import 'package:again/common/paths.dart';
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

const String DELETE_SCRIPT_PATH = 'scripts/delete.ps1';

/// 窗口背景效果模式 (config.json `windowEffect`)。
const String WINDOW_EFFECT_TRANSPARENT = 'transparent';
const String WINDOW_EFFECT_ACRYLIC = 'acrylic';
const String WINDOW_EFFECT_OPAQUE = 'opaque';

/// 默认主题色 (config.json `themeSeedColor` 缺省值, #RRGGBB)。
const String kDefaultThemeSeedHex = '#00BCD4';

// 布尔开关缺省值 (读取处与重置块统一引用, 避免语义默认与重置默认不一致)
const bool kDefaultCloseToTray = true;
const bool kDefaultRememberWindowPos = false;
const bool kDefaultRememberWindowSize = true;
const bool kDefaultSearchEnabled = false;

final configJsonProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(pathResolver: configFilePath);
});

final historyJsonProvider = Provider.autoDispose<JsonStorage>((ref) {
  return JsonStorage(pathResolver: historyFilePath);
});
