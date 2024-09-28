import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/audio/audio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoopModeButton extends ConsumerWidget {
  const LoopModeButton({
    super.key,
    required this.iconSize,
  });

  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loopMode = ref.watch(audioProvider.select((state) => state.loopMode));
    final audioNotifier = ref.read(audioProvider.notifier);

    return IconButton(
      key: const Key('loop_mode'),
      onPressed: audioNotifier.onLoopModePressed,
      iconSize: iconSize,
      icon: loopMode == LoopMode.allLoop
          ? const Icon(Icons.repeat)
          : const Icon(Icons.repeat_one),
    );
  }
}
