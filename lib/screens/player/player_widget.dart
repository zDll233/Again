import 'package:again/audio/audio_notifier.dart';
import 'package:again/audio/audio_providers.dart';
import 'package:again/screens/player/components/play_back_controls.dart/playback_controls.dart';
import 'package:again/screens/player/components/progress_bar.dart';
import 'package:again/screens/player/components/time_display.dart';
import 'package:again/screens/player/components/volume_control.dart';
import 'package:again/screens/window_title_bar/move_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerWidget extends ConsumerStatefulWidget {
  const PlayerWidget({
    super.key,
  });

  @override
  ConsumerState<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends ConsumerState<PlayerWidget> {
  late final AudioNotifier audioNotifier;
  @override
  void initState() {
    audioNotifier = ref.read(audioProvider.notifier);
    super.initState();
  }

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
