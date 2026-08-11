import 'package:again/services/database/voice_updater.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getCvList', () {
    test('多CV', () {
      expect(getCvList('cv1&cv2-title'), ['cv1', 'cv2']);
    });

    test('中文CV名', () {
      expect(getCvList('芹澤優&古賀葵-作品名'), ['芹澤優', '古賀葵']);
    });

    test('作品名含连字符时只取首个连字符之前', () {
      expect(getCvList('cv1&cv2-a-b-c'), ['cv1', 'cv2']);
    });

    test('单个CV', () {
      expect(getCvList('cv1-title'), ['cv1']);
    });
  });

  group('isSourceIdValid', () {
    test('合法RJ号', () {
      expect(isSourceIdValid('RJ123456'), isTrue);
    });

    test('小写RJ号', () {
      expect(isSourceIdValid('rj123456'), isTrue);
    });

    test('纯数字', () {
      expect(isSourceIdValid('123456'), isTrue);
    });

    test('VJ/BJ', () {
      expect(isSourceIdValid('VJ42'), isTrue);
      expect(isSourceIdValid('BJ42'), isTrue);
    });

    test('非法值', () {
      expect(isSourceIdValid('abc'), isFalse);
      expect(isSourceIdValid('RJ'), isFalse);
      expect(isSourceIdValid('RJ123a'), isFalse);
      expect(isSourceIdValid(''), isFalse);
    });
  });
}
