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
      title: 'Filter',
      listView: const FilterListView(),
      icon: const Icon(Icons.remove),
      onIconBtnPressed: ref.read(uiServiceProvider).onResetFilterPressed,
    );
  }
}

class FilterListView extends StatelessWidget {
  const FilterListView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 与 CvList 顶部搜索框等高的头部, 保证两列列表垂直对齐
    final header = SizedBox(
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(
            '分类',
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Column(
            children: [
              header,
              const Expanded(child: CategoryList()),
            ],
          ),
        ),
        const SizedBox(width: 180, child: CvList())
      ],
    );
  }
}
