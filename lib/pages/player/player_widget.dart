import 'package:again/common/const.dart';
import 'package:again/pages/components/liquid_glass.dart';
import 'package:again/pages/player/components/play_back_controls/playback_controls.dart';
import 'package:again/pages/player/components/progress_bar.dart';
import 'package:again/pages/player/components/time_display.dart';
import 'package:again/pages/player/components/volume_control.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
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
    final content = SizedBox(
      height: PLAYER_WIDGET_HEIGHT,
      child: Stack(
        children: [
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
    // LiquidGlass 背景会拦截命中, 导致底层 MoveWindow 的拖动区收不到事件,
    // 这里给播放器自身包一层 DragToMoveArea: 按钮/进度条有自己的手势优先,
    // 空白区域可拖动窗口
    return DragToMoveArea(
      child: LiquidGlass(
        borderRadius: 0,
        tintAlpha: tint,
        child: content,
      ),
    );
  }
}
