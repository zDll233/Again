import 'package:again/audio/audio_providers.dart';
import 'package:again/screens/components/rectangle_overlay_shape.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VolumeControl extends ConsumerWidget {
  const VolumeControl({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.watch(audioProvider.notifier);
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final scrollDelta = pointerSignal.scrollDelta.dy;
          final volume = ref.read(audioProvider).volume;
          if (scrollDelta > 0) {
            audioNotifier.setVolume((volume - 0.1).clamp(0.0, 1.0));
          } else if (scrollDelta < 0) {
            audioNotifier.setVolume((volume + 0.1).clamp(0.0, 1.0));
          }
        }
      },
      child: SizedBox(
        width: 150,
        child: Row(
          children: [
            Consumer(
              builder: (_, WidgetRef ref, __) {
                final volume =
                    ref.watch(audioProvider.select((state) => state.volume));
                return IconButton(
                  onPressed: audioNotifier.onMutePressed,
                  icon: volume == 0
                      ? const Icon(Icons.volume_off)
                      : const Icon(Icons.volume_up),
                );
              },
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    trackHeight: 1.0,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 0.0),
                    overlayShape: RectangleOverlayShape(
                        shapeSize: const Size(10.0, 40.0)),
                    overlayColor: Colors.transparent),
                child: Consumer(
                  builder: (_, WidgetRef ref, __) {
                    final volume = ref
                        .watch(audioProvider.select((state) => state.volume));
                    return Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (double value) {
                        audioNotifier.setVolume(value);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
