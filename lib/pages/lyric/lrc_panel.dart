import 'dart:math' as math;

import 'package:again/pages/lyric/components/empty_lyric.dart';
import 'package:again/pages/lyric/components/lyric_builder.dart';
import 'package:again/pages/lyric/components/lyric_panel_controls.dart';
import 'package:again/pages/lyric/components/voice_item_title.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LyricPanel extends ConsumerWidget {
  const LyricPanel({super.key, this.topInset = 0});

  /// 状态栏高度 (SafeArea 外的真实值; 面板内 MediaQuery 读不到)。
  final double topInset;

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
    // 窄屏: 标题区高度 = 参考图比例 (4.2%->10% 屏高) 但保底 56dp。
    final titleHeight =
        math.max(MediaQuery.sizeOf(context).height * 0.058, 56.0);
    return Column(
      children: [
        // 顶部标题行: 当前音轨标题 + 右侧「打开音轨列表」按钮
        // (原在底部控制行, 让位给声道对调按钮)。
        SizedBox(
          height: titleHeight,
          child: Row(
            children: [
              const SizedBox(width: 20),
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: VoiceItemTitle(),
                ),
              ),
              IconButton(
                key: const Key('queue_button'),
                tooltip: '打开正在播放的音轨列表',
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints.tightFor(width: 44, height: 44),
                onPressed: () {
                  // 先恢复播放中的作品和音轨, 再稳定切到音轨页。
                  ref.read(uiServiceProvider).openTracksPanel();
                },
                icon: const Icon(Icons.queue_music),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        // 标题和底部控制区固定在 PageView 外, 横向切换时只有封面/歌词移动。
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: LyricBuilder(topInset: topInset)),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 30,
                child: SizedBox(
                  height: lyricPanelControlsHeight,
                  child: LyricPanelControls(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
