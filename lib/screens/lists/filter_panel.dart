import 'package:again/screens/components/future_list.dart';
import 'package:again/screens/components/voice_panel.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterPanel extends ConsumerWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VoicePanel(
      title: 'Filter',
      listView: const FutureFilterListView(),
      icon: const Icon(Icons.remove),
      onIconBtnPressed: ref.read(uiServiceProvider).onRemoveFilterPressed,
    );
  }
}

class FutureFilterListView extends ConsumerWidget {
  const FutureFilterListView({super.key});

  Future<List> fetchcategoryItems(WidgetRef ref) async {
    return ref.watch(categoryProvider.select((state) => state.values));
  }

  Future<List> fetchCvItems(WidgetRef ref) async {
    return ref.watch(cvProvider.select((state) => state.values));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Consumer(
            builder: (_, WidgetRef ref, __) {
              final selectedIndex = ref.watch(
                  categoryProvider.select((state) => state.selectedIndex));
              return FutureListView(
                  future: fetchcategoryItems(ref),
                  itemBuilder: (context, category, index) {
                    return ListTile(
                      title: Text(category),
                      onTap: () =>
                          ref.read(categoryProvider.notifier).onSelected(index),
                      selected: selectedIndex == index,
                    );
                  },
                  itemScrollController:
                      ref.read(uiServiceProvider).cateScrollController);
            },
          ),
        ),
        SizedBox(
            width: 150,
            child: Consumer(
              builder: (_, WidgetRef ref, __) {
                final selectedIndex = ref
                    .watch(cvProvider.select((state) => state.selectedIndex));
                return FutureListView(
                    future: fetchCvItems(ref),
                    itemBuilder: (context, title, index) {
                      return ListTile(
                        title: Text(title),
                        onTap: () =>
                            ref.read(cvProvider.notifier).onSelected(index),
                        selected: selectedIndex == index,
                      );
                    },
                    itemScrollController:
                        ref.read(uiServiceProvider).cvScrollController);
              },
            ))
      ],
    );
  }
}
