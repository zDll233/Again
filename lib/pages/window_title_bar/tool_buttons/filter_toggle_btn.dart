import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 折叠/展开 Filter 面板的按钮; 有生效的筛选条件时高亮。
class FilterToggleBtn extends ConsumerWidget {
  const FilterToggleBtn({
    super.key,
    this.buttonWidth = 46.0,
    this.buttonHeight = 32.0,
  });

  final double buttonWidth;
  final double buttonHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded =
        ref.watch(miscUIProvider.select((state) => state.filterExpanded));
    final hasActiveFilter = ref.watch(
      categoryProvider.select((state) =>
          state.cachedSelectedItem != null &&
          state.cachedSelectedItem != 'All'),
    ) ||
        ref.watch(cvProvider.select((state) =>
            state.cachedSelectedItem != null &&
            state.cachedSelectedItem != 'All'));

    return IconButton(
      onPressed: () =>
          ref.read(miscUIProvider.notifier).toggleFilterExpanded(),
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      iconSize: 20,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: buttonWidth,
        height: buttonHeight,
      ),
      tooltip: expanded ? '收起筛选' : '展开筛选',
      icon: Icon(
        expanded
            ? Icons.filter_alt
            : hasActiveFilter
                ? Icons.filter_alt
                : Icons.filter_alt_outlined,
        color: expanded || hasActiveFilter
            ? Theme.of(context).colorScheme.primary
            : const Color.fromRGBO(255, 255, 255, 0.5),
      ),
    );
  }
}
