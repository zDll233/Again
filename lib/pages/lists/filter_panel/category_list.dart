import 'package:again/pages/components/empty_state.dart';
import 'package:again/pages/components/searchable_header.dart';
import 'package:again/services/ui/theme/text_settings.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:again/services/ui/theme/ui_settings.dart';
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
      return const EmptyState(icon: Icons.folder_open_outlined);
    }
    // 搜索关闭时直接显示全量列表
    final searchEnabled = searchEnabledFor(ref, searchFilterEnabledProvider);
    if (!searchEnabled) {
      return ScrollablePositionedList.builder(
        itemCount: values.length,
        itemBuilder: (context, index) => _buildItem(values, index),
        itemScrollController: ref.read(uiServiceProvider).cateScrollController,
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
                  itemBuilder: (context, index) =>
                      _buildItem(values, filtered[index]),
                  itemScrollController:
                      ref.read(uiServiceProvider).cateScrollController,
                ),
        ),
      ],
    );
  }

  /// 单个分类条目 (index 为原始列表索引)。
  Widget _buildItem(List<String> values, int index) {
    return Consumer(
      builder: (context, ref, child) {
        final selected = ref.watch(_categotySelectedProvider(index));
        final ts = ref.watch(textSettingsProvider).valueOrNull;
        final ui = ref.watch(uiSettingsProvider).valueOrNull;
        final themeHue = resolveThemeHueSource(
            Theme.of(context).colorScheme, kDefaultThemeSeed);
        return Material(
          color: Colors.transparent,
          child: ListTile(
            title: Text(
              values[index],
              maxLines: 1,
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
                ref.read(categoryProvider.notifier).onSelected(index),
            selected: selected,
            contentPadding: EdgeInsets.symmetric(
              vertical: ui?.listDensity == 'comfortable' ? 8.0 : 1.0,
              horizontal: 10.0,
            ),
          ),
        );
      },
    );
  }
}

final _categotySelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index ==
      ref.watch(categoryProvider.select((state) => state.selectedIndex));
});
