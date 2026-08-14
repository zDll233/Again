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
    // 指示条整体宽 = 窗口宽 55%, 在歌词列内居中 (歌词列中心);
    // 左图标区 75px 不变, 横线填满剩余空间延伸到歌词右端,
    // 时间戳按钮与歌词之间留 8px 空隙
    const sideWidth = 75.0;
    final indicatorWidth = MediaQuery.of(context).size.width * 0.55;
    return Center(
      child: SizedBox(
        width: indicatorWidth,
        child: Row(
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
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ),
            ),
            // 中: 主题色渐变引导线 (延伸到歌词右端)
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
            // 右: 时间戳按钮 (与歌词之间留 8px 空隙)
            SizedBox(
              width: 88,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Tooltip(
                      message: '点击跳转到此时间',
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(40, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          Duration(milliseconds: position)
                              .toString()
                              .split('.')
                              .first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.primary.withValues(alpha: 0.9),
                            decoration: TextDecoration.underline,
                            decorationColor:
                                scheme.primary.withValues(alpha: 0.35),
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
            ),
          ],
        ),
      ),
    );
  }
}
