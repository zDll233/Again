import 'package:again/services/ui/theme/text_settings.dart';
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
        maxWidth: MediaQuery.of(context).size.width * 0.70,
      ),
      child: Consumer(
        builder: (_, WidgetRef ref, __) {
          final playingViPath = ref.watch(voiceItemProvider
              .select((state) => state.cachedPlayingVoiceItemPath!));
          final lyricTitleSize =
              ref.watch(textSettingsProvider).valueOrNull?.lyricTitleSize;
          return Tooltip(
            message: '在资源管理器中显示该音轨',
            child: TextButton(
                onPressed: ref.read(uiServiceProvider).selectPlayingVoiceItem,
                child: Text(
                  p.basenameWithoutExtension(playingViPath),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: lyricTitleSize,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
          );
        },
      ),
    );
  }
}
