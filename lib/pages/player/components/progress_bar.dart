import 'package:again/pages/player/components/slider_thumb_shape.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
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
          int step = 10000;
          if (scrollDelta > 0) {
            step = -step;
          }
          audioNotifier.seek(Duration(
              milliseconds:
                  ref.read(audioProvider).position.inMilliseconds + step));
        }
      },
      child: SizedBox(
        height: 40,
        width: appWidth,
        child: Consumer(
          builder: (_, WidgetRef ref, __) {
            final duration =
                ref.watch(audioProvider.select((state) => state.duration));
            final position =
                ref.watch(audioProvider.select((state) => state.position));
            // 是否显示滑块圆点 / 轨道粗细 (设置项)
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
                focusNode: FocusNode(canRequestFocus: false),
                onChanged: (value) {
                  if (duration != Duration.zero) {
                    final position = value * duration.inMilliseconds;
                    audioNotifier
                        .seek(Duration(milliseconds: position.round()));
                  }
                },
                value: _getProgressBarValue(position, duration),
              ),
            );
          },
        ),
      ),
    );
  }
}
