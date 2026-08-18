import 'package:again/common/const.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// UI 外观设置 (封面/滑块/列表布局, 与文字设置分离, config.json 键均可选)。
class UiSettings {
  final bool coverTilt; // 封面 3D 倾斜动画
  final bool coverReflection; // 封面倒影
  final bool showSliderThumb; // 进度条/音量条滑块圆点
  final double sliderThickness; // 进度条/音量条轨道粗细
  final double sliderThumbSize; // 滑块圆点大小 (半径)
  final String listDensity; // 列表密度 'compact' | 'comfortable'
  final bool showHoverTime; // 歌词 hover 行起始时间
  final double hoverTimeSize; // hover 行起始时间字号
  final bool showCoverLyric; // 封面歌词预览

  const UiSettings({
    this.coverTilt = true,
    this.coverReflection = true,
    this.showSliderThumb = false,
    this.sliderThickness = 1,
    this.sliderThumbSize = 5,
    this.listDensity = 'comfortable',
    this.showHoverTime = true,
    this.hoverTimeSize = 14,
    this.showCoverLyric = true,
  });

  factory UiSettings.fromConfig(Map<String, dynamic> config) {
    final thickness = config['sliderThickness'];
    final thumbSize = config['sliderThumbSize'];
    final hoverTimeSize = config['hoverTimeSize'];
    return UiSettings(
      coverTilt: config['coverTilt'] != false,
      coverReflection: config['coverReflection'] != false,
      showSliderThumb: config['showSliderThumb'] == true,
      sliderThickness: thickness is num ? thickness.toDouble() : 1,
      sliderThumbSize: thumbSize is num ? thumbSize.toDouble() : 5,
      listDensity:
          config['listDensity'] == 'compact' ? 'compact' : 'comfortable',
      showHoverTime: config['showHoverTime'] != false,
      hoverTimeSize: hoverTimeSize is num ? hoverTimeSize.toDouble() : 14,
      showCoverLyric: config['showCoverLyric'] != false,
    );
  }

  /// 重置时移除的配置键。
  static const List<String> baseKeys = [
    'coverTilt',
    'coverReflection',
    'showSliderThumb',
    'sliderThickness',
    'sliderThumbSize',
    'listDensity',
    'showHoverTime',
    'hoverTimeSize',
    'showCoverLyric',
  ];
}

final uiSettingsProvider = FutureProvider.autoDispose<UiSettings>((ref) async {
  final config = await ref.read(configJsonProvider).read();
  return UiSettings.fromConfig(config);
});
