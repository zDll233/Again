import 'package:again/pages/components/empty_state.dart';
import 'package:again/pages/components/searchable_header.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CategoryList extends ConsumerStatefulWidget {
  const CategoryList({super.key});

  @override
  ConsumerState<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList> {
  String _query = '';

  List<int> _filteredIndices(List<String> values) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return List.generate(values.length, (i) => i);
    }
    final indices = <int>[];
    for (var i = 0; i < values.length; i++) {
      if (values[i].toLowerCase().contains(q)) {
        indices.add(i);
      }
    }
    return indices;
  }

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(categoryProvider.select((state) => state.values));
    if (values.isEmpty) {
      return const Column(
        children: [
          SearchableHeader(
            title: '分类',
            query: '',
            onQueryChanged: _noop,
            onClear: _noopClear,
          ),
          Expanded(child: EmptyState(icon: Icons.folder_open_outlined)),
        ],
      );
    }
    final filtered = _filteredIndices(values);

    return Column(
      children: [
        SearchableHeader(
          title: '分类',
          query: _query,
          onQueryChanged: (value) => setState(() => _query = value),
          onClear: () => setState(() => _query = ''),
          compact: true,
        ),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_outlined,
                  message: '没有匹配的分类',
                )
              : ScrollablePositionedList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final originalIndex = filtered[index];
                    return Consumer(
                      builder: (context, ref, child) {
                        final selected =
                            ref.watch(_categotySelectedProvider(originalIndex));
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            title: Text(
                              values[originalIndex],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => ref
                                .read(categoryProvider.notifier)
                                .onSelected(originalIndex),
                            selected: selected,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 1.0,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  itemScrollController:
                      ref.read(uiServiceProvider).cateScrollController,
                ),
        ),
      ],
    );
  }

  static void _noop(String _) {}

  static void _noopClear() {}
}

final _categotySelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index ==
      ref.watch(categoryProvider.select((state) => state.selectedIndex));
});
