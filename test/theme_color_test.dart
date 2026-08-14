import 'package:again/common/const.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
