import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class VoiceItemListView extends ConsumerStatefulWidget {
  const VoiceItemListView({super.key});

  @override
  ConsumerState<VoiceItemListView> createState() => _VoiceItemListViewState();
}

class _VoiceItemListViewState extends ConsumerState<VoiceItemListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uiServiceProvider).scrollToPlayingIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(voiceItemProvider.select((state) => state.values));
    if (values.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ScrollablePositionedList.builder(
      itemCount: values.length,
      itemBuilder: (context, index) {
        final voiceItem = values[index];
        return Consumer(
          builder: (_, WidgetRef ref, __) {
            final selected = ref.watch(_voiceItemSelectedProvider(index));
            return ListTile(
              title: Text(voiceItem.title),
              onTap: () =>
                  ref.read(voiceItemProvider.notifier).onSelected(index),
              selected: selected,
            );
          },
        );
      },
      itemScrollController: ref.read(uiServiceProvider).viScrollController,
    );
  }
}

final _voiceItemSelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  final voiceWorkPlaying = ref.watch(isSelectedVoiceWorkPlaying);
  return index ==
          ref.watch(voiceItemProvider.select((state) => state.selectedIndex)) &&
      voiceWorkPlaying;
});
