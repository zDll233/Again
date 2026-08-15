import 'dart:async';

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
