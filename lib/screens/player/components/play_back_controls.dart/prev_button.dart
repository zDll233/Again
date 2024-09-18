import 'package:again/audio/audio_providers.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrevButton extends ConsumerWidget {
  const PrevButton({
    super.key,
    required this.iconSize,
  });

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying =
        ref.watch(voiceItemProvider.select((state) => state.isPlaying));
    final audioNotifier = ref.read(audioProvider.notifier);
    return IconButton(
      key: const Key('prev_button'),
      onPressed: isPlaying ? audioNotifier.playPrev : null,
      iconSize: iconSize,
      icon: const Icon(Icons.skip_previous),
      padding: const EdgeInsets.all(2.5),
    );
  }
}
