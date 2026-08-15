import 'package:again/common/const.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 封面外观设置 (与文字设置分离, config.json 键均可选, 缺省启用)。
class AppearanceSettings {
  final bool coverTilt; // 封面 3D 倾斜动画
  final bool coverReflection; // 封面倒影
  final bool showSliderThumb; // 进度条/音量条滑块圆点

  const AppearanceSettings({
    this.coverTilt = true,
    this.coverReflection = true,
    this.showSliderThumb = true,
  });

  factory AppearanceSettings.fromConfig(Map<String, dynamic> config) {
    return AppearanceSettings(
      coverTilt: config['coverTilt'] != false,
      coverReflection: config['coverReflection'] != false,
      showSliderThumb: config['showSliderThumb'] != false,
    );
  }

  /// 重置时移除的配置键。
  static const List<String> baseKeys = [
    'coverTilt',
    'coverReflection',
    'showSliderThumb',
  ];
}

final appearanceSettingsProvider =
    FutureProvider.autoDispose<AppearanceSettings>((ref) async {
  final config = await ref.read(configJsonProvider).read();
  return AppearanceSettings.fromConfig(config);
});
