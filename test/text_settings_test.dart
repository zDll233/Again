import 'package:again/services/ui/theme/text_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('封面当前行字号缺省跟随封面其他行字号', () {
    final defaults = TextSettings.fromConfig({});
    final customPreview = TextSettings.fromConfig({'lyricPreviewSize': 22});

    expect(defaults.lyricPreviewCurrentSize, defaults.lyricPreviewSize);
    expect(customPreview.lyricPreviewCurrentSize, 22);
  });

  test('封面当前行字号显式配置时保持独立值', () {
    final settings = TextSettings.fromConfig({
      'lyricPreviewSize': 22,
      'lyricPreviewCurrentSize': 18,
    });

    expect(settings.lyricPreviewCurrentSize, 18);
  });
}
