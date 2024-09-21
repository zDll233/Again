import 'package:again/presentation/u_i_providers.dart';
import 'package:again/screens/components/future_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CvList extends ConsumerWidget {
  const CvList({super.key});

  Future<List> fetchCvItems(WidgetRef ref) async {
    return ref.watch(cvProvider.select((state) => state.values));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureListView(
        future: fetchCvItems(ref),
        itemBuilder: (context, title, index) {
          return Consumer(
            builder: (_, WidgetRef ref, __) {
              final selected = ref.watch(_cvSelectedProvider(index));
              return ListTile(
                title: Text(title),
                onTap: () => ref.read(cvProvider.notifier).onSelected(index),
                selected: selected,
              );
            },
          );
        },
        itemScrollController: ref.read(uiServiceProvider).cvScrollController);
  }
}

final _cvSelectedProvider = Provider.family<bool, int>((ref, index) {
  return index == ref.watch(cvProvider.select((state) => state.selectedIndex));
});
