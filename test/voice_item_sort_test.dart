import 'package:again/models/voice_item.dart';
import 'package:again/services/ui/presentation/voice_item/voice_item_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  VoiceItem vi(String title, {DateTime? at}) => VoiceItem(
        title: title,
        filePath: '/w/$title.mp3',
        voiceWorkPath: '/w',
        createdAt: at,
      );

  List<String> sorted(List<VoiceItem> items, VoiceItemSort sort) =>
      applyVoiceItemSort(List.of(items), sort).map((e) => e.title).toList();

  group('音轨时间排序', () {
    test('时间顺序/倒序按 createdAt 排列', () {
      final items = [
        vi('b', at: DateTime(2026, 1, 2)),
        vi('a', at: DateTime(2026, 1, 1)),
        vi('c', at: DateTime(2026, 1, 3)),
      ];
      expect(sorted(items, VoiceItemSort.timeAsc), ['a', 'b', 'c']);
      expect(sorted(items, VoiceItemSort.timeDesc), ['c', 'b', 'a']);
    });

    test('同一秒内用标题自然序兜底 (drift 只存整秒)', () {
      final t = DateTime(2026, 1, 1);
      final items = [vi('track10', at: t), vi('track2', at: t)];
      expect(sorted(items, VoiceItemSort.timeAsc), ['track2', 'track10']);
      expect(sorted(items, VoiceItemSort.timeDesc), ['track10', 'track2']);
    });

    test('时间为空回退 1970, 排在有时间的前面', () {
      final items = [
        vi('withTime', at: DateTime(2026, 1, 1)),
        vi('nullTime'),
      ];
      expect(sorted(items, VoiceItemSort.timeAsc), ['nullTime', 'withTime']);
      expect(sorted(items, VoiceItemSort.timeDesc), ['withTime', 'nullTime']);
    });

    test('重复应用排序结果不变 (纯排序, 不再是反转)', () {
      final items = [
        vi('a', at: DateTime(2026, 1, 2)),
        vi('b', at: DateTime(2026, 1, 1)),
      ];
      final once = applyVoiceItemSort(List.of(items), VoiceItemSort.timeDesc);
      final twice = applyVoiceItemSort(List.of(once), VoiceItemSort.timeDesc);
      expect(twice.map((e) => e.title), ['a', 'b']);
    });

    test('标题排序不受 createdAt 影响', () {
      final items = [
        vi('b', at: DateTime(2026, 1, 1)),
        vi('a', at: DateTime(2026, 1, 3)),
      ];
      expect(sorted(items, VoiceItemSort.titleAsc), ['a', 'b']);
      expect(sorted(items, VoiceItemSort.titleDesc), ['b', 'a']);
    });
  });

  group('voiceItemSort 配置兼容', () {
    test('旧值 fileAsc/fileDesc 映射到时间升/降序', () {
      expect(VoiceItemSortExtension.fromString('VoiceItemSort.fileAsc'),
          VoiceItemSort.timeAsc);
      expect(VoiceItemSortExtension.fromString('VoiceItemSort.fileDesc'),
          VoiceItemSort.timeDesc);
    });

    test('新值与未知值', () {
      expect(VoiceItemSortExtension.fromString('VoiceItemSort.timeDesc'),
          VoiceItemSort.timeDesc);
      expect(VoiceItemSortExtension.fromString('VoiceItemSort.nope'),
          VoiceItemSort.titleAsc);
    });
  });
}
