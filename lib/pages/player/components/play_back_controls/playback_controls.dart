import 'package:again/pages/player/components/play_back_controls/playback_mode_button.dart';
import 'package:again/pages/player/components/play_back_controls/next_button.dart';
import 'package:again/pages/player/components/play_back_controls/play_pause_button.dart';
import 'package:again/pages/player/components/play_back_controls/prev_button.dart';
import 'package:again/pages/player/components/play_back_controls/show_lryic_button.dart';
import 'package:flutter/material.dart';

const double _iconSize = 40.0;

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    if (isNarrow) {
      // 窄屏: 按钮 Expanded 均分整行, 避免挤压堆叠;
      // 无音量按钮 (移动端用系统音量键)
      return SizedBox(
        height: 60.0,
        child: const Row(
          children: [
            Expanded(child: Center(child: ShowLryicButton(iconSize: 24))),
            Expanded(child: Center(child: PrevButton(iconSize: 34))),
            Expanded(child: Center(child: PlayPauseButton(iconSize: 40))),
            Expanded(child: Center(child: NextButton(iconSize: 34))),
            Expanded(child: Center(child: PlaybackModeButton(iconSize: 24))),
          ],
        ),
      );
    }
    return Container(
      height: 60.0,
      alignment: Alignment.center,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShowLryicButton(iconSize: _iconSize * 0.5),
          PrevButton(iconSize: _iconSize),
          PlayPauseButton(iconSize: _iconSize),
          NextButton(iconSize: _iconSize),
          PlaybackModeButton(iconSize: _iconSize * 0.5),
        ],
      ),
    );
  }
}
