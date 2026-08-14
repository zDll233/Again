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
    final sortOrder = ref
            .watch(sortOrderProvider.select((state) => state.cachedSelectedItem))
        ??
        SortOrder.byTitleAsc;
    return VoicePanel(
      title:
          '作品(${ref.watch(voiceWorkProvider.select((state) => state.values)).length})',
      listView: const WorksListView(),
      actions: [
        PopupMenuButton<SortOrder>(
          icon: const Icon(Icons.sort, size: 18),
          tooltip: '排序',
          initialValue: sortOrder,
          onSelected: (value) =>
              ref.read(sortOrderProvider.notifier).setSortOrder(value),
          itemBuilder: (context) => [
            for (final s in SortOrder.values)
              CheckedPopupMenuItem(
                value: s,
                checked: s == sortOrder,
                child: Text(s.label),
              ),
          ],
        ),
      ],
    );
  }
}
