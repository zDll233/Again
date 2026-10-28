import 'package:again/pages/player/components/play_back_controls/channel_swap_button.dart';
import 'package:again/pages/player/components/slider_thumb_shape.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 音量控制 (左右声道对调 + 静音图标 + 横向滑杆, 支持滚轮)。
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
        // 比原先宽 50: 多出来的宽度给左右声道对调按钮, 滑杆长度不变
        width: 200,
        child: Row(
          children: [
            // 40 的按钮盒与静音按钮、打开歌词按钮的悬停圆形高亮一致
            const ChannelSwapButton(iconSize: 24, buttonSize: 40),
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
                  final thickness = appearance?.sliderThickness ??
                      UiSettings.defaultSliderThickness;
                  final thumbSize = appearance?.sliderThumbSize ?? 5;
                  return SizedBox(
                    // 固定操作区高度: thumb/overlay 隐藏时 Slider 固有高度
                    // 会坍缩到轨道高度 (1px), 点击基本失效
                    height: 40,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape: showThumb
                            ? RoundSliderThumbShape(
                                enabledThumbRadius: thumbSize)
                            : const NoThumbShape(),
                        overlayShape: showThumb
                            ? RoundSliderOverlayShape(
                                overlayRadius: thumbSize + 6)
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
