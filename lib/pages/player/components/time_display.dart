import 'package:again/services/audio/audio_providers.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 播放进度时间 (当前播放位置)。
class PositionTimeText extends ConsumerWidget {
  const PositionTimeText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(audioProvider.select((state) => state.position));
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    return Text(
      getTimeText(position),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: ts?.progressTextSize,
            fontWeight: fontWeightFor(ts?.progressTextWeight ?? 400),
            color: ts?.progressTextColor?.resolve(scheme.onSurface, themeHue),
          ),
    );
  }
}

/// 播放总时长。
class DurationTimeText extends ConsumerWidget {
  const DurationTimeText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(audioProvider.select((state) => state.duration));
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    return Text(
      getTimeText(duration),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: ts?.progressTextSize,
            fontWeight: fontWeightFor(ts?.progressTextWeight ?? 400),
            color: ts?.progressTextColor?.resolve(scheme.onSurface, themeHue),
          ),
    );
  }
}

String getTimeText(Duration duration) {
  if (duration == Duration.zero) return '';
  return formatDuration(duration);
}

/// Formats durations like a media player: `mm:ss` below one hour and
/// `h:mm:ss` once an hour boundary is reached.
String formatDuration(Duration duration) {
  final negative = duration.isNegative;
  final totalSeconds = duration.inSeconds.abs();
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final prefix = negative ? '-' : '';

  String twoDigits(int value) => value.toString().padLeft(2, '0');

  if (hours > 0) {
    return '$prefix$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
  return '$prefix${twoDigits(minutes)}:${twoDigits(seconds)}';
}

/// 兼容旧调用: "当前 / 总时长" 合并文本 (宽屏布局用)。
class TimeDisplay extends ConsumerWidget {
  const TimeDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(audioProvider.select((state) => state.duration));
    final position = ref.watch(audioProvider.select((state) => state.position));
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    return Align(
      alignment: Alignment.center,
      child: Text(
        getTimeDisplayText(position, duration),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: ts?.progressTextSize,
              color: ts?.progressTextColor?.resolve(scheme.onSurface, themeHue),
            ),
      ),
    );
  }
}

String getTimeDisplayText(Duration position, Duration duration) {
  if (position != Duration.zero) {
    return '${getTimeText(position)} / ${getTimeText(duration)}';
  } else if (duration != Duration.zero) {
    return getTimeText(duration);
  } else {
    return '';
  }
}
