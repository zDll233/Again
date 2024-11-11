import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaybackModeButton extends ConsumerWidget {
  const PlaybackModeButton({
    super.key,
    required this.iconSize,
  });

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackMode = ref.watch(audioProvider.select((state) => state.playbackMode));
    final audioNotifier = ref.read(audioProvider.notifier);

    return IconButton(
      key: const Key('playback_mode_button'),
      onPressed: audioNotifier.onPlaybackModePressed,
      iconSize: iconSize,
      icon: playbackMode == PlaybackMode.sequentialPlay
          ? const Icon(Icons.repeat)
          : const Icon(Icons.repeat_one),
    );
  }
}
