import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolveWindowEffect: 缺省为 acrylic', () {
    expect(resolveWindowEffect({}), 'acrylic');
    expect(resolveWindowEffect({'windowEffect': 'unknown'}), 'acrylic');
  });

  test('resolveWindowEffect: 读取合法配置值', () {
    expect(resolveWindowEffect({'windowEffect': 'transparent'}), 'transparent');
    expect(resolveWindowEffect({'windowEffect': 'acrylic'}), 'acrylic');
    expect(resolveWindowEffect({'windowEffect': 'opaque'}), 'opaque');
  });
}
