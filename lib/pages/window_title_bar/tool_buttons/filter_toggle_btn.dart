import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 折叠/展开 Filter 面板的按钮。
///
/// 选中态只看面板是否展开 (展开=实心+主题色, 收起=描边灰), 不再受
/// 「已有筛选条件」影响 —— 否则收起面板但保留筛选时会一直显示成选中。
/// 歌词界面没有筛选面板, 该按钮隐藏。
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
    final expanded = ref.watch(
      miscUIProvider.select((state) => state.filterExpanded),
    );
    // 歌词界面: 宽屏标题栏仍在, 但此时没有筛选面板可开关, 隐藏按钮
    final showLyricPanel = ref.watch(
      miscUIProvider.select((state) => state.showLyricPanel),
    );
    if (showLyricPanel) return const SizedBox.shrink();

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
        expanded ? Icons.filter_alt : Icons.filter_alt_outlined,
        color: expanded
            ? Theme.of(context).colorScheme.primary
            : const Color.fromRGBO(255, 255, 255, 0.5),
      ),
    );
  }
}
