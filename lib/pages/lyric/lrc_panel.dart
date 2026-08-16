import 'package:again/pages/lyric/components/empty_lyric.dart';
import 'package:again/pages/lyric/components/lyric_builder.dart';
import 'package:again/pages/lyric/components/voice_item_title.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class LyricPanel extends ConsumerWidget {
  const LyricPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAudioSource =
        ref.watch(voiceItemProvider.select((state) => state.isPlaying));

    if (!hasAudioSource) {
      return const EmptyLyric();
    }
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    if (!isNarrow) {
      // 宽屏 (桌面): 标题居中, 无作品名副标题 (保持桌面原布局)
      return Column(
        children: [
          SizedBox(
            height: 50.0,
            child: const VoiceItemTitle(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: const LyricBuilder(),
          ),
        ],
      );
    }
    return Column(
      children: [
        // 顶部控制栏: 歌名 + 作品名副标题, 左对齐 (1:1 复刻参考布局)
        SizedBox(
          height: 56.0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.only(left: 20),
              child: _TitleBlock(),
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

/// 歌名 (主) + 作品名 (副, 灰色小字) — 参考播放器标题区。
class _TitleBlock extends ConsumerWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final playingViPath = ref.watch(voiceItemProvider
        .select((state) => state.cachedPlayingVoiceItemPath!));
    final workName = p.basename(p.dirname(playingViPath));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const VoiceItemTitle(),
        Text(
          workName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
