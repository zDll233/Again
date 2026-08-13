import 'package:again/pages/components/empty_state.dart';
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
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      return const EmptyState(icon: Icons.person_search_outlined);
    }
    final filtered = _filteredIndices(values);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 搜索框: 支持原名 / 罗马音匹配
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
          child: SizedBox(
            height: 32,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: '搜索 CV (罗马音/原名)',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.35),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 15),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                isDense: true,
                filled: true,
                fillColor: scheme.onSurface.withValues(alpha: 0.06),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
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
}

final _cvSelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index == ref.watch(cvProvider.select((state) => state.selectedIndex));
});
