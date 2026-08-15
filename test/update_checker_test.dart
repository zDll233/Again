import 'package:again/services/updater/update_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('compareVersions', () {
    test('忽略 v 前缀', () {
      expect(compareVersions('v0.4.4', 'v0.4.3'), greaterThan(0));
      expect(compareVersions('v0.4.3', 'v0.4.4'), lessThan(0));
      expect(compareVersions('v0.4.4', 'v0.4.4'), 0);
    });

    test('按段比较', () {
      expect(compareVersions('0.10.0', '0.9.9'), greaterThan(0));
      expect(compareVersions('1.0.0', '0.9.9'), greaterThan(0));
      expect(compareVersions('0.4.4', '0.4.4.1'), lessThan(0));
    });

    test('非法段按 0 处理', () {
      expect(compareVersions('0.4.x', '0.4.0'), 0);
    });
  });
}
