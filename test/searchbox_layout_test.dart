import 'package:again/pages/components/searchable_header.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget build() {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          child: SearchableHeader(
            title: '分类',
            query: '',
            onQueryChanged: (_) {},
            onClear: () {},
            compact: true,
          ),
        ),
      ),
    );
  }

  testWidgets('默认态: 标题文字在 40px 头部内垂直居中', (tester) async {
    await tester.pumpWidget(build());
    final rect = tester.getRect(find.text('分类'));
    expect((rect.top + rect.bottom) / 2, closeTo(20, 1.5));
  });

  testWidgets('窗口失焦/最小化时收起搜索框', (tester) async {
    await tester.pumpWidget(build());
    await tester.tap(find.text('分类'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('分类'), findsOneWidget);

    await tester.tap(find.text('分类'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('分类'), findsOneWidget);
  });

  testWidgets('搜索态: 输入框自然高度在 40px 头部内垂直居中(填充铺满盒子)',
      (tester) async {
    await tester.pumpWidget(build());
    await tester.tap(find.text('分类'));
    await tester.pump();

    final decorator = tester.getRect(find.byType(InputDecorator));
    // 自然高度(37 = 13 内容 + 默认 dense padding 12×2)由 Center 居中。
    expect(decorator.height, 37);
    expect((decorator.top + decorator.bottom) / 2, closeTo(20, 0.5));

    final editable = tester.getRect(find.byType(EditableText));
    final centerRatio =
        (editable.center.dy - decorator.top) / decorator.height;
    expect(centerRatio, closeTo(0.5, 0.1));

    // 填充(CustomPaint)必须覆盖整个装饰器,不能只盖住 13px 内容区。
    final paint = tester.getRect(find.descendant(
      of: find.byType(InputDecorator),
      matching: find.byType(CustomPaint),
    ));
    expect(paint.top, closeTo(decorator.top, 0.5));
    expect(paint.bottom, closeTo(decorator.bottom, 0.5));
  });

  testWidgets('Windows 平台密度: 盒子高度不同但依旧居中、内容居中',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    await tester.pumpWidget(build());
    await tester.tap(find.text('分类'));
    await tester.pump();

    final decorator = tester.getRect(find.byType(InputDecorator));
    final editable = tester.getRect(find.byType(EditableText));
    final centerRatio =
        (editable.center.dy - decorator.top) / decorator.height;
    debugPrint('Windows density: decorator=$decorator editable=$editable '
        'centerRatio=$centerRatio');
    // Windows compact 密度下自然高度更小(29), 但 Center 保证盒子居中。
    expect(decorator.height, 29);
    expect((decorator.top + decorator.bottom) / 2, closeTo(20, 0.5));
    expect(centerRatio, closeTo(0.5, 0.1));
    debugDefaultTargetPlatformOverride = null;
  });
}
