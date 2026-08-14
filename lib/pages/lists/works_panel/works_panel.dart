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
          itemBuilder: (context) {
            final scheme = Theme.of(context).colorScheme;
            return [
              for (final s in SortOrder.values)
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
                        child: s == sortOrder
                            ? Icon(Icons.check,
                                size: 16, color: scheme.primary)
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
