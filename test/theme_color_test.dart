import 'package:again/common/const.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolveThemeColorMode: 缺省为跟随封面', () {
    expect(resolveThemeColorMode({}), 'cover');
  });

  test('resolveThemeColorMode: 兼容旧 followCoverTheme 配置', () {
    expect(resolveThemeColorMode({'followCoverTheme': false}), 'custom');
    expect(resolveThemeColorMode({'followCoverTheme': true}), 'cover');
  });

  test('resolveThemeColorMode: 新配置优先于旧配置', () {
    expect(
      resolveThemeColorMode({'themeColorMode': 'custom', 'followCoverTheme': true}),
      'custom',
    );
    expect(resolveThemeColorMode({'themeColorMode': 'cover'}), 'cover');
  });

  test('resolveThemeSeedHex: 缺省默认紫, 新配置优先', () {
    expect(resolveThemeSeedHex({}), kDefaultThemeSeedHex);
    expect(resolveThemeSeedHex({'themeSeedColor': '#FF0000'}), '#FF0000');
  });

  test('parseHexColor: 支持 #RRGGBB 与 RRGGBB, 非法返回 null', () {
    expect(parseHexColor('#FF0000'), const Color(0xFFFF0000));
    expect(parseHexColor('00FF00'), const Color(0xFF00FF00));
    expect(parseHexColor('#9C6BFF'), const Color(0xFF9C6BFF));
    expect(parseHexColor('red'), isNull);
    expect(parseHexColor('#12345'), isNull);
  });

  test('resolveTextColorMode: 缺省跟随主题色, 兼容旧 accentColorMode, 新配置优先', () {
    expect(resolveTextColorMode({}), 'follow');
    expect(resolveTextColorMode({'textColorMode': 'custom'}), 'custom');
    expect(resolveTextColorMode({'accentColorMode': 'custom'}), 'custom');
    expect(
      resolveTextColorMode({'textColorMode': 'follow', 'accentColorMode': 'custom'}),
      'follow',
    );
  });

  test('resolveTextColorHex: 缺省 onSurface, 兼容旧 accentColor, 新配置优先', () {
    expect(resolveTextColorHex({}), kDefaultTextColorHex);
    expect(resolveTextColorHex({'textColor': '#00FF00'}), '#00FF00');
    expect(resolveTextColorHex({'accentColor': '#FF0000'}), '#FF0000');
    expect(
      resolveTextColorHex({'textColor': '#00FF00', 'accentColor': '#FF0000'}),
      '#00FF00',
    );
  });
}
