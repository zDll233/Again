import 'package:again/pages/player/components/play_back_controls/channel_swap_button.dart';
import 'package:again/pages/player/components/play_back_controls/next_button.dart';
import 'package:again/pages/player/components/play_back_controls/play_pause_button.dart';
import 'package:again/pages/player/components/play_back_controls/playback_mode_button.dart';
import 'package:again/pages/player/components/play_back_controls/prev_button.dart';
import 'package:again/pages/player/components/progress_bar.dart';
import 'package:again/pages/player/components/time_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 歌词界面底部控制区:
/// 进度条 + 时间 + 五个核心按钮 (播放顺序/上一曲/播放/下一曲/声道对调)。
/// 「打开音轨列表」按钮已上移到歌词标题行右侧 (见 lrc_panel.dart)。
const double lyricPanelControlsHeight = 120.0;

class LyricPanelControls extends ConsumerWidget {
  const LyricPanelControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 进度条: 细线轨道贴顶, 点击/拖动 seek
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ProgressBar(trackAtTop: true, compact: true),
        ),
        // 时间: 左当前 / 右总时长
        const SizedBox(
          height: 22,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                PositionTimeText(),
                Spacer(),
                DurationTimeText(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // 五个按钮放在同一排, 中间播放按钮用主题色强调。
        SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const PlaybackModeButton(iconSize: 22, buttonSize: 42),
              const PrevButton(iconSize: 30, buttonSize: 42),
              _buildPlayButton(context),
              const NextButton(iconSize: 30, buttonSize: 42),
              // 左右声道对调 (原「打开列表」按钮位置; 列表按钮已上移到标题行)
              const ChannelSwapButton(iconSize: 22, buttonSize: 42),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.30),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconTheme(
        data: IconThemeData(color: scheme.onPrimary),
        child: const PlayPauseButton(iconSize: 38, buttonSize: 56),
      ),
    );
  }
}
