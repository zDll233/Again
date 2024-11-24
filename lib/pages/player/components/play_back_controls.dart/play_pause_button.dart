import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayPauseButton extends ConsumerWidget {
  const PlayPauseButton({
    super.key,
    required this.iconSize,
  });

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState =
        ref.watch(audioProvider.select((state) => state.playerState));
    final isPlaying =
        ref.watch(voiceItemProvider.select((state) => state.isPlaying));
    final audioNotifier = ref.read(audioProvider.notifier);
    return IconButton(
      key: const Key('play_pause_button'),
      onPressed: isPlaying ? audioNotifier.switchPauseResume : null,
      iconSize: iconSize,
      icon: playerState == PlayerState.playing
          ? const Icon(Icons.pause)
          : const Icon(Icons.play_arrow),
      padding: const EdgeInsets.all(2.5),
    );
  }
}
