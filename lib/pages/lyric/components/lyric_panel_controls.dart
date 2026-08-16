import 'package:again/pages/player/components/play_back_controls/next_button.dart';
import 'package:again/pages/player/components/play_back_controls/play_pause_button.dart';
import 'package:again/pages/player/components/play_back_controls/playback_mode_button.dart';
import 'package:again/pages/player/components/play_back_controls/prev_button.dart';
import 'package:again/pages/player/components/progress_bar.dart';
import 'package:again/pages/player/components/time_display.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 歌词界面底部控制区 (1:1 复刻参考播放器):
/// 歌词来源行 (词/文A) + 细线进度条 + 时间 (左当前/右总时长) +
/// 主控制行 (上一曲/播放/下一曲 等距, 大小一致) +
/// 底部功能行 (播放顺序切换 / 队列, 小图标居中分布)。
class LyricPanelControls extends ConsumerWidget {
  const LyricPanelControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 歌词来源行: 左侧「词 EMBEDDED」标签, 右侧「文A」翻译按钮 (参考布局)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _smallTag('词', 'EMBEDDED', scheme),
              const Spacer(),
              _smallTag('文A', null, scheme),
            ],
          ),
        ),
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
        // 主控制行: 三按钮等距居中, 大小一致 (参考布局, 高度紧凑)
        SizedBox(
          height: 48,
          child: const Row(
            children: [
              Spacer(),
              PrevButton(iconSize: 36),
              SizedBox(width: 44),
              PlayPauseButton(iconSize: 36),
              SizedBox(width: 44),
              NextButton(iconSize: 36),
              Spacer(),
            ],
          ),
        ),
        // 底部功能行: 播放顺序切换 / 队列 (小按钮居中分布)
        SizedBox(
          height: 36,
          child: Row(
            children: [
              const Spacer(),
              const PlaybackModeButton(iconSize: 20),
              const Spacer(),
              // 队列: 切到音轨列表
              IconButton(
                key: const Key('queue_button'),
                tooltip: '队列',
                iconSize: 20,
                padding: const EdgeInsets.all(3),
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

  /// 参考样式的小标签 (圆角小框 + 文字)。
  Widget _smallTag(String text, String? sub, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.onSurface.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (sub != null) ...[
            const SizedBox(width: 4),
            Text(
              sub,
              style: TextStyle(
                fontSize: 10,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
