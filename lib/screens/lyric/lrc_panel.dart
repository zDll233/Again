import 'package:again/presentation/u_i_providers.dart';
import 'package:again/screens/lyric/components/empty_lyric.dart';
import 'package:again/screens/lyric/components/lyric_builder.dart';
import 'package:again/screens/lyric/components/voice_item_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LyricPanel extends ConsumerWidget {
  const LyricPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
