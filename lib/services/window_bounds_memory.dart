import 'dart:async';
import 'dart:ui';

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

/// 启动时恢复上次窗口位置/尺寸; 无记录或记录无效则跳过 (保持默认居中)。
Future<void> restoreWindowBounds(JsonStorage storage) async {
  try {
    final config = await storage.read();
    final b = config['windowBounds'];
    if (b is Map &&
        b['x'] is num &&
        b['y'] is num &&
        b['w'] is num &&
        b['h'] is num) {
      final x = (b['x'] as num).toDouble();
      final y = (b['y'] as num).toDouble();
      final w = (b['w'] as num).toDouble();
      final h = (b['h'] as num).toDouble();
      if (w >= 400 && h >= 300) {
        await windowManager.setBounds(Rect.fromLTWH(x, y, w, h));
      }
    }
  } catch (e) {
    Log.error('restoreWindowBounds error: $e');
  }
}
