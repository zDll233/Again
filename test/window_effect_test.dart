import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolveWindowEffect: 缺省为 acrylic', () {
    expect(resolveWindowEffect({}), 'acrylic');
  });

  test('resolveWindowEffect: 兼容旧 liquidGlass 配置', () {
    expect(resolveWindowEffect({'liquidGlass': false}), 'transparent');
    expect(resolveWindowEffect({'liquidGlass': true}), 'acrylic');
  });

  test('resolveWindowEffect: 新配置优先于旧配置', () {
    expect(
      resolveWindowEffect({'windowEffect': 'opaque', 'liquidGlass': false}),
      'opaque',
    );
    expect(resolveWindowEffect({'windowEffect': 'transparent'}), 'transparent');
    expect(resolveWindowEffect({'windowEffect': 'acrylic'}), 'acrylic');
  });
}
