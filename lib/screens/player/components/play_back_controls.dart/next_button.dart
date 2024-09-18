import 'package:again/audio/audio_providers.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NextButton extends ConsumerWidget {
  const NextButton({
    required this.iconSize,
    super.key,
  });

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying =
        ref.watch(voiceItemProvider.select((state) => state.isPlaying));
    final audioNotifier = ref.read(audioProvider.notifier);
    return IconButton(
      key: const Key('next_button'),
      onPressed: isPlaying ? audioNotifier.playNext : null,
      iconSize: iconSize,
      icon: const Icon(Icons.skip_next),
      padding: const EdgeInsets.all(2.5),
    );
  }
}
