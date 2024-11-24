import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(categoryProvider.select((state) => state.values));
    if (values.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ScrollablePositionedList.builder(
      itemCount: values.length,
      itemBuilder: (context, index) {
        final category = values[index];
        return Consumer(
          builder: (context, ref, child) {
            final selected = ref.watch(_categotySelectedProvider(index));
            return ListTile(
              title: Text(category),
              onTap: () =>
                  ref.read(categoryProvider.notifier).onSelected(index),
              selected: selected,
            );
          },
        );
      },
      itemScrollController: ref.read(uiServiceProvider).cateScrollController,
    );
  }
}

final _categotySelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index ==
      ref.watch(categoryProvider.select((state) => state.selectedIndex));
});
