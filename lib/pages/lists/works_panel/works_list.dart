import 'package:again/models/voice_work.dart';
import 'package:again/pages/components/empty_state.dart';
import 'package:again/pages/components/searchable_header.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/components/image_thumbnail.dart';
import 'package:again/pages/lists/works_panel/vw_menu_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class WorksListView extends ConsumerStatefulWidget {
  const WorksListView({super.key});

  @override
  ConsumerState<WorksListView> createState() => _WorksListViewState();
}

class _WorksListViewState extends ConsumerState<WorksListView> {
  String _query = '';

  /// 过滤后保留原始 index, onSelected 需要原始 index。
  List<int> _filteredIndices(List<VoiceWork> values) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return List.generate(values.length, (i) => i);
    }
    final indices = <int>[];
    for (var i = 0; i < values.length; i++) {
      final v = values[i];
      if (v.title.toLowerCase().contains(q) ||
          v.sourceId.toLowerCase().contains(q)) {
        indices.add(i);
      }
    }
    return indices;
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(voiceWorkProvider.select((state) => state.values));
    if (values.isEmpty) {
      return const EmptyState();
    }
    // 搜索关闭时直接显示全量列表 (与开启时共用条目构建)
    final searchEnabled =
        ref.watch(searchEnabledProvider).valueOrNull ?? true;
    if (!searchEnabled) {
      return ScrollablePositionedList.builder(
        itemCount: values.length,
        itemBuilder: (context, index) => _buildItem(context, index),
        itemScrollController:
            ref.read(uiServiceProvider).worksScrollController,
      );
    }
    final filtered = _filteredIndices(values);

    return Column(
      children: [
        SearchableHeader(
          title: '作品',
          query: _query,
          onQueryChanged: (value) => setState(() => _query = value),
          onClear: () => setState(() => _query = ''),
          compact: true,
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_outlined,
                  message: '没有匹配的作品',
                )
              : ScrollablePositionedList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildItem(context, filtered[index]),
                  itemScrollController:
                      ref.read(uiServiceProvider).worksScrollController,
                ),
        ),
      ],
    );
  }

  /// 单个作品条目 (index 为原始列表索引)。
  Widget _buildItem(BuildContext context, int index) {
    final values =
        ref.watch(voiceWorkProvider.select((state) => state.values));
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
  }
}

final _voiceWorkSelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index ==
      ref.watch(voiceWorkProvider.select((state) => state.selectedIndex));
});
