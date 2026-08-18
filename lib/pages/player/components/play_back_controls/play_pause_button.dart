import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayPauseButton extends ConsumerWidget {
  const PlayPauseButton({
    super.key,
    required this.iconSize,
    this.buttonSize = 48.0,
  });

  final double iconSize;
  final double buttonSize;

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
      icon: playerState == AudioPlaybackState.playing
          ? const Icon(Icons.pause)
          : const Icon(Icons.play_arrow),
      padding: buttonSize < 48 ? EdgeInsets.zero : const EdgeInsets.all(2.5),
      constraints: BoxConstraints.tightFor(
        width: buttonSize,
        height: buttonSize,
      ),
    );
  }
}
