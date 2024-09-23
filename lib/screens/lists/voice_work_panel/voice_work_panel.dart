import 'package:again/screens/components/voice_panel.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/repository/repository_providers.dart';
import 'package:again/screens/lists/voice_work_panel/voice_work_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceWorkPanel extends ConsumerWidget {
  const VoiceWorkPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOrderIndex =
        ref.watch(sortOrderProvider.select((state) => state.selectedIndex));
    return VoicePanel(
      title:
          'VoiceWorks(${ref.watch(voiceWorkProvider.select((state) => state.values)).length}): ${SortOrder.values[sortOrderIndex] == SortOrder.byTitle ? 'title' : 'time'}',
      listView: const VoiceWorkListView(),
      icon: const Icon(Icons.refresh),
      onIconBtnPressed: ref.read(dbRepoProvider.notifier).onUpdatePressed,
      onTextBtnPressed: () =>
          ref.read(sortOrderProvider.notifier).onSelected(sortOrderIndex),
    );
  }
}
