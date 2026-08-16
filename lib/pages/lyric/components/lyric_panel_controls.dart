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
/// 主控制行 (上一曲/播放/下一曲 等距居中, 播放大) +
/// 底部功能行 (播放顺序切换 / 队列列表, 小按钮居中分布)。
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
        // 主控制行: 三按钮等距居中, 大小一致 (参考播放器)
        SizedBox(
          height: 58,
          child: const Row(
            children: [
              Spacer(),
              PrevButton(iconSize: 38),
              SizedBox(width: 48),
              PlayPauseButton(iconSize: 38),
              SizedBox(width: 48),
              NextButton(iconSize: 38),
              Spacer(),
            ],
          ),
        ),
        // 底部功能行: 播放顺序切换 / 队列 (小按钮居中分布)
        SizedBox(
          height: 46,
          child: Row(
            children: [
              const Spacer(),
              const PlaybackModeButton(iconSize: 22),
              const Spacer(),
              // 队列: 切到音轨列表
              IconButton(
                key: const Key('queue_button'),
                tooltip: '队列',
                iconSize: 22,
                padding: const EdgeInsets.all(4),
                onPressed: () {
                  ref.read(miscUIProvider.notifier).toggleShowLyricPanel();
                  ref.read(listsPanelPageProvider.notifier).state = 1;
                },
                icon: const Icon(Icons.queue_music),
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}
