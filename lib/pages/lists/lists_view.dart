import 'package:again/pages/components/panel_switcher.dart';
import 'package:again/pages/lists/filter_panel/filter_panel.dart';
import 'package:again/pages/lists/tracks_panel/tracks_panel.dart';
import 'package:again/pages/lists/works_panel/works_panel.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 窄屏断点: 宽度不足以并排作品/音轨面板时改用左右滑动切换。
const double _narrowBreakpoint = 600;

/// 窄屏筛选抽屉宽度 (占屏宽比例)。
const double _filterDrawerRatio = 0.72;

class ListsView extends ConsumerWidget {
  const ListsView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final filterExpanded = ref.watch(
      miscUIProvider.select((state) => state.filterExpanded),
    );
    final isNarrow = MediaQuery.sizeOf(context).width < _narrowBreakpoint;

    if (isNarrow) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      final drawerWidth = (screenWidth * _filterDrawerRatio)
          .clamp(240.0, 360.0)
          .toDouble();
      return Stack(
        children: [
          // 作品/音轨: 左右滑动切换 (面板自带标题, 无 tab 条);
          // 外部可请求跳页 (歌词界面队列按钮)
          PanelSwitcher(
            panels: const [WorksPanel(), TracksPanel()],
            pageProvider: listsPanelPageProvider,
          ),
          // 筛选抽屉: 从左到右弹出, 不完全覆盖 (右侧留白点击收起)
          if (filterExpanded) ...[
            Positioned.fill(
              child: GestureDetector(
                // 点击右侧留白收起筛选
                onTap: () => ref
                    .read(miscUIProvider.notifier)
                    .toggleFilterExpanded(),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.30),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              left: 0,
              top: 0,
              bottom: 0,
              width: drawerWidth,
              child: Material(
                color: scheme.surface.withValues(alpha: 0.98),
                borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: const FilterPanel(),
              ),
            ),
          ],
        ],
      );
    }

    final divider = VerticalDivider(
      width: 1.0,
      thickness: 1.0,
      color: scheme.onSurface.withValues(alpha: 0.08),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: filterExpanded ? 280 : 0,
          child: filterExpanded ? const FilterPanel() : null,
        ),
        if (filterExpanded) divider,
        const Flexible(flex: 16, child: WorksPanel()),
        divider,
        const Flexible(flex: 10, child: TracksPanel()),
      ],
    );
  }
}
