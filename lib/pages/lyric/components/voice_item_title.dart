import 'dart:io';

import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class VoiceItemTitle extends StatelessWidget {
  const VoiceItemTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width < 600
            ? MediaQuery.of(context).size.width * 0.78
            : MediaQuery.of(context).size.width * 0.70,
      ),
      child: Consumer(
        builder: (_, WidgetRef ref, __) {
          final playingViPath = ref.watch(voiceItemProvider
              .select((state) => state.cachedPlayingVoiceItemPath!));
          final ts = ref.watch(textSettingsProvider).valueOrNull;
          final scheme = Theme.of(context).colorScheme;
          final themeHue = resolveThemeHueSource(scheme, kDefaultThemeSeed);
          final title = Text(
            p.basenameWithoutExtension(playingViPath),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: ts?.lyricTitleSize,
                  fontWeight: fontWeightFor(ts?.lyricTitleWeight ?? 400),
                  color:
                      ts?.lyricTitleColor?.resolve(scheme.onSurface, themeHue),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
          // Windows: 点击在资源管理器中定位; Android: 纯文本展示
          if (Platform.isWindows) {
            return Tooltip(
              message: '在资源管理器中显示该音轨',
              child: TextButton(
                  onPressed: ref.read(uiServiceProvider).selectPlayingVoiceItem,
                  child: title),
            );
          } else {
            return title;
          }
        },
      ),
    );
  }
}
