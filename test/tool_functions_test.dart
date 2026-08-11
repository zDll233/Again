import 'package:again/utils/tool_functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('replaceLast', () {
    test('替换最后一次出现', () {
      expect(replaceLast('a-b-b-c', 'b', 'x'), 'a-b-x-c');
    });

    test('路径中替换类别', () {
      expect(
        replaceLast(r'C:\root\分类A\作品', '分类A', '分类B'),
        r'C:\root\分类B\作品',
      );
    });

    test('目标不存在时原样返回', () {
      expect(replaceLast('abc', 'x', 'y'), 'abc');
    });

    test('只出现一次时也替换', () {
      expect(replaceLast('abc', 'b', 'x'), 'axc');
    });
  });
}
