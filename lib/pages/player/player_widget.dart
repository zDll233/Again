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
    if (isNarrow) {
      // 窄屏: 跑道形悬浮胶囊 — 左右半圆 + 顶部直线段为进度条, 无时间文字;
      // 悬浮在列表/面板上方 (MyApp Stack 底部 overlay)
      const capsuleHeight = 88.0;
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
        child: Container(
          height: capsuleHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(capsuleHeight / 2),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: LiquidGlass(
            borderRadius: capsuleHeight / 2,
            tintAlpha: tint,
            // 上边界即进度条, 不再叠加玻璃亮边 (避免双线)
            showTopHighlight: false,
            child: content,
          ),
        ),
      );
    }
    return LiquidGlass(
      borderRadius: 0,
      tintAlpha: tint,
      // 移除顶部 1px 亮边: 进度条本身就是播放器的上边界
      showTopHighlight: false,
      child: content,
    );
  }

  /// 窄屏: 跑道胶囊 — 顶部直线段进度条 + 控制按钮行; 上滑/点击空白开歌词。
  Widget _buildNarrow(BuildContext context, WidgetRef ref) {
    void openLyric() =>
        ref.read(miscUIProvider.notifier).toggleShowLyricPanel();
    final screenHeight = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: openLyric,
      // 拖动直接驱动歌词面板位置 (跟手)
      onVerticalDragUpdate: (details) {
        ref.read(lyricPanelProgressProvider.notifier).state =
            (ref.read(lyricPanelProgressProvider) -
                    (details.primaryDelta ?? 0) / screenHeight)
                .clamp(0.0, 1.0);
      },
      onVerticalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        final p = ref.read(lyricPanelProgressProvider);
        // 高速上滑打开 / 高速下滑关闭 / 低速看位置
        final open = v < -300 ? true : (v > 300 ? false : p >= 0.35);
        final show = ref.read(miscUIProvider).showLyricPanel;
        if (open != show) {
          // 状态变化: toggle 触发 ListLyricSwitch 的动画
          ref.read(miscUIProvider.notifier).toggleShowLyricPanel();
        } else {
          // 状态一致: 直接请求动画回到目标
          ref.read(lyricPanelAnimateRequestProvider.notifier).state =
              open ? 1.0 : 0.0;
        }
      },
      child: Column(
        children: [
          // 顶部直线段 = 进度条 (无时间文字)
          const Padding(
            padding: EdgeInsets.only(left: 18, right: 18, top: 2),
            child: ProgressBar(trackAtTop: true),
          ),
          // 按钮组垂直居中
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: const PlaybackControls(),
            ),
          ),
        ],
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
