import 'package:again/services/audio/audio_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LineIndicator extends ConsumerWidget {
  const LineIndicator({
    super.key,
    required this.context,
    required this.position,
    required this.flashBack,
    required this.confirmPlay,
    required this.isPlaying,
  });

  final BuildContext context;
  final int position;
  final VoidCallback flashBack;
  final VoidCallback confirmPlay;
  final bool isPlaying;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    // 左图标区与右时间戳区等宽 (110), 使指示条内容整体居中,
    // 与歌词文本区 (列中心) 同轴对齐;
    // 指示条宽度为窗口宽的 55% (横线范围覆盖歌词文本区), 居中显示
    const sideWidth = 110.0;
    final indicatorWidth = MediaQuery.of(context).size.width * 0.55;
    return SizedBox(
      width: indicatorWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 左: 回到当前播放位置 (定位图标, 避免播放三角的"在此播放"歧义)
          SizedBox(
            width: sideWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: IconButton(
                onPressed: () {
                  flashBack.call();
                },
                tooltip: '回到当前播放位置',
                icon: Icon(
                  Icons.my_location,
                  color: scheme.primary,
                ),
                iconSize: 18,
                // 视觉紧凑但保留足够点击热区
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
          // 中: 主题色渐变引导线
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.05),
                    scheme.primary.withValues(alpha: 0.55),
                    scheme.primary.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          // 右: 可点击的时间戳 (下划线暗示可点击跳转)
          SizedBox(
            width: sideWidth,
            child: Tooltip(
              message: '点击跳转到此时间',
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(40, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  Duration(milliseconds: position).toString().split('.').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.primary.withValues(alpha: 0.9),
                    decoration: TextDecoration.underline,
                    decorationColor: scheme.primary.withValues(alpha: 0.35),
                    decorationThickness: 1,
                  ),
                ),
                onPressed: () {
                  ref
                      .read(audioProvider.notifier)
                      .seek(Duration(milliseconds: position));
                  confirmPlay.call();
                  if (!isPlaying) {
                    ref.read(audioProvider.notifier).resume();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
