import 'dart:io';

import 'package:again/common/const.dart';
import 'package:again/pages/components/liquid_glass.dart';
import 'package:again/pages/player/components/play_back_controls/cover_lyric_button.dart';
import 'package:again/pages/player/components/play_back_controls/next_button.dart';
import 'package:again/pages/player/components/play_back_controls/play_pause_button.dart';
import 'package:again/pages/player/components/play_back_controls/playback_mode_button.dart';
import 'package:again/pages/player/components/play_back_controls/playback_controls.dart';
import 'package:again/pages/player/components/play_back_controls/prev_button.dart';
import 'package:again/pages/player/components/progress_bar.dart';
import 'package:again/pages/player/components/time_display.dart';
import 'package:again/pages/player/components/volume_control.dart';
import 'package:again/services/audio/audio_providers.dart';
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
      // 窄屏: 跑道形悬浮胶囊 — 整体即进度条 (从左到右颜色填充),
      // 缩略图 + 控制按钮居中; 悬浮在列表/面板上方 (MyApp Stack 底部 overlay)
      const capsuleHeight = 64.0;
      final duration =
          ref.watch(audioProvider.select((state) => state.duration));
      final position =
          ref.watch(audioProvider.select((state) => state.position));
      final progress = (duration == Duration.zero || position == Duration.zero)
          ? 0.0
          : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
      final scheme = Theme.of(context).colorScheme;
      return Center(
        // Stack 在有界约束下会撑满全宽, 用 UnconstrainedBox 解除宽度约束
        // (胶囊宽度由内容决定), Center 负责水平居中
        child: UnconstrainedBox(
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(capsuleHeight / 2),
              // 宽度由内容决定 (Stack 默认 loose, 不撑满), 胶囊收缩包住内容
              child: Stack(
                children: [
                  // 进度填充: 从左到右 (底层)
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: ColoredBox(
                        color: scheme.primary.withValues(alpha: 0.38),
                      ),
                    ),
                  ),
                  // 毛玻璃着色 (盖在进度上, 半透明透出)
                  Positioned.fill(
                    child: ColoredBox(
                      color: scheme.surface.withValues(alpha: tint),
                    ),
                  ),
                  // 内容居中: 缩略图 (panel 缩略图 60 的 2/3 = 40) + 控制按钮
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: content,
                    ),
                  ),
                ],
              ),
            ),
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

  /// 窄屏: 胶囊内一行 — 缩略图 + 控制按钮; 上滑/点击空白开歌词。
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
      // 缩略图 (panel 缩略图 60 的 2/3) + 控制按钮, 水平居中;
      // 按钮用 SizedBox 收紧 (IconButton 默认 48px 最小尺寸会撑开胶囊)
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CoverLyricButton(size: 40),
          const SizedBox(width: 10),
          const SizedBox(
            width: 30,
            height: 30,
            child: PrevButton(iconSize: 22),
          ),
          const SizedBox(width: 4),
          const SizedBox(
            width: 40,
            height: 40,
            child: PlayPauseButton(iconSize: 32),
          ),
          const SizedBox(width: 4),
          const SizedBox(
            width: 30,
            height: 30,
            child: NextButton(iconSize: 22),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 28,
            height: 28,
            child: PlaybackModeButton(iconSize: 20),
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
