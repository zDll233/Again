import 'package:again/pages/components/voice_panel.dart';
import 'package:again/services/ui/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/services/database/database_providers.dart';
import 'package:again/pages/lists/works_panel/works_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorksPanel extends ConsumerStatefulWidget {
  const WorksPanel({super.key});

  @override
  ConsumerState<WorksPanel> createState() => _WorksPanelState();
}

class _WorksPanelState extends ConsumerState<WorksPanel> {
  bool _updating = false;

  Future<void> _onUpdatePressed() async {
    if (_updating) return;
    setState(() => _updating = true);
    try {
      await ref.read(dbNotifierProvider).onUpdatePressed();
    } finally {
      if (mounted) {
        setState(() => _updating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortOrderIndex =
        ref.watch(sortOrderProvider.select((state) => state.selectedIndex));
    return VoicePanel(
      title:
          '作品(${ref.watch(voiceWorkProvider.select((state) => state.values)).length}): ${SortOrder.values[sortOrderIndex] == SortOrder.byTitle ? '标题' : '时间'}',
      listView: const WorksListView(),
      icon: _updating
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      onIconBtnPressed: _onUpdatePressed,
      onTextBtnPressed: () =>
          ref.read(sortOrderProvider.notifier).onSelected(sortOrderIndex),
    );
  }
}
