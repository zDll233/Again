import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/pages/components/liquid_glass.dart';
import 'package:again/pages/player/components/play_back_controls/playback_controls.dart';
import 'package:again/pages/player/components/progress_bar.dart';
import 'package:again/pages/player/components/time_display.dart';
import 'package:again/pages/player/components/volume_control.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class PlayerWidget extends ConsumerWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effect =
        ref.watch(windowEffectProvider).valueOrNull ?? WINDOW_EFFECT_ACRYLIC;
    // 三种模式统一用 LiquidGlass, 毛玻璃更透, 其他模式着色更深。
    final tint = effect == WINDOW_EFFECT_ACRYLIC ? 0.14 : 0.25;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    final Widget content;
    if (isNarrow) {
      content = _buildNarrow(context, ref);
    } else {
      content = _buildWide(context);
    }
    return LiquidGlass(
      borderRadius: 0,
      tintAlpha: tint,
      // 移除顶部 1px 亮边: 进度条本身就是播放器的上边界
      showTopHighlight: false,
      child: content,
    );
  }

  /// 窄屏: 上滑/点击空白打开歌词; 布局 = 进度条 + 时间行 + 按钮行。
  Widget _buildNarrow(BuildContext context, WidgetRef ref) {
    void openLyric() =>
        ref.read(miscUIProvider.notifier).toggleShowLyricPanel();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: openLyric,
      onVerticalDragEnd: (details) {
        // 上滑打开歌词
        if ((details.primaryVelocity ?? 0) < -300) {
          openLyric();
        }
      },
      child: SizedBox(
        // 窄屏高度加大: 进度条(40) + 时间行 + 按钮行, 90 放不下会溢出裁切
        height: PLAYER_WIDGET_HEIGHT + 20,
        child: Column(
          children: [
            const ProgressBar(),
            // 进度文字贴近进度条: 当前时间左 / 总时长右
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  PositionTimeText(),
                  Spacer(),
                  DurationTimeText(),
                ],
              ),
            ),
            // 按钮组贴底但留出底边距
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: const PlaybackControls(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWide(BuildContext context) {
    return SizedBox(
      height: PLAYER_WIDGET_HEIGHT,
      child: Stack(
        children: [
          // 空白区域拖动窗口 (Windows 专属): DragToMoveArea 放最底层,
          // 控件命中优先; 若包住整个播放器, 其内部 onDoubleTap 会拖慢
          // 所有按钮的单击响应
          if (Platform.isWindows)
            Positioned.fill(
              child: DragToMoveArea(child: Container()),
            ),
          const Positioned(
            child: ProgressBar(),
          ),
          const Positioned(
            left: 20,
            bottom: 25,
            child: TimeDisplay(),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 5,
            child: PlaybackControls(),
          ),
          Positioned(
            right: 10,
            bottom: 15,
            child: VolumeControl(),
          ),
        ],
      ),
    );
  }
}
