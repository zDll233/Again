import 'package:again/models/voice_item.dart';
import 'package:again/models/voice_work.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceWork toMap/fromMap', () {
    test('round-trip', () {
      final work = VoiceWork(
        title: 'cv1&cv2-作品名',
        sourceId: 'RJ123456',
        directoryPath: r'C:\root\分类A\cv1&cv2-作品名',
        coverPath: r'C:\root\分类A\cv1&cv2-作品名\cover.jpg',
        category: '分类A',
        createdAt: DateTime(2024, 1, 2, 3, 4, 5),
      );

      final restored = VoiceWork.fromMap(work.toMap());

      expect(restored.title, work.title);
      expect(restored.sourceId, work.sourceId);
      expect(restored.directoryPath, work.directoryPath);
      expect(restored.coverPath, work.coverPath);
      expect(restored.category, work.category);
      expect(restored.createdAt, work.createdAt);
      expect(restored, work);
    });

    test('createdAt 为 null 时 round-trip', () {
      final work = VoiceWork(
        title: 'title',
        sourceId: '',
        directoryPath: r'C:\root\a\title',
        coverPath: '',
        category: 'a',
        createdAt: null,
      );

      final restored = VoiceWork.fromMap(work.toMap());

      expect(restored.createdAt, isNull);
      expect(restored, work);
    });

    test('fromMap 缺失字段给空值不抛异常', () {
      final work = VoiceWork.fromMap({});

      expect(work.title, '');
      expect(work.sourceId, '');
      expect(work.createdAt, isNull);
    });
  });

  group('VoiceItem toMap/fromMap', () {
    test('round-trip', () {
      final item = VoiceItem(
        title: 'track1',
        filePath: r'C:\root\a\title\track1.mp3',
        voiceWorkPath: r'C:\root\a\title',
      );

      final restored = VoiceItem.fromMap(item.toMap());

      expect(restored, item);
    });
  });
}
