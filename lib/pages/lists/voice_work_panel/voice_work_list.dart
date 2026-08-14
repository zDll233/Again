import 'package:again/pages/components/empty_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/components/image_thumbnail.dart';
import 'package:again/pages/lists/voice_work_panel/vw_menu_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class VoiceWorkListView extends ConsumerWidget {
  const VoiceWorkListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(voiceWorkProvider.select((state) => state.values));
    if (values.isEmpty) {
      return const EmptyState();
    }
    return ScrollablePositionedList.builder(
      itemCount: values.length,
      itemBuilder: (context, index) {
        final voiceWork = values[index];
        return Consumer(
          builder: (_, WidgetRef ref, __) {
            final selected = ref.watch(_voiceWorkSelectedProvider(index));
            // 外包 Material: 让 ListTile 内部 InkWell 的 ink 画在本层而非根 Material,
            // 避免选中高亮 (Ink) 在滚动后逃逸面板裁剪
            return Material(
              color: Colors.transparent,
              child: ListTile(
              leading: ImageThumbnail(imagePath: voiceWork.coverPath),
              title: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                child: Text(
                  voiceWork.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              subtitle: voiceWork.sourceId.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 2.0),
                      child: Text(
                        voiceWork.sourceId,
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    ),
              trailing: VwMenuBtn(voiceWork: voiceWork),
              onTap: () =>
                  ref.read(voiceWorkProvider.notifier).onSelected(index),
              selected: selected,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              horizontalTitleGap: 0.0,
            ),
            );
          },
        );
      },
      itemScrollController: ref.read(uiServiceProvider).vwScrollController,
    );
  }
}

final _voiceWorkSelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index ==
      ref.watch(voiceWorkProvider.select((state) => state.selectedIndex));
});
