import 'package:again/presentation/u_i_providers.dart';
import 'package:again/screens/components/future_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  Future<List> fetchcategoryItems(WidgetRef ref) async {
    return ref.watch(categoryProvider.select((state) => state.values));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureListView(
        future: fetchcategoryItems(ref),
        itemBuilder: (context, title, index) {
          return Consumer(
            builder: (context, ref, child) {
              final selected = ref.watch(_categotySelectedProvider(index));
              return ListTile(
                title: Text(title),
                onTap: () =>
                    ref.read(categoryProvider.notifier).onSelected(index),
                selected: selected,
              );
            },
          );
        },
        itemScrollController: ref.read(uiServiceProvider).cateScrollController);
  }
}

final _categotySelectedProvider = Provider.family<bool, int>((ref, index) {
  return index ==
      ref.watch(categoryProvider.select((state) => state.selectedIndex));
});
