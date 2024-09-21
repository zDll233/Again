import 'package:again/screens/components/voice_panel.dart';
import 'package:again/presentation/u_i_providers.dart';
import 'package:again/screens/lists/filter_panel/category_list.dart';
import 'package:again/screens/lists/filter_panel/cv_list.dart';
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
      onIconBtnPressed: ref.read(uiServiceProvider).onResetFilterPressed,
    );
  }
}

class FutureFilterListView extends StatelessWidget {
  const FutureFilterListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 100,
          child: CategoryList(),
        ),
        SizedBox(
          width: 150,
          child: CvList(),
        )
      ],
    );
  }
}
