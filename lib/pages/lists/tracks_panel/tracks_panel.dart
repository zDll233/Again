import 'package:again/pages/components/voice_panel.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lists/tracks_panel/tracks_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TracksPanel extends ConsumerWidget {
  const TracksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiService = ref.watch(uiServiceProvider);
    final byTitle = ref.read(voiceItemProvider.notifier).byTitleSort;
    return VoicePanel(
      title:
          '音轨(${ref.watch(voiceItemProvider.select((state) => state.values)).length})',
      listView: const TracksListView(),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_searching, size: 18),
          tooltip: '定位到当前播放位置',
          onPressed: uiService.onLocateBtnPressed,
        ),
        IconButton(
          icon: const Icon(Icons.folder_open, size: 18),
          tooltip: '打开所在目录',
          onPressed: uiService.revealInExplorerView,
        ),
        IconButton(
          icon: Icon(
            byTitle ? Icons.sort_by_alpha : Icons.numbers,
            size: 18,
          ),
          tooltip: byTitle ? '排序: 标题' : '排序: 文件顺序',
          onPressed: () =>
              ref.read(voiceItemProvider.notifier).toggleSortOrder(),
        ),
      ],
    );
  }
}
