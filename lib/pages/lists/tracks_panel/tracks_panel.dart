import 'package:again/pages/components/voice_panel.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_notifier.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lists/tracks_panel/tracks_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TracksPanel extends ConsumerWidget {
  const TracksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiService = ref.watch(uiServiceProvider);
    final sort = ref.read(voiceItemProvider.notifier).sort;
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
        PopupMenuButton<VoiceItemSort>(
          icon: const Icon(Icons.sort, size: 18),
          tooltip: '排序',
          initialValue: sort,
          onSelected: (value) =>
              ref.read(voiceItemProvider.notifier).setSortOrder(value),
          itemBuilder: (context) => [
            for (final s in VoiceItemSort.values)
              CheckedPopupMenuItem(
                value: s,
                checked: s == sort,
                // 紧凑: 缩小行高与内边距, 避免菜单过空
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(s.label, style: const TextStyle(fontSize: 13)),
              ),
          ],
        ),
      ],
    );
  }
}
