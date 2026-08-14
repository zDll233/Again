import 'package:again/pages/components/empty_state.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TracksListView extends ConsumerStatefulWidget {
  const TracksListView({super.key});

  @override
  ConsumerState<TracksListView> createState() => _TracksListViewState();
}

class _TracksListViewState extends ConsumerState<TracksListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uiServiceProvider).scrollToSelectedIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(voiceItemProvider.select((state) => state.values));
    if (values.isEmpty) {
      return const EmptyState(icon: Icons.queue_music_outlined);
    }
    return ScrollablePositionedList.builder(
      itemCount: values.length,
      itemBuilder: (context, index) {
        final voiceItem = values[index];
        return Consumer(
          builder: (_, WidgetRef ref, __) {
            final selected = ref.watch(_voiceItemSelectedProvider(index));
            final ts = ref.watch(textSettingsProvider).valueOrNull;
            final themeHue = resolveThemeHueSource(
                Theme.of(context).colorScheme, kDefaultThemeSeed);
            // 外包 Material: 让 InkWell 的 ink 画在本层而非根 Material,
            // 避免选中高亮在滚动后逃逸面板裁剪
            return Material(
              color: Colors.transparent,
              child: ListTile(
                title: Text(
                  voiceItem.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ts == null
                      ? null
                      : TextStyle(
                          fontSize: ts.panelTextSize,
                          color: ts.panelTextColor?.resolve(
                              Colors.transparent, themeHue),
                        ),
                ),
                onTap: () =>
                    ref.read(voiceItemProvider.notifier).onSelected(index),
                selected: selected,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 1.0,
                ),
              ),
            );
          },
        );
      },
      itemScrollController: ref.read(uiServiceProvider).tracksScrollController,
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
