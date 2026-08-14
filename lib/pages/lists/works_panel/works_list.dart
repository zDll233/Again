import 'package:again/models/voice_work.dart';
import 'package:again/pages/components/empty_state.dart';
import 'package:again/pages/components/searchable_header.dart';
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
      return const Column(
        children: [
          SearchableHeader(
            title: '作品',
            query: '',
            onQueryChanged: _noop,
            onClear: _noopClear,
          ),
          Expanded(child: EmptyState()),
        ],
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
                  itemBuilder: (context, index) {
                    final originalIndex = filtered[index];
                    final voiceWork = values[originalIndex];
                    return Consumer(
                      builder: (_, WidgetRef ref, __) {
                        final selected = ref
                            .watch(_voiceWorkSelectedProvider(originalIndex));
                        // 外包 Material: 让 ListTile 内部 InkWell 的 ink 画在本层而非根 Material,
                        // 避免选中高亮 (Ink) 在滚动后逃逸面板裁剪
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading:
                                ImageThumbnail(imagePath: voiceWork.coverPath),
                            title: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0, right: 5.0),
                              child: Text(
                                voiceWork.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            subtitle: voiceWork.sourceId.isEmpty
                                ? null
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, top: 2.0),
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
                            onTap: () => ref
                                .read(voiceWorkProvider.notifier)
                                .onSelected(originalIndex),
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
                  itemScrollController:
                      ref.read(uiServiceProvider).worksScrollController,
                ),
        ),
      ],
    );
  }

  static void _noop(String _) {}

  static void _noopClear() {}
}

final _voiceWorkSelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index ==
      ref.watch(voiceWorkProvider.select((state) => state.selectedIndex));
});
