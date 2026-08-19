import 'package:again/pages/components/voice_panel.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:again/pages/lists/filter_panel/category_list.dart';
import 'package:again/pages/lists/filter_panel/cv_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterPanel extends ConsumerWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VoicePanel(
      title: '筛选',
      listView: const FilterListView(),
      actions: [
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          tooltip: '重置筛选',
          onPressed: ref.read(uiServiceProvider).onResetFilterPressed,
        ),
      ],
    );
  }
}

class FilterListView extends StatelessWidget {
  const FilterListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 1, child: CategoryList()),
        SizedBox(width: 4),
        Expanded(flex: 1, child: CvList())
      ],
    );
  }
}
