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
