import 'package:again/pages/lyric/components/empty_lyric.dart';
import 'package:again/pages/lyric/components/lyric_builder.dart';
import 'package:again/pages/lyric/components/voice_item_title.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LyricPanel extends ConsumerWidget {
  const LyricPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAudioSource =
        ref.watch(voiceItemProvider.select((state) => state.isPlaying));

    if (!hasAudioSource) {
      return const EmptyLyric();
    }
    return Column(
      children: [
        // 顶部控制栏: 标题左对齐 (参考播放器布局)
        SizedBox(
          height: 50.0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: const VoiceItemTitle(),
            ),
          ),
        ),
        // 必须 Expanded: 无高度约束会 collapse 到 0;
        // 控制区在页面内部 (LyricBuilder 每页), 与内容紧凑堆叠
        Expanded(
          child: const Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: LyricBuilder(),
          ),
        ),
      ],
    );
  }
}
