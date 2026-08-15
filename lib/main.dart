import 'dart:async';
import 'dart:io';

import 'package:again/pages/my_app.dart';
import 'package:again/services/audio/again_audio_handler.dart';
import 'package:again/services/window_setup.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await setupWindow();
      // Android: 后台播放/媒体通知/锁屏控制的前台服务 (仅初始化一次)
      if (Platform.isAndroid) {
        await AudioService.init(
          builder: () => againAudioHandler,
          config: const AudioServiceConfig(
            androidNotificationChannelId: 'com.zdl.again.audio',
            androidNotificationChannelName: 'Again 播放',
            androidNotificationOngoing: true,
          ),
        );
      }
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
