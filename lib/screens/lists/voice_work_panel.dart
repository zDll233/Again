import 'dart:async';

import 'package:again/components/future_list.dart';
import 'package:again/components/vk_menu_btn.dart';
import 'package:again/components/voice_panel.dart';
import 'package:again/components/image_thumbnail.dart';
import 'package:again/presentation/filter/sort_oder/sort_order_state.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/repository/repository_providers.dart';
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
      listView: const FutureVoiceWorkListView(),
      icon: const Icon(Icons.refresh),
      onIconBtnPressed: ref.read(repositoryProvider.notifier).onUpdatePressed,
      onTextBtnPressed: () =>
          ref.read(sortOrderProvider.notifier).onSelected(sortOrderIndex),
    );
  }
}

class FutureVoiceWorkListView extends ConsumerWidget {
  const FutureVoiceWorkListView({super.key});

  Future<List> fetchItems(WidgetRef ref) async {
    return ref.watch(voiceWorkProvider.select((state) => state.values));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureListView(
      future: fetchItems(ref),
      itemBuilder: (context, vk, index) {
        final selectedindex =
            ref.watch(voiceWorkProvider.select((state) => state.selectedIndex));
        return ListTile(
          leading: ImageThumbnail(imagePath: vk.coverPath),
          title: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 5.0),
            child: Text(vk.title),
          ),
          trailing: VkMenuBtn(voiceWork: vk),
          onTap: () => ref.read(voiceWorkProvider.notifier).onSelected(index),
          selected: selectedindex == index,
          contentPadding: const EdgeInsets.only(
              top: 5.0, bottom: 5.0, left: 20.0, right: 10.0),
          horizontalTitleGap: 0.0,
        );
      },
      itemScrollController: ref.read(uiServiceProvider).vkScrollController,
    );
  }
}
