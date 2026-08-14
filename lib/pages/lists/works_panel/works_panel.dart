import 'package:again/pages/components/voice_panel.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lists/works_panel/works_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorksPanel extends ConsumerWidget {
  const WorksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOrderIndex =
        ref.watch(sortOrderProvider.select((state) => state.selectedIndex));
    final byTitle = SortOrder.values[sortOrderIndex] == SortOrder.byTitle;
    return VoicePanel(
      title:
          '作品(${ref.watch(voiceWorkProvider.select((state) => state.values)).length})',
      listView: const WorksListView(),
      actions: [
        IconButton(
          icon: Icon(
            byTitle ? Icons.sort_by_alpha : Icons.history,
            size: 18,
          ),
          tooltip: byTitle ? '排序: 标题' : '排序: 时间',
          // 点击切换排序 (标题/时间), 对应列表由 sortOrder notifier 驱动
          onPressed: () =>
              ref.read(sortOrderProvider.notifier).onSelected(sortOrderIndex),
        ),
      ],
    );
  }
}
