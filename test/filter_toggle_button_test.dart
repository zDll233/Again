import 'package:again/pages/window_title_bar/tool_buttons/filter_toggle_btn.dart';
import 'package:again/services/ui/presentation/filter/category/category_notifier.dart';
import 'package:again/services/ui/presentation/filter/category/category_state.dart';
import 'package:again/services/ui/ui_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// 标题栏「筛选面板」按钮: 展开或已有生效筛选条件时高亮; 歌词界面隐藏。
void main() {
  Icon iconOf(WidgetTester tester) =>
      tester.widget<Icon>(find.byType(Icon));

  Future<ProviderContainer> pumpButton(
    WidgetTester tester, {
    String category = 'All',
  }) async {
    final container = ProviderContainer(
      overrides: [
        categoryProvider.overrideWith(
          () => _StubCategoryNotifier(category),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: FilterToggleBtn())),
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  ColorScheme schemeOf(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(FilterToggleBtn))).colorScheme;

  testWidgets('无筛选且收起时未选中: 描边图标 + 非主题色', (tester) async {
    await pumpButton(tester);
    final icon = iconOf(tester);
    expect(icon.icon, Icons.filter_alt_outlined);
    expect(icon.color, isNot(schemeOf(tester).primary));
  });

  testWidgets('展开时选中: 实心图标 + 主题色', (tester) async {
    final container = await pumpButton(tester);
    container.read(miscUIProvider.notifier).setFilterExpanded(true,
        persist: false);
    await tester.pump();

    final icon = iconOf(tester);
    expect(icon.icon, Icons.filter_alt);
    expect(icon.color, schemeOf(tester).primary);
  });

  testWidgets('已有生效筛选条件时, 收起也保持高亮 (原逻辑)', (tester) async {
    final container = await pumpButton(tester, category: 'Loved');
    expect(iconOf(tester).icon, Icons.filter_alt,
        reason: '有筛选条件时收起状态也高亮, 提示列表被筛选过');
    expect(iconOf(tester).color, schemeOf(tester).primary);

    // 展开 → 收起, 高亮保持 (筛选条件仍在)
    container.read(miscUIProvider.notifier).setFilterExpanded(true,
        persist: false);
    await tester.pump();
    container.read(miscUIProvider.notifier).setFilterExpanded(false,
        persist: false);
    await tester.pump();
    expect(iconOf(tester).icon, Icons.filter_alt);
    expect(iconOf(tester).color, schemeOf(tester).primary);
  });

  testWidgets('歌词界面不显示按钮', (tester) async {
    final container = await pumpButton(tester);
    expect(find.byType(IconButton), findsOneWidget);

    container.read(miscUIProvider.notifier).showLyricPanel();
    await tester.pump();
    expect(find.byType(IconButton), findsNothing,
        reason: '歌词界面没有筛选面板, 按钮应隐藏');

    container.read(miscUIProvider.notifier).hideLyricPanel();
    await tester.pump();
    expect(find.byType(IconButton), findsOneWidget, reason: '回到目录界面恢复显示');
  });
}

class _StubCategoryNotifier extends CategoryNotifier {
  _StubCategoryNotifier(this._cached);

  final String _cached;

  @override
  CategoryState build() => CategoryState(cachedSelectedItem: _cached);
}
