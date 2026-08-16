import 'dart:io';

import 'package:again/pages/components/voice_panel.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lists/tracks_panel/tracks_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TracksPanel extends ConsumerWidget {
  const TracksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiService = ref.watch(uiServiceProvider);
    final sort = ref.watch(voiceItemProvider.select((state) => state.sort));
    return VoicePanel(
      title:
          '音轨(${ref.watch(voiceItemProvider.select((state) => state.values)).length})',
      listView: const TracksListView(),
      actions: [
        // Android 放在顶栏; 其他平台保留在音轨面板。
        if (!Platform.isAndroid)
          IconButton(
            icon: const Icon(Icons.location_searching, size: 18),
            tooltip: '定位到当前播放位置',
            onPressed: uiService.onLocateBtnPressed,
          ),
        // Windows 专属: 资源管理器定位
        if (Platform.isWindows)
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
          itemBuilder: (context) {
            final scheme = Theme.of(context).colorScheme;
            return [
              for (final s in VoiceItemSort.values)
                PopupMenuItem(
                  value: s,
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  // 自定义 Row: 避免 CheckedPopupMenuItem 的 ListTile
                  // 布局在文字右侧留下大量空白
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        child: s == sort
                            ? Icon(Icons.check, size: 16, color: scheme.primary)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(s.label, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
            ];
          },
        ),
      ],
    );
  }
}
