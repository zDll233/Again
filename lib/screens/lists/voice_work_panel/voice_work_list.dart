import 'dart:async';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/screens/components/future_list.dart';
import 'package:again/screens/components/image_thumbnail.dart';
import 'package:again/screens/lists/voice_work_panel/vk_menu_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        return Consumer(
          builder: (_, WidgetRef ref, __) {
            final selected = ref.watch(_voiceWorkSelectedProvider(index));
            return ListTile(
              leading: ImageThumbnail(imagePath: vk.coverPath),
              title: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                child: Text(vk.title),
              ),
              trailing: VkMenuBtn(voiceWork: vk),
              onTap: () =>
                  ref.read(voiceWorkProvider.notifier).onSelected(index),
              selected: selected,
              contentPadding: const EdgeInsets.only(
                top: 5.0,
                bottom: 5.0,
                left: 20.0,
                right: 10.0,
              ),
              horizontalTitleGap: 0.0,
            );
          },
        );
      },
      itemScrollController: ref.read(uiServiceProvider).vkScrollController,
    );
  }
}

final _voiceWorkSelectedProvider = Provider.family<bool, int>((ref, index) {
  return index ==
      ref.watch(voiceWorkProvider.select((state) => state.selectedIndex));
});
