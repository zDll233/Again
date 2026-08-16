import 'package:again/models/voice_item.dart';
import 'package:again/pages/components/empty_state.dart';
import 'package:again/pages/components/searchable_header.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/kana_romaji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class TracksListView extends ConsumerStatefulWidget {
  const TracksListView({super.key});

  @override
  ConsumerState<TracksListView> createState() => _TracksListViewState();
}

class _TracksListViewState extends ConsumerState<TracksListView> {
  String _query = '';

  /// 过滤后保留原始 index, onSelected 需要原始 index。
  List<int> _filteredIndices(List<VoiceItem> values) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return List.generate(values.length, (i) => i);
    }
    final indices = <int>[];
    for (var i = 0; i < values.length; i++) {
      final title = values[i].title;
      if (title.toLowerCase().contains(q) ||
          kanaToRomaji(title).toLowerCase().contains(q)) {
        indices.add(i);
      }
    }
    return indices;
  }

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
    // 搜索关闭时直接显示全量列表 (与开启时共用条目构建)
    final searchEnabled = searchEnabledFor(ref, searchTracksEnabledProvider);
    if (!searchEnabled) {
      return _buildList(values, null);
    }
    final filtered = _filteredIndices(values);

    return Column(
      children: [
        SearchableHeader(
          title: '音轨',
          query: _query,
          onQueryChanged: (value) => setState(() => _query = value),
          onClear: () => setState(() => _query = ''),
          compact: true,
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_outlined,
                  message: '没有匹配的音轨',
                )
              : _buildList(values, filtered),
        ),
      ],
    );
  }

  /// 音轨列表; [indices] 为 null 时显示全量, 否则只显示过滤后的索引。
  Widget _buildList(List<VoiceItem> values, List<int>? indices) {
    // 窄屏底部留出悬浮胶囊空间 (内容可滚到胶囊上方);
    // 宽屏面板视口止于播放器顶部 (MyApp 已留出播放器高度), 无需垫底
    final bottomPad = MediaQuery.sizeOf(context).width < 600 ? 120.0 : 0.0;
    return ScrollablePositionedList.builder(
      itemCount: indices?.length ?? values.length,
      padding: EdgeInsets.only(bottom: bottomPad),
      itemBuilder: (context, index) {
        final originalIndex = indices?[index] ?? index;
        final voiceItem = values[originalIndex];
        return Consumer(
          builder: (_, WidgetRef ref, __) {
            final selected =
                ref.watch(_voiceItemSelectedProvider(originalIndex));
            final ts = ref.watch(textSettingsProvider).valueOrNull;
            final ui = ref.watch(uiSettingsProvider).valueOrNull;
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
                          color: ts.panelTextColor
                              ?.resolve(Colors.transparent, themeHue),
                        ),
                ),
                onTap: () => ref
                    .read(voiceItemProvider.notifier)
                    .onSelected(originalIndex),
                selected: selected,
                contentPadding: EdgeInsets.symmetric(
                  vertical: ui?.listDensity == 'comfortable' ? 8.0 : 1.0,
                  horizontal: 12.0,
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
