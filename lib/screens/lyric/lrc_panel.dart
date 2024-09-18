import 'package:again/presentation/u_i_providers.dart';
import 'package:again/screens/lyric/components/empty_lyric.dart';
import 'package:again/screens/lyric/components/lyric_builder.dart';
import 'package:again/screens/lyric/components/voice_item_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LyricPanel extends ConsumerStatefulWidget {
  const LyricPanel({
    super.key,
  });

  @override
  ConsumerState<LyricPanel> createState() => _LyricPanelState();
}

class _LyricPanelState extends ConsumerState<LyricPanel> {
  @override
  Widget build(BuildContext context) {
    final hasAudioSource =
        ref.watch(voiceItemProvider.select((state) => state.isPlaying));

    return hasAudioSource
        ? const Column(
            children: [
              SizedBox(
                height: 50.0,
                child: VoiceItemTitle(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: LyricBuilder(),
              ),
            ],
          )
        : const EmptyLyric();
  }
}
