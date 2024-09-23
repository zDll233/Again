import 'package:again/presentation/u_i_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CvList extends ConsumerWidget {
  const CvList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(cvProvider.select((state) => state.values));
    if (values.isEmpty) {
      return const Center(child: Text('No items found'));
    }
    return ScrollablePositionedList.builder(
      itemCount: values.length,
      itemBuilder: (context, index) {
        final cv = values[index];
        return Consumer(
          builder: (_, WidgetRef ref, __) {
            final selected = ref.watch(_cvSelectedProvider(index));
            return ListTile(
              title: Text(cv),
              onTap: () => ref.read(cvProvider.notifier).onSelected(index),
              selected: selected,
            );
          },
        );
      },
      itemScrollController: ref.read(uiServiceProvider).cvScrollController,
    );
  }
}

final _cvSelectedProvider =
    Provider.autoDispose.family<bool, int>((ref, index) {
  return index == ref.watch(cvProvider.select((state) => state.selectedIndex));
});
