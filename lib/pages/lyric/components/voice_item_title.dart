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
          return TextButton(
              onPressed: ref.read(uiServiceProvider).selectPlayingVoiceItem,
              child: Text(
                p.basenameWithoutExtension(playingViPath),
                style: Theme.of(context).textTheme.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ));
        },
      ),
    );
  }
}
