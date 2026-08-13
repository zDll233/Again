import 'package:again/common/const.dart';
import 'package:again/pages/player/components/play_back_controls/playback_controls.dart';
import 'package:again/pages/player/components/progress_bar.dart';
import 'package:again/pages/player/components/time_display.dart';
import 'package:again/pages/player/components/volume_control.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.25),
        border: Border(
          top: BorderSide(color: scheme.onSurface.withValues(alpha: 0.06)),
        ),
      ),
      child: SizedBox(
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
      ),
    );
  }
}
