import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:again/common/const.dart';
import 'package:again/pages/components/liquid_glass.dart';
import 'package:again/pages/player/components/play_back_controls/cover_lyric_button.dart';
import 'package:again/pages/player/components/play_back_controls/next_button.dart';
import 'package:again/pages/player/components/play_back_controls/play_pause_button.dart';
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
      // 窄屏: 悬浮迷你播放器胶囊 — 封面、曲目信息和控制按钮分区排列;
      // 用左侧浅色背景填充表达进度, 不再额外绘制进度线。
      const capsuleHeight = 76.0;
      final screenW = MediaQuery.sizeOf(context).width;
      final capsuleWidth = math.max(screenW - 24.0, 0.0);
      final duration =
          ref.watch(audioProvider.select((state) => state.duration));
      final position =
          ref.watch(audioProvider.select((state) => state.position));
      final progress = (duration == Duration.zero || position == Duration.zero)
          ? 0.0
          : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: SizedBox(
          width: capsuleWidth,
          height: capsuleHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(capsuleHeight / 2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.48),
                  blurRadius: 26,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(capsuleHeight / 2),
              child: Stack(
                children: [
                  // 亚克力毛玻璃底: 模糊下方列表内容 + 渐变着色。
                  // Windows 透明窗口不用此分支, 移动端背景可直接模糊。
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              scheme.surface.withValues(alpha: 0.78),
                              scheme.surfaceContainerHighest
                                  .withValues(alpha: 0.48),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 进度背景: 浅色半透明填充从左向右增长, 不干扰控件层次。
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.22),
                              scheme.primary.withValues(alpha: 0.16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 顶部亮边增加胶囊的层次感。
                  Positioned(
                    top: 0,
                    left: 24,
                    right: 24,
                    child: IgnorePointer(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.04),
                              Colors.white.withValues(alpha: 0.40),
                              Colors.white.withValues(alpha: 0.04),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
      // 左侧封面和曲目信息, 右侧保持固定宽度的核心控制组;
      // 小按钮显式收紧, 避免 IconButton 默认最小尺寸挤压标题。
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: const ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: CoverLyricButton(size: 48),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: _NarrowPlayerInfo()),
          const SizedBox(width: 4),
          IconTheme(
            data: IconThemeData(
              color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.78,
                  ),
            ),
            child: const PrevButton(iconSize: 20, buttonSize: 32),
          ),
          const SizedBox(width: 2),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.32),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconTheme(
              data: IconThemeData(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const PlayPauseButton(iconSize: 25, buttonSize: 42),
            ),
          ),
          const SizedBox(width: 2),
          IconTheme(
            data: IconThemeData(
              color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.78,
                  ),
            ),
            child: const NextButton(iconSize: 20, buttonSize: 32),
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

/// 窄屏胶囊中的曲目信息, 在切换音轨时用淡入淡出避免文字突然跳变。
class _NarrowPlayerInfo extends ConsumerWidget {
  const _NarrowPlayerInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item =
        ref.watch(voiceItemProvider.select((state) => state.cachedPlayingItem));
    final work =
        ref.watch(voiceWorkProvider.select((state) => state.cachedPlayingItem));
    final title = item?.title.isNotEmpty == true ? item!.title : '未播放音轨';
    final subtitle = work?.title.isNotEmpty == true ? work!.title : '点击封面打开歌词';
    final scheme = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.centerLeft,
        children: [
          ...previousChildren,
          if (currentChild != null) currentChild,
        ],
      ),
      child: Column(
        key: ValueKey('$title\n$subtitle'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface.withValues(alpha: 0.92),
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.56),
                ),
          ),
        ],
      ),
    );
  }
}
