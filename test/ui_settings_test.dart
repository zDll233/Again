import 'package:again/services/ui/theme/ui_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('歌词滚动回正延迟缺省为 5 秒 (与原硬编码 waitMilliseconds 一致)', () {
    final defaults = UiSettings.fromConfig({});

    expect(defaults.lyricScrollBackSeconds, 5);
    expect(const UiSettings().lyricScrollBackSeconds, 5);
  });

  test('歌词滚动回正延迟显式配置时回读', () {
    final settings = UiSettings.fromConfig({'lyricScrollBackSeconds': 8});

    expect(settings.lyricScrollBackSeconds, 8);
  });

  test('歌词滚动回正延迟越界值收敛到可调范围 (防滑杆越界)', () {
    expect(
      UiSettings.fromConfig({
        'lyricScrollBackSeconds': 999,
      }).lyricScrollBackSeconds,
      UiSettings.maxLyricScrollBackSeconds,
    );
    expect(
      UiSettings.fromConfig({
        'lyricScrollBackSeconds': 0,
      }).lyricScrollBackSeconds,
      UiSettings.minLyricScrollBackSeconds,
    );
  });

  test('歌词滚动回正延迟非法值回退默认', () {
    expect(
      UiSettings.fromConfig({
        'lyricScrollBackSeconds': '5s',
      }).lyricScrollBackSeconds,
      UiSettings.defaultLyricScrollBackSeconds,
    );
  });

  test('baseKeys 包含歌词滚动回正延迟键 (重置时一并清除)', () {
    expect(UiSettings.baseKeys, contains('lyricScrollBackSeconds'));
  });
}
