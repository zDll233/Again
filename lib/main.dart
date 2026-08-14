import 'dart:async';
import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/pages/my_app.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_service.dart';
import 'package:again/utils/json_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:window_manager/window_manager.dart';

/// 视觉验证/截图用: 构建时传 --dart-define=OPAQUE_BG=true 得到不透明背景窗口。
const bool _opaqueBackground = bool.fromEnvironment('OPAQUE_BG');

Future<void> setupWindow() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    // for window acrylic, mica or transparency effects
    await Window.initialize();
    if (!_opaqueBackground) {
      Window.setEffect(
        effect: WindowEffect.transparent,
        color: const Color(0xCC222222),
      );
    }

    const initialSize = Size(1040, 690);
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: initialSize,
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      windowManager
        ..setMinimumSize(initialSize)
        ..setTitle('Again')
        ..setPreventClose(true);
      // 窗口显示前应用配置的窗口背景效果, 启动即生效 (无透明→亚克力闪变)
      final config = await JsonStorage(filePath: CONFIG_FILE_PATH).read();
      await applyWindowEffectStandalone(resolveWindowEffect(config));
      windowManager.show();
    });
  }
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await setupWindow();
      // MCP 调试工具链 (flutter-mcp-toolkit), 仅 debug 构建生效;
      // release 构建启用会导致窗口启动即最小化。
      if (kDebugMode) {
        MCPToolkitBinding.instance
          ..initialize()
          ..initializeFlutterToolkit();
      }
      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) => kDebugMode
        ? MCPToolkitBinding.instance.handleZoneError(error, stack)
        : throw error,
  );
}
