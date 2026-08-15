import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lyric/components/empty_lyric.dart';
import 'package:again/pages/lyric/components/lyric_builder.dart';
import 'package:again/pages/lyric/components/voice_item_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LyricPanel extends ConsumerWidget {
  const LyricPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAudioSource =
        ref.watch(voiceItemProvider.select((state) => state.isPlaying));

    return hasAudioSource
        ? Column(
            children: [
              const SizedBox(
                height: 50.0,
                child: VoiceItemTitle(),
              ),
              // 必须 Expanded: 窄屏下 LyricBuilder 是 PageView (左右滑动),
              // 无高度约束会 collapse 到 0
              Expanded(
                child: const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: LyricBuilder(),
                ),
              ),
            ],
          )
        : const EmptyLyric();
  }
}
