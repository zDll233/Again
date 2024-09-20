import 'package:again/screens/player/components/play_back_controls.dart/playback_controls.dart';
import 'package:again/screens/player/components/progress_bar.dart';
import 'package:again/screens/player/components/time_display.dart';
import 'package:again/screens/player/components/volume_control.dart';
import 'package:again/screens/window_title_bar/move_window.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 100,
      child: Stack(
        children: [
          MoveWindow(),
          Positioned(
            top: 10,
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
