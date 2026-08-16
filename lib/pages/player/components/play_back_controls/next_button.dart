import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NextButton extends ConsumerWidget {
  const NextButton({
    super.key,
    required this.iconSize,
    this.buttonSize = 48.0,
  });

  final double iconSize;
  final double buttonSize;

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
      padding: buttonSize < 48 ? EdgeInsets.zero : const EdgeInsets.all(2.5),
      constraints: BoxConstraints.tightFor(
        width: buttonSize,
        height: buttonSize,
      ),
    );
  }
}
