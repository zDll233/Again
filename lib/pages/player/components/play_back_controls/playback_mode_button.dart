import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaybackModeButton extends ConsumerWidget {
  const PlaybackModeButton({
    super.key,
    required this.iconSize,
    this.buttonSize = 48.0,
  });

  final double iconSize;
  final double buttonSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackMode =
        ref.watch(audioProvider.select((state) => state.playbackMode));
    final audioNotifier = ref.read(audioProvider.notifier);

    IconData icon;

    switch (playbackMode) {
      case PlaybackMode.sequentialPlay:
        icon = Icons.repeat;
        break;
      case PlaybackMode.singleRepeat:
        icon = Icons.repeat_one;
        break;
      case PlaybackMode.shufflePlay:
        icon = Icons.shuffle;
        break;
    }

    return IconButton(
      key: const Key('playback_mode_button'),
      onPressed: audioNotifier.onPlaybackModePressed,
      iconSize: iconSize,
      icon: Icon(icon),
      padding: buttonSize < 48 ? EdgeInsets.zero : null,
      constraints: BoxConstraints.tightFor(
        width: buttonSize,
        height: buttonSize,
      ),
    );
  }
}
