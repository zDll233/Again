import 'package:again/pages/settings/components/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 设置页文字设置行/面板在窄屏 (Android) 宽度下的布局回归测试:
/// 文字编辑面板内容宽 = 屏宽 - 80 (见 settings_page.dart 的 panelWidth),
/// 360dp 屏 → 280dp; 测试各设置行在该宽度下不溢出、不换行。
void main() {
  Future<void> pumpTile(
    WidgetTester tester,
    Widget tile, {
    double width = 280,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width,
            child: tile,
          ),
        ),
      ),
    );
  }

  void expectNoOverflow(WidgetTester tester) {
    expect(tester.takeException(), isNull,
        reason: '窄屏下不得出现 RenderFlex 溢出');
  }

  testWidgets('字号行: 最长标签在 280 宽不溢出不换行', (tester) async {
    await pumpTile(
      tester,
      SettingsTextSizeTile(
        label: '歌词起始时间字号',
        value: 14,
        defaultValue: 14,
        icon: Icons.timer_outlined,
        onChanged: (_) {},
        onChangedEnd: (_) {},
        onReset: () {},
      ),
    );
    expectNoOverflow(tester);
    final title =
        tester.widget<Text>(find.text('歌词起始时间字号'));
    expect(title.maxLines, 1, reason: '标签应单行省略而非换行');
    expect(title.overflow, TextOverflow.ellipsis);
  });

  testWidgets('字重行: 分段按钮在 280 宽不溢出不换行', (tester) async {
    await pumpTile(
      tester,
      SettingsTextWeightTile(
        label: '字重',
        value: 400,
        defaultValue: 400,
        icon: Icons.format_bold,
        onChanged: (_) {},
        onChangedEnd: (_) {},
        onReset: () {},
      ),
    );
    expectNoOverflow(tester);
  });

  testWidgets('颜色行: 在 280 宽不溢出', (tester) async {
    await pumpTile(
      tester,
      SettingsTextColorTile(
        label: '颜色',
        setting: null,
        fallback: Colors.white,
        themeHueColor: Colors.blue,
        onChanged: (_) {},
        onReset: () {},
        onSave: (_) async {},
      ),
    );
    expectNoOverflow(tester);
  });

  testWidgets('文字位置入口行: 在 280 宽不溢出', (tester) async {
    await pumpTile(
      tester,
      SettingsTextPositionTile(
        icon: Icons.timer_outlined,
        title: '歌词起始时间',
        sample: '00:35',
        sampleStyle: const TextStyle(fontSize: 14),
        onTap: () {},
      ),
    );
    expectNoOverflow(tester);
  });

  testWidgets('360dp 屏: 放宽 insetPadding 后面板内容宽约 280 不被挤压',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    // 与 settings_page.dart 面板一致: 窄屏放宽占屏宽度
                    insetPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 24),
                    title: const Text('歌词起始时间'),
                    content: SizedBox(
                      width: 280, // (360 - 80).clamp(240, 420)
                      child: const Text('00:35'),
                    ),
                  ),
                ),
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expectNoOverflow(tester);
    final content = find.byType(SizedBox).last;
    final box = tester.getSize(content);
    expect(box.width, 280,
        reason: '内容宽不应被默认 insetPadding 挤压 (实际 ${box.width})');
  });
}