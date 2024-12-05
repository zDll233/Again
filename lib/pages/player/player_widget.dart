import 'package:again/common/const.dart';
import 'package:again/pages/player/components/play_back_controls.dart/playback_controls.dart';
import 'package:again/pages/player/components/progress_bar.dart';
import 'package:again/pages/player/components/time_display.dart';
import 'package:again/pages/player/components/volume_control.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: PLAYER_WIDGET_HEIGHT,
      child: Stack(
        children: [
          Positioned(
            child: ProgressBar(),
          ),
          Positioned(
            left: 20,
            bottom: 25,
            child: TimeDisplay(),
          ),
          Positioned(
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
  }
}
