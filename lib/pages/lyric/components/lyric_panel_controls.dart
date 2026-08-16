import 'package:again/pages/player/components/play_back_controls/next_button.dart';
import 'package:again/pages/player/components/play_back_controls/play_pause_button.dart';
import 'package:again/pages/player/components/play_back_controls/playback_mode_button.dart';
import 'package:again/pages/player/components/play_back_controls/prev_button.dart';
import 'package:again/pages/player/components/progress_bar.dart';
import 'package:again/pages/player/components/time_display.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 歌词界面底部控制区 (参考主流播放器歌词页):
/// 细线进度条 + 时间 (左当前/右总时长) + 控制行
/// (左: 播放顺序切换, 中: 上一曲/播放/下一曲, 右: 队列列表)。
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
        // 控制行: 模式切换 (左) + 三按钮等距居中 (播放大) + 队列 (右)
        SizedBox(
          height: 64,
          child: Row(
            children: [
              const SizedBox(width: 12),
              const PlaybackModeButton(iconSize: 26),
              const Spacer(),
              const PrevButton(iconSize: 34),
              const SizedBox(width: 14),
              const PlayPauseButton(iconSize: 46),
              const SizedBox(width: 14),
              const NextButton(iconSize: 34),
              const Spacer(),
              // 队列: 切到音轨列表
              IconButton(
                key: const Key('queue_button'),
                tooltip: '队列',
                iconSize: 26,
                onPressed: () {
                  ref.read(miscUIProvider.notifier).toggleShowLyricPanel();
                  ref.read(listsPanelPageProvider.notifier).state = 1;
                },
                icon: const Icon(Icons.queue_music),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }
}
