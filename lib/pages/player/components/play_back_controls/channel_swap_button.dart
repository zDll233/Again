import 'package:again/services/audio/audio_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 左右声道对调按钮 (ASMR 里作品录反时用)。
///
/// 点击后立即生效: 播放不中断、进度不变, 由原生播放引擎在 PCM 层交换
/// 左右声道; 开关状态写入 config.json, 切歌/重启后保持。
class ChannelSwapButton extends ConsumerWidget {
  const ChannelSwapButton({
    super.key,
    required this.iconSize,
    this.buttonSize = 48.0,
  });

  final double iconSize;
  final double buttonSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swapped =
        ref.watch(audioProvider.select((state) => state.channelSwap));
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      key: const Key('channel_swap_button'),
      tooltip: swapped ? '取消对调左右声道' : '对调左右声道',
      onPressed: ref.read(audioProvider.notifier).toggleChannelSwap,
      iconSize: iconSize,
      padding: buttonSize < 48 ? EdgeInsets.zero : null,
      constraints: BoxConstraints.tightFor(
        width: buttonSize,
        height: buttonSize,
      ),
      color: swapped ? scheme.primary : null,
      icon: Icon(swapped ? Icons.swap_horiz_rounded : Icons.swap_horiz),
    );
  }
}
