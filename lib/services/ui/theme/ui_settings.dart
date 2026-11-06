import 'dart:io';

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
  final int hoverTimeWeight; // hover 行起始时间字重 (400 常规 / 700 粗体)
  final bool showCoverLyric; // 封面歌词预览

  /// 歌词滚动回正延迟 (秒): 手动滚动歌词后, 等待多久自动滚回当前播放行。
  final int lyricScrollBackSeconds;

  /// 歌词滚动回正延迟的默认值 / 可调范围 (秒)。
  /// 默认 5 秒与原硬编码的 `waitMilliseconds: 5000` 一致。
  static const int defaultLyricScrollBackSeconds = 5;
  static const int minLyricScrollBackSeconds = 1;
  static const int maxLyricScrollBackSeconds = 20;

  /// 轨道粗细默认值: 手机上 1px 几乎看不见, Android 默认 5; 桌面保持细线 1。
  static double get defaultSliderThickness => Platform.isWindows ? 1 : 5;

  const UiSettings({
    this.coverTilt = true,
    this.coverReflection = true,
    this.showSliderThumb = false,
    this.sliderThickness = 1,
    this.sliderThumbSize = 5,
    this.listDensity = 'comfortable',
    this.showHoverTime = true,
    this.hoverTimeSize = 14,
    this.hoverTimeWeight = 400,
    this.showCoverLyric = true,
    this.lyricScrollBackSeconds = defaultLyricScrollBackSeconds,
  });

  /// 读取 config 中的歌词滚动回正延迟 (秒):
  /// 缺失/非数字时回退默认值, 越界时收敛到可调范围
  /// (配置被手工改成范围外的值时, 设置页滑杆不会越界)。
  static int scrollBackSecondsFromConfig(Map<String, dynamic> config) {
    final raw = config['lyricScrollBackSeconds'];
    if (raw is! num) return defaultLyricScrollBackSeconds;
    return raw
        .toInt()
        .clamp(minLyricScrollBackSeconds, maxLyricScrollBackSeconds)
        .toInt();
  }

  factory UiSettings.fromConfig(Map<String, dynamic> config) {
    final thickness = config['sliderThickness'];
    final thumbSize = config['sliderThumbSize'];
    final hoverTimeSize = config['hoverTimeSize'];
    return UiSettings(
      coverTilt: config['coverTilt'] != false,
      coverReflection: config['coverReflection'] != false,
      showSliderThumb: config['showSliderThumb'] == true,
      sliderThickness: thickness is num
          ? thickness.toDouble()
          : UiSettings.defaultSliderThickness,
      sliderThumbSize: thumbSize is num ? thumbSize.toDouble() : 5,
      listDensity:
          config['listDensity'] == 'compact' ? 'compact' : 'comfortable',
      showHoverTime: config['showHoverTime'] != false,
      hoverTimeSize: hoverTimeSize is num ? hoverTimeSize.toDouble() : 14,
      hoverTimeWeight: config['hoverTimeWeight'] == 700 ? 700 : 400,
      showCoverLyric: config['showCoverLyric'] != false,
      lyricScrollBackSeconds: scrollBackSecondsFromConfig(config),
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
    'hoverTimeWeight',
    'showCoverLyric',
    'lyricScrollBackSeconds',
  ];
}

final uiSettingsProvider = FutureProvider.autoDispose<UiSettings>((ref) async {
  final config = await ref.read(configJsonProvider).read();
  return UiSettings.fromConfig(config);
});
