import 'package:again/utils/kana_romaji.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kanaToRomaji', () {
    test('清音', () {
      expect(kanaToRomaji('こまる'), 'komaru');
    });

    test('浊音/拗音', () {
      expect(kanaToRomaji('みやぢ'), 'miyaji');
      expect(kanaToRomaji('上田麗奈'), '上田麗奈'); // 汉字原样保留
    });

    test('片假名', () {
      expect(kanaToRomaji('スズ'), 'suzu');
    });

    test('混合', () {
      expect(kanaToRomaji('大西沙織'), '大西沙織');
      expect(kanaToRomaji('ヒロイチ'), 'hiroichi');
    });

    test('长音符忽略', () {
      expect(kanaToRomaji('メーカー'), 'meka');
    });
  });
}
