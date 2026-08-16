import 'package:again/pages/player/components/slider_thumb_shape.dart';
import 'package:again/services/audio/audio_notifier.dart';
import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressBar extends ConsumerWidget {
  const ProgressBar({super.key, this.trackAtTop = false});

  /// 窄屏进度条轨道位置: true 贴顶 (跑道胶囊/歌词控制区用), false 贴底。
  final bool trackAtTop;

  /// 窄屏进度条: 纯轨道 (紧邻时间行), 点击/拖动 seek。
  Widget _buildNarrow(BuildContext context, WidgetRef ref,
      AudioNotifier audioNotifier) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 24,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final duration =
              ref.watch(audioProvider.select((state) => state.duration));
          final position =
              ref.watch(audioProvider.select((state) => state.position));
          final appearance = ref.watch(uiSettingsProvider).valueOrNull;
          final thickness =
              (appearance?.sliderThickness ?? 1).clamp(1.0, 6.0);
          final progress = (duration == Duration.zero ||
                  position == Duration.zero)
              ? 0.0
              : (position.inMilliseconds / duration.inMilliseconds)
                  .clamp(0.0, 1.0);

          void seekAt(double dx) {
            if (duration == Duration.zero) return;
            final ratio = (dx / constraints.maxWidth).clamp(0.0, 1.0);
            audioNotifier.seek(
                Duration(milliseconds: (duration.inMilliseconds * ratio).round()));
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => seekAt(d.localPosition.dx),
            onHorizontalDragUpdate: (d) => seekAt(d.localPosition.dx),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: trackAtTop ? 0 : null,
                  bottom: trackAtTop ? null : 0,
                  height: thickness,
                  child: Container(
                    color: scheme.onSurface.withValues(alpha: 0.12),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: trackAtTop ? 0 : null,
                  bottom: trackAtTop ? null : 0,
                  width: constraints.maxWidth * progress,
                  height: thickness,
                  child: Container(color: scheme.primary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    if (isNarrow) {
      return _buildNarrow(context, ref, audioNotifier);
    }
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
