import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// 系统托盘: 关窗隐藏到托盘, 托盘菜单可显示窗口/退出。
class SystemTrayListener with WindowListener, TrayListener {
  SystemTrayListener(this._ref);

  final Ref _ref;

  static const _showWindowKey = 'show_window';
  static const _exitKey = 'exit_app';

  static Future<void> init(Ref ref) async {
    try {
      final listener = SystemTrayListener(ref);
      windowManager.addListener(listener);
      trayManager.addListener(listener);

      await trayManager.setIcon('assets/images/app_icon.ico');
      await trayManager.setToolTip('Again');
      await trayManager.setContextMenu(Menu(
        items: [
          MenuItem(key: _showWindowKey, label: '显示主窗口'),
          MenuItem.separator(),
          MenuItem(key: _exitKey, label: '退出'),
        ],
      ));
    } catch (e) {
      // 托盘初始化失败不阻塞启动, 仅影响托盘功能
      Log.error('Tray init failed.\n$e');
    }
  }

  @override
  void onWindowClose() {
    _ref.read(uiServiceProvider).onWindowClose();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  Future<void> onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case _showWindowKey:
        windowManager.show();
        windowManager.focus();
        break;
      case _exitKey:
        await _ref.read(uiServiceProvider).onExit();
        break;
    }
  }
}
