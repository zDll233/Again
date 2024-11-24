import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/components/image_thumbnail.dart';
import 'package:again/pages/lists/voice_work_panel/vk_menu_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class VoiceWorkListView extends ConsumerWidget {
  const VoiceWorkListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(voiceWorkProvider.select((state) => state.values));
    if (values.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ScrollablePositionedList.builder(
      itemCount: values.length,
      itemBuilder: (context, index) {
        final voiceWork = values[index];
        return Consumer(
          builder: (_, WidgetRef ref, __) {
            final selected = ref.watch(_voiceWorkSelectedProvider(index));
            return ListTile(
              leading: ImageThumbnail(imagePath: voiceWork.coverPath),
              title: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                child: Text(voiceWork.title),
              ),
              trailing: VkMenuBtn(voiceWork: voiceWork),
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

final _voiceWorkSelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index ==
      ref.watch(voiceWorkProvider.select((state) => state.selectedIndex));
});
