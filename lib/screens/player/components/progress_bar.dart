import 'package:again/audio/audio_providers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressBar extends ConsumerWidget {
  const ProgressBar({super.key});

  double _getProgressBarValue(Duration position, Duration duration) {
    if (position != Duration.zero &&
        duration != Duration.zero &&
        position.inMilliseconds > 0 &&
        position.inMilliseconds < duration.inMilliseconds) {
      return position.inMilliseconds / duration.inMilliseconds;
    } else {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.read(audioProvider.notifier);
    final appWidth = MediaQuery.of(context).size.width;
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final scrollDelta = pointerSignal.scrollDelta.dy;
          int ms = 0;
          if (scrollDelta > 0) {
            ms = -10000;
          } else if (scrollDelta < 0) {
            ms = 10000;
          }
          audioNotifier.seek(Duration(
              milliseconds:
                  ref.read(audioProvider).position.inMilliseconds + ms));
        }
      },
      child: SizedBox(
        height: 40,
        width: appWidth,
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 1.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 0.0),
          ),
          child: Consumer(
            builder: (_, WidgetRef ref, __) {
              final duration =
                  ref.watch(audioProvider.select((state) => state.duration));
              final position =
                  ref.watch(audioProvider.select((state) => state.position));

              return Slider(
                focusNode: FocusNode(canRequestFocus: false),
                onChanged: (value) {
                  if (duration != Duration.zero) {
                    final position = value * duration.inMilliseconds;
                    audioNotifier
                        .seek(Duration(milliseconds: position.round()));
                  }
                },
                value: _getProgressBarValue(position, duration),
              );
            },
          ),
        ),
      ),
    );
  }
}
