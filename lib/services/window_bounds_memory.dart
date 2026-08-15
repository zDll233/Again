import 'dart:async';
import 'dart:ui';
import 'package:again/common/const.dart';
import 'package:again/utils/json_storage.dart';
import 'package:again/utils/log.dart';
import 'package:window_manager/window_manager.dart';

/// 窗口位置/尺寸记忆: 移动或缩放后防抖保存到 config (`windowBounds`),
/// 启动时由 initialization 恢复 (默认行为, 无设置开关)。
class WindowBoundsMemory extends WindowListener {
  WindowBoundsMemory(this._storage) {
    windowManager.addListener(this);
  }

  final JsonStorage _storage;
  Timer? _debounce;

  void dispose() {
    windowManager.removeListener(this);
    _debounce?.cancel();
  }

  @override
  void onWindowMove() => _scheduleSave();

  @override
  void onWindowResize() => _scheduleSave();

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), _save);
  }

  Future<void> _save() async {
    try {
      final bounds = await windowManager.getBounds();
      final config = await _storage.read();
      await _storage.write({
        ...config,
        'windowBounds': {
          'x': bounds.left,
          'y': bounds.top,
          'w': bounds.width,
          'h': bounds.height,
        },
      });
    } catch (e) {
      Log.error('WindowBoundsMemory save error: $e');
    }
  }
}

/// 启动时恢复上次窗口位置/尺寸 (按设置分别生效); 记录无效或开关关闭则跳过。
Future<void> restoreWindowBounds(JsonStorage storage) async {
  try {
    final config = await storage.read();
    final b = config['windowBounds'];
    if (b is! Map) return;
    final rememberPos = config['rememberWindowPos'] ?? kDefaultRememberWindowPos;
    final rememberSize = config['rememberWindowSize'] ?? kDefaultRememberWindowSize;
    final sizeValid =
        b['w'] is num && b['h'] is num && (b['w'] as num) >= 400 &&
            (b['h'] as num) >= 300;
    final posValid = b['x'] is num && b['y'] is num;
    if (rememberSize && sizeValid) {
      await windowManager.setSize(Size(
        (b['w'] as num).toDouble(),
        (b['h'] as num).toDouble(),
      ));
    }
    if (rememberPos && posValid) {
      await windowManager.setPosition(Offset(
        (b['x'] as num).toDouble(),
        (b['y'] as num).toDouble(),
      ));
    }
  } catch (e) {
    Log.error('restoreWindowBounds error: $e');
  }
}
