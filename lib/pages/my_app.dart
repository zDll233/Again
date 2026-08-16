import 'dart:io';
import 'dart:ui';
import 'package:again/pages/components/initialization.dart';
import 'package:again/pages/components/list_lyric_switch.dart';
import 'package:again/pages/player/player_widget.dart';
import 'package:again/pages/window_title_bar/move_window.dart';
import 'package:again/pages/window_title_bar/window_title_bar.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 视觉验证/截图用: --dart-define=OPAQUE_BG=true 时给窗口不透明深色背景。
const bool _opaqueBackground = bool.fromEnvironment('OPAQUE_BG');

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    // Android: 深色背景上状态栏用浅色图标
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    }
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    // 歌词面板打开时: 胶囊隐藏 + 内容区铺满 (歌词界面自带完整控制区)
    final showLyric =
        ref.watch(miscUIProvider.select((state) => state.showLyricPanel));
    return Initialization(
      child: ColoredBox(
        // 透明窗口仅 Windows 支持; Android 等平台恒用不透明深色背景
        color: (_opaqueBackground || !Platform.isWindows)
            ? const Color(0xFF202024)
            : Colors.transparent,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          scrollBehavior: MyCustomScrollBehavior(),
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: MoveWindow(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const WindowTitleBar(),
                        // 窄屏: 底部留出悬浮播放器空间 (歌词打开时铺满)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: isNarrow && !showLyric ? 120 : 0),
                            child: const ListLyricSwitch(),
                          ),
                        ),
                      ],
                    ),
                    // 悬浮播放器: 窄屏跑道胶囊 (内部自带左右留白),
                    // 桌面版保持贴底全宽; 歌词界面打开时隐藏 (自带控制区)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: isNarrow ? 12 : 0,
                      child: isNarrow && showLyric
                          ? const SizedBox.shrink()
                          : const PlayerWidget(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        // default
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        // enable mouse && trackpad
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad
      };
}
