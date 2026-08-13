import 'package:again/pages/components/empty_state.dart';
import 'package:again/pages/components/searchable_header.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/kana_romaji.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CvList extends ConsumerStatefulWidget {
  const CvList({super.key});

  @override
  ConsumerState<CvList> createState() => _CvListState();
}

class _CvListState extends ConsumerState<CvList> {
  String _query = '';

  /// 过滤后保留原始 index, onSelected 需要原始 index。
  List<int> _filteredIndices(List<String> values) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return List.generate(values.length, (i) => i);
    }
    final indices = <int>[];
    for (var i = 0; i < values.length; i++) {
      final cv = values[i];
      if (cv.toLowerCase().contains(q)) {
        indices.add(i);
        continue;
      }
      if (kanaToRomaji(cv).toLowerCase().contains(q)) {
        indices.add(i);
      }
    }
    return indices;
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(cvProvider.select((state) => state.values));
    if (values.isEmpty) {
      return Column(
        children: [
          SearchableHeader(
            title: '声优',
            query: '',
            onQueryChanged: _noop,
            onClear: () {},
          ),
          const Expanded(child: EmptyState(icon: Icons.person_search_outlined)),
        ],
      );
    }
    final filtered = _filteredIndices(values);

    return Column(
      children: [
        SearchableHeader(
          title: '声优',
          query: _query,
          onQueryChanged: (value) => setState(() => _query = value),
          onClear: () => setState(() => _query = ''),
          compact: true,
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_outlined,
                  message: '没有匹配的 CV',
                )
              : ScrollablePositionedList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final originalIndex = filtered[index];
                    return Consumer(
                      builder: (_, WidgetRef ref, __) {
                        final selected =
                            ref.watch(_cvSelectedProvider(originalIndex));
                        return ListTile(
                          title: Text(
                            values[originalIndex],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => ref
                              .read(cvProvider.notifier)
                              .onSelected(originalIndex),
                          selected: selected,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 1.0,
                          ),
                        );
                      },
                    );
                  },
                  itemScrollController:
                      ref.read(uiServiceProvider).cvScrollController,
                ),
        ),
      ],
    );
  }

  static void _noop(String _) {}
}

final _cvSelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index == ref.watch(cvProvider.select((state) => state.selectedIndex));
});
