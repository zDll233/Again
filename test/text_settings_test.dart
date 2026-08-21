import 'package:again/services/ui/theme/text_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('封面当前行字号缺省跟随封面其他行字号', () {
    final defaults = TextSettings.fromConfig({});
    final customPreview = TextSettings.fromConfig({'lyricPreviewSize': 22});

    expect(defaults.lyricPreviewCurrentSize, defaults.lyricPreviewSize);
    expect(customPreview.lyricPreviewCurrentSize, 22);
  });

  test('封面当前行字号显式配置时保持独立值', () {
    final settings = TextSettings.fromConfig({
      'lyricPreviewSize': 22,
      'lyricPreviewCurrentSize': 18,
    });

    expect(settings.lyricPreviewCurrentSize, 18);
  });

  test('字重默认值: 保持当前渲染效果 (面板标题 700, 其余 400)', () {
    final defaults = TextSettings.fromConfig({});

    expect(defaults.panelTitleWeight, 700);
    expect(defaults.panelTextWeight, 400);
    expect(defaults.progressTextWeight, 400);
    expect(defaults.lyricTitleWeight, 400);
    expect(defaults.lyricWeight, 400);
    expect(defaults.lyricCurrentWeight, 400);
    expect(defaults.lyricPreviewWeight, 400);
    expect(defaults.lyricPreviewCurrentWeight, 400);
  });

  test('字重显式配置时按位置独立回读', () {
    final settings = TextSettings.fromConfig({
      'panelTextWeight': 700,
      'lyricWeight': 700,
      'lyricPreviewWeight': 700,
      'lyricPreviewCurrentWeight': 700,
    });

    expect(settings.panelTextWeight, 700);
    expect(settings.lyricWeight, 700);
    expect(settings.lyricPreviewWeight, 700);
    expect(settings.lyricPreviewCurrentWeight, 700);
    // 未配置的位置保持默认
    expect(settings.panelTitleWeight, 700);
    expect(settings.lyricCurrentWeight, 400);
    expect(settings.lyricTitleWeight, 400);
    expect(settings.progressTextWeight, 400);
  });

  test('字重非法/缺失值回退该位置默认 (与字号同语义)', () {
    final settings = TextSettings.fromConfig({
      'lyricWeight': 'bold',
      'panelTextWeight': 900,
      'panelTitleWeight': 0,
    });

    expect(settings.lyricWeight, 400);
    expect(settings.panelTextWeight, 400);
    // 非法值回退该位置默认 (面板标题默认 700), 不改变渲染
    expect(settings.panelTitleWeight, 700);
  });

  test('baseKeys 包含全部字重键 (重置时一并清除)', () {
    const weightKeys = {
      'panelTextWeight',
      'panelTitleWeight',
      'progressTextWeight',
      'lyricTitleWeight',
      'lyricWeight',
      'lyricCurrentWeight',
      'lyricPreviewWeight',
      'lyricPreviewCurrentWeight',
    };
    for (final key in weightKeys) {
      expect(TextSettings.baseKeys, contains(key));
    }
  });

  test('起始时间颜色缺省为 null (跟随默认)', () {
    final defaults = TextSettings.fromConfig({});
    expect(defaults.hoverTimeColor, isNull);
  });

  test('起始时间颜色显式配置 hex 时回读', () {
    final settings = TextSettings.fromConfig({
      'hoverTimeColor': '#80C4FF',
    });
    expect(settings.hoverTimeColor?.color, const Color(0xFF80C4FF));
  });

  test('起始时间颜色支持跟随主题色相', () {
    final settings = TextSettings.fromConfig({
      'hoverTimeColorTheme': true,
      'hoverTimeColorSat': 0.5,
      'hoverTimeColorVal': 0.6,
    });
    expect(settings.hoverTimeColor?.themeHue, isTrue);
    expect(settings.hoverTimeColor?.sat, 0.5);
    expect(settings.hoverTimeColor?.val, 0.6);
  });

  test('colorBaseKeys 包含起始时间颜色键 (重置时一并清除)', () {
    expect(TextSettings.colorBaseKeys, contains('hoverTimeColor'));
  });
}
