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
