import 'package:again/pages/player/components/play_back_controls/cover_lyric_button.dart';
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
      // 窄屏: 封面缩略图按钮 (开歌词) + 紧凑居中的控制按钮组;
      // 无音量按钮 (移动端用系统音量键)
      return SizedBox(
        height: 60.0,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CoverLyricButton(size: 34),
            SizedBox(width: 18),
            PrevButton(iconSize: 32),
            SizedBox(width: 10),
            PlayPauseButton(iconSize: 38),
            SizedBox(width: 10),
            NextButton(iconSize: 32),
            SizedBox(width: 18),
            PlaybackModeButton(iconSize: 26),
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
