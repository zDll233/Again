import 'dart:io';

import 'package:again/services/window_setup_windows.dart' as win;

/// 窗口初始化入口。
/// Windows: 丙烯酸/透明窗口、隐藏标题栏、最小尺寸、显示前应用窗口效果。
/// 其他平台 (Android 等): 空操作。
Future<void> setupWindow() async {
  if (Platform.isWindows) {
    await win.setupWindowWindows();
  }
}

/// 应用窗口背景效果后清理 DWM 残留 (Windows 专属)。
///
/// 修复「亚克力 → 透明」切换后窗口上边界出现一道 1px 亮边 (重启消失):
/// flutter_acrylic 离开亚克力时把 DWM frame 扩展留成 {0, 0, 1, 0}, 顶部 1px
/// 玻璃 frame 在透明窗口上渲染成纯白线。详见
/// `window_setup_windows.dart` 的 [win.resetBackdropResidue]。
Future<void> resetWindowBackdropResidue() async {
  if (Platform.isWindows) {
    await win.resetBackdropResidue();
  }
}
