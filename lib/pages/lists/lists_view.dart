import 'package:again/pages/lists/filter_panel/filter_panel.dart';
import 'package:again/pages/lists/tracks_panel/tracks_panel.dart';
import 'package:again/pages/lists/works_panel/works_panel.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
