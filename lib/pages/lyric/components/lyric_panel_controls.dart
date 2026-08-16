import 'package:again/pages/player/components/play_back_controls/next_button.dart';
import 'package:again/pages/player/components/play_back_controls/play_pause_button.dart';
import 'package:again/pages/player/components/play_back_controls/playback_mode_button.dart';
import 'package:again/pages/player/components/play_back_controls/prev_button.dart';
import 'package:again/pages/player/components/progress_bar.dart';
import 'package:again/pages/player/components/time_display.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 歌词界面底部控制区 (复刻主流播放器歌词页布局):
/// 细线进度条 + 时间 (左当前/右总时长) +
/// 单排控制按钮 (播放顺序 / 上一曲/播放/下一曲紧凑排列 / 队列)。
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
          child: ProgressBar(trackAtTop: true),
        ),
        // 时间: 左当前 / 右总时长
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              PositionTimeText(),
              Spacer(),
              DurationTimeText(),
            ],
          ),
        ),
        // 单排控制按钮: 播放顺序 (左) + 三按钮紧凑 (中) + 队列 (右)
        SizedBox(
          height: 58,
          child: Row(
            children: [
              const SizedBox(width: 24),
              const PlaybackModeButton(iconSize: 24),
              const Spacer(),
              const PrevButton(iconSize: 32),
              const SizedBox(width: 12),
              const PlayPauseButton(iconSize: 38),
              const SizedBox(width: 12),
              const NextButton(iconSize: 32),
              const Spacer(),
              // 队列: 切到音轨列表
              IconButton(
                key: const Key('queue_button'),
                tooltip: '队列',
                iconSize: 24,
                padding: const EdgeInsets.all(4),
                onPressed: () {
                  ref.read(miscUIProvider.notifier).toggleShowLyricPanel();
                  ref.read(listsPanelPageProvider.notifier).state = 1;
                },
                icon: const Icon(Icons.queue_music),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
      ],
    );
  }
}
