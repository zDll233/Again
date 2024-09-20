import 'package:again/audio/audio_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeDisplay extends ConsumerWidget {
  const TimeDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(audioProvider.select((state) => state.duration));
    final position = ref.watch(audioProvider.select((state) => state.position));
    return Align(
      alignment: Alignment.center,
      child: Text(
        getTimeDisplayText(position, duration),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

String getTimeDisplayText(Duration position, Duration duration) {
  if (position != Duration.zero) {
    return '${position.toString().split('.').first} / ${duration.toString().split('.').first}';
  } else if (duration != Duration.zero) {
    return duration.toString().split('.').first;
  } else {
    return '';
  }
}
