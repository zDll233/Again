import 'dart:async';
import 'dart:io';

import 'package:again/common/paths.dart';
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
      // 窗口显示前应用配置的窗口背景效果
      final config = await JsonStorage(filePath: await configFilePath()).read();
      final effect = resolveWindowEffect(config);
      await applyWindowEffectStandalone(effect);
      windowManager.show();
      // DWM 在窗口可见并首次绘制后才真正合成 backdrop (SYSTEMBACKDROP_TYPE),
      // 显示后立即重设一次, 消除启动时几十 ms 的延迟
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        applyWindowEffectStandalone(effect);
      });
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
