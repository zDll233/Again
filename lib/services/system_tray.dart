import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/log.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// 系统托盘: 关窗隐藏到托盘, 托盘菜单可显示窗口/音频控制/退出。
class SystemTrayListener with WindowListener, TrayListener {
  SystemTrayListener(this._ref);

  final Ref _ref;

  static const _showWindowKey = 'show_window';
  static const _playPauseKey = 'play_pause';
  static const _prevKey = 'prev';
  static const _nextKey = 'next';
  static const _exitKey = 'exit_app';

  static Future<void> init(Ref ref) async {
    try {
      final listener = SystemTrayListener(ref);
      windowManager.addListener(listener);
      trayManager.addListener(listener);

      await trayManager.setIcon('assets/images/app_icon.ico');
      await trayManager.setToolTip('Again');
      await _updateMenu(ref);
    } catch (e) {
      // 托盘初始化失败不阻塞启动, 仅影响托盘功能
      Log.error('Tray init failed.\n$e');
    }
  }

  static Future<void> _updateMenu(Ref ref) async {
    final isPlaying =
        ref.read(audioProvider).playerState == PlayerState.playing;
    await trayManager.setContextMenu(Menu(
      items: [
        MenuItem(key: _showWindowKey, label: '显示主窗口'),
        MenuItem.separator(),
        MenuItem(key: _playPauseKey, label: isPlaying ? '暂停' : '播放'),
        MenuItem(key: _prevKey, label: '上一首'),
        MenuItem(key: _nextKey, label: '下一首'),
        MenuItem.separator(),
        MenuItem(key: _exitKey, label: '退出'),
      ],
    ));
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
    // 右键弹出前刷新菜单, 保证播放/暂停文案与当前状态一致
    _updateMenu(_ref);
    trayManager.popUpContextMenu();
  }

  @override
  Future<void> onTrayMenuItemClick(MenuItem menuItem) async {
    switch (menuItem.key) {
      case _showWindowKey:
        windowManager.show();
        windowManager.focus();
        break;
      case _playPauseKey:
        _ref.read(audioProvider.notifier).switchPauseResume();
        break;
      case _prevKey:
        _ref.read(audioProvider.notifier).playPrev();
        break;
      case _nextKey:
        _ref.read(audioProvider.notifier).playNext();
        break;
      case _exitKey:
        await _ref.read(uiServiceProvider).onExit();
        break;
    }
  }
}
