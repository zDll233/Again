import 'package:again/pages/player/components/slider_thumb_shape.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VolumeControl extends ConsumerWidget {
  const VolumeControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioNotifier = ref.watch(audioProvider.notifier);
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          final scrollDelta = pointerSignal.scrollDelta.dy;
          final volume = ref.read(audioProvider).volume;
          double volumeStep = 0.05;
          if (scrollDelta > 0) {
              volumeStep = -volumeStep;
          }
          audioNotifier.setVolume((volume + volumeStep).clamp(0.0, 1.0));
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
              child: Consumer(
                builder: (_, WidgetRef ref, __) {
                  final volume =
                      ref.watch(audioProvider.select((state) => state.volume));
                  final appearance =
                      ref.watch(uiSettingsProvider).valueOrNull;
                  final showThumb = appearance?.showSliderThumb ?? true;
                  final thickness = appearance?.sliderThickness ?? 4;
                  return SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: showThumb ? null : const NoThumbShape(),
                      overlayShape: showThumb ? null : const NoThumbShape(),
                      trackHeight: thickness,
                    ),
                    child: Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (double value) {
                        audioNotifier.setVolume(value);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
