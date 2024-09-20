import 'package:again/screens/player/components/play_back_controls.dart/loop_mode_button.dart';
import 'package:again/screens/player/components/play_back_controls.dart/next_button.dart';
import 'package:again/screens/player/components/play_back_controls.dart/play_pause_button.dart';
import 'package:again/screens/player/components/play_back_controls.dart/prev_button.dart';
import 'package:again/screens/player/components/play_back_controls.dart/show_lryic_button.dart';
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
          LoopModeButton(iconSize: _iconSize * 0.5),
        ],
      ),
    );
  }
}
