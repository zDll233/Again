import 'package:again/pages/lists/lists_view.dart';
import 'package:again/pages/lyric/lrc_panel.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 列表/歌词切换:
/// - 宽屏 (桌面): 淡入淡出切换 (本组件内完成);
/// - 窄屏: 仅返回列表, 歌词面板由 LyricPanelOverlay 在 MyApp Stack
///   最顶层滑入 (保证上划时面板盖住悬浮播放器)。
class ListLyricSwitch extends ConsumerWidget {
  const ListLyricSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final showLyricPanel =
        ref.watch(miscUIProvider.select((state) => state.showLyricPanel));

    if (isNarrow) {
      return const ListsView();
    }

    // 宽屏 (桌面): 淡入淡出切换
    // 注意: 本组件在 MyApp 的 Column 中, 必须自身返回 Expanded 撑满剩余空间
    return Expanded(
      child: Stack(
        children: [
          AnimatedOpacity(
            opacity: showLyricPanel ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Offstage(
              offstage: showLyricPanel,
              child: const ListsView(),
            ),
          ),
          AnimatedOpacity(
            opacity: showLyricPanel ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Visibility(
              visible: showLyricPanel,
              child: const LyricPanel(),
            ),
          )
        ],
      ),
    );
  }
}
