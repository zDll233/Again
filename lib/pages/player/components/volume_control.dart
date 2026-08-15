import 'package:again/pages/player/components/slider_thumb_shape.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 音量控制 (图标 + 横向滑杆, 支持滚轮)。
/// 仅宽屏 (桌面) 使用 — 移动端移除应用内音量 (系统音量键更方便)。
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
                  final showThumb = appearance?.showSliderThumb ?? false;
                  final thickness = appearance?.sliderThickness ?? 1;
                  final thumbSize = appearance?.sliderThumbSize ?? 5;
                  return SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: showThumb
                          ? RoundSliderThumbShape(enabledThumbRadius: thumbSize)
                          : const NoThumbShape(),
                      overlayShape: showThumb
                          ? RoundSliderOverlayShape(overlayRadius: thumbSize + 6)
                          : const NoThumbShape(),
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
