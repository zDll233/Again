import 'package:again/common/const.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 主题色相来源: primary 无彩色 (极端主题下可退化为纯白) 时回退 seed 色相。
HSVColor resolveThemeHueSource(ColorScheme scheme, Color seedColor) {
  final primaryHsv = HSVColor.fromColor(scheme.primary);
  return primaryHsv.saturation > 0.1
      ? primaryHsv
      : HSVColor.fromColor(seedColor);
}

/// 字体颜色设置: 色相可跟随主题色, 只调饱和/明度; 也可用自定义色。
class ColorSetting {
  final bool themeHue;
  final double sat;
  final double val;
  final Color? color;

  const ColorSetting({
    this.themeHue = false,
    this.sat = 0.7,
    this.val = 0.7,
    this.color,
  });

  /// 解析出实际颜色。
  /// [themeHueSource]: 主题色相来源 (primary 或 seed 的 HSV)。
  Color resolve(Color fallback, HSVColor themeHueSource) {
    if (themeHue) {
      return HSVColor.fromAHSV(1, themeHueSource.hue, sat, val).toColor();
    }
    return color ?? fallback;
  }

  /// 写配置时生成键值 (baseKey 前缀)。
  Map<String, dynamic> toConfig(String baseKey) {
    if (themeHue) {
      return {
        '${baseKey}Theme': true,
        '${baseKey}Sat': sat,
        '${baseKey}Val': val,
      };
    }
    return {baseKey: _toHex(color ?? kDefaultThemeSeed)};
  }

  /// 该设置占用的配置键 (重置/清理用)。
  static List<String> keys(String baseKey) => [
        baseKey,
        '${baseKey}Theme',
        '${baseKey}Sat',
        '${baseKey}Val',
      ];

  static String _toHex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
}

/// 文字/字体设置 (config.json 键均可选, 缺省用界面默认值)。
class TextSettings {
  final double panelTextSize;
  final double panelTitleSize;
  final double progressTextSize;
  final double lyricTitleSize;
  final double lyricSize;
  final ColorSetting? panelTextColor;
  final ColorSetting? panelTitleColor;
  final ColorSetting? progressTextColor;
  final ColorSetting? lyricHighlightColor;
  final ColorSetting? lyricColor;
  final ColorSetting? lyricTitleColor;
  final double lyricLineGap;
  final String lyricAlign; // 'center' | 'left'
  final double lyricCurrentSize; // 当前播放歌词行字号 (缺省 = 歌词字号 + 2)

  const TextSettings({
    this.panelTextSize = 14,
    this.panelTitleSize = 14,
    this.progressTextSize = 16,
    this.lyricTitleSize = 28,
    this.lyricSize = 18,
    this.lyricCurrentSize = 20,
    this.panelTextColor,
    this.panelTitleColor,
    this.progressTextColor,
    this.lyricHighlightColor,
    this.lyricColor,
    this.lyricTitleColor,
    this.lyricLineGap = 25,
    this.lyricAlign = 'left',
  });

  factory TextSettings.fromConfig(Map<String, dynamic> config) {
    double size(String key, double fallback) {
      final v = config[key];
      return v is num ? v.toDouble() : fallback;
    }

    ColorSetting? color(String baseKey) {
      if (config['${baseKey}Theme'] == true) {
        final sat = config['${baseKey}Sat'];
        final val = config['${baseKey}Val'];
        return ColorSetting(
          themeHue: true,
          sat: sat is num ? sat.toDouble() : 0.7,
          val: val is num ? val.toDouble() : 0.7,
        );
      }
      final v = config[baseKey];
      if (v is String) {
        final c = parseHexColor(v);
        if (c != null) return ColorSetting(color: c);
      }
      return null;
    }

    return TextSettings(
      panelTextSize: size('panelTextSize', 14),
      panelTitleSize: size('panelTitleSize', 14),
      progressTextSize: size('progressTextSize', 16),
      lyricTitleSize: size('lyricTitleSize', 28),
      lyricSize: size('lyricSize', 18),
      // 当前行字号缺省跟随歌词字号 + 2
      lyricCurrentSize:
          size('lyricCurrentSize', size('lyricSize', 18) + 2),
      panelTextColor: color('panelTextColor'),
      panelTitleColor: color('panelTitleColor'),
      progressTextColor: color('progressTextColor'),
      lyricHighlightColor: color('lyricHighlightColor'),
      lyricColor: color('lyricColor'),
      lyricTitleColor: color('lyricTitleColor'),
      lyricLineGap: size('lyricLineGap', 25),
      lyricAlign: config['lyricAlign'] == 'center' ? 'center' : 'left',
    );
  }

  /// 重置时移除的配置键。
  static const List<String> baseKeys = [
    'panelTextSize',
    'panelTitleSize',
    'progressTextSize',
    'lyricTitleSize',
    'lyricSize',
    'lyricCurrentSize',
    'lyricLineGap',
    'lyricAlign',
  ];

  static const List<String> colorBaseKeys = [
    'panelTextColor',
    'panelTitleColor',
    'progressTextColor',
    'lyricHighlightColor',
    'lyricColor',
    'lyricTitleColor',
  ];

  static List<String> get allKeys => [
        ...baseKeys,
        for (final k in colorBaseKeys) ...ColorSetting.keys(k),
      ];
}

final textSettingsProvider =
    FutureProvider.autoDispose<TextSettings>((ref) async {
  final config = await ref.read(configJsonProvider).read();
  return TextSettings.fromConfig(config);
});
