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
    final position =
        ref.watch(audioProvider.select((state) => state.position));
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    return Text(
      getTimeText(position),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: ts?.progressTextSize,
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
    final duration =
        ref.watch(audioProvider.select((state) => state.duration));
    final ts = ref.watch(textSettingsProvider).valueOrNull;
    final scheme = Theme.of(context).colorScheme;
    final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
    return Text(
      getTimeText(duration),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: ts?.progressTextSize,
            color: ts?.progressTextColor
                ?.resolve(scheme.onSurface, themeHue),
          ),
    );
  }
}

String getTimeText(Duration duration) {
  if (duration == Duration.zero) return '';
  return duration.toString().split('.').first;
}

/// 兼容旧调用: "当前 / 总时长" 合并文本 (宽屏布局用)。
class TimeDisplay extends ConsumerWidget {
  const TimeDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration =
        ref.watch(audioProvider.select((state) => state.duration));
    final position =
        ref.watch(audioProvider.select((state) => state.position));
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
    return '${position.toString().split('.').first} / ${duration.toString().split('.').first}';
  } else if (duration != Duration.zero) {
    return duration.toString().split('.').first;
  } else {
    return '';
  }
}
