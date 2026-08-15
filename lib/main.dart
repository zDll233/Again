import 'dart:async';
import 'dart:io';

import 'package:again/pages/my_app.dart';
import 'package:again/services/window_setup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await setupWindow();
      // MCP 调试工具链 (flutter-mcp-toolkit), 仅 Windows debug 构建生效;
      // release 构建启用会导致窗口启动即最小化; Android 上疑会阻塞首帧。
      // AudioService.init 移到首帧渲染后 (initialization.dart) —
      // runApp 前初始化 audio_service 会使 FlutterView 尺寸停在 0x0 (真机黑屏)。
      if (kDebugMode && Platform.isWindows) {
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
