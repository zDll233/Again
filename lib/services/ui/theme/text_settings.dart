import 'package:again/common/const.dart';
import 'package:again/services/ui/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 文字/字体设置 (config.json 键均可选, 缺省用界面默认值)。
class TextSettings {
  final double panelTextSize;
  final double panelTitleSize;
  final double progressTextSize;
  final double lyricTitleSize;
  final double lyricSize;
  final Color? panelTextColor;
  final Color? panelTitleColor;
  final Color? progressTextColor;
  final Color? lyricHighlightColor;
  final Color? lyricColor;

  const TextSettings({
    this.panelTextSize = 16,
    this.panelTitleSize = 14,
    this.progressTextSize = 16,
    this.lyricTitleSize = 28,
    this.lyricSize = 18,
    this.panelTextColor,
    this.panelTitleColor,
    this.progressTextColor,
    this.lyricHighlightColor,
    this.lyricColor,
  });

  factory TextSettings.fromConfig(Map<String, dynamic> config) {
    double size(String key, double fallback) {
      final v = config[key];
      return v is num ? v.toDouble() : fallback;
    }

    Color? color(String key) {
      final v = config[key];
      return v is String ? parseHexColor(v) : null;
    }

    return TextSettings(
      panelTextSize: size('panelTextSize', 16),
      panelTitleSize: size('panelTitleSize', 14),
      progressTextSize: size('progressTextSize', 16),
      lyricTitleSize: size('lyricTitleSize', 28),
      lyricSize: size('lyricSize', 18),
      panelTextColor: color('panelTextColor'),
      panelTitleColor: color('panelTitleColor'),
      progressTextColor: color('progressTextColor'),
      lyricHighlightColor: color('lyricHighlightColor'),
      lyricColor: color('lyricColor'),
    );
  }

  /// 重置时移除的配置键。
  static const List<String> keys = [
    'panelTextSize',
    'panelTitleSize',
    'progressTextSize',
    'lyricTitleSize',
    'lyricSize',
    'panelTextColor',
    'panelTitleColor',
    'progressTextColor',
    'lyricHighlightColor',
    'lyricColor',
  ];
}

final textSettingsProvider =
    FutureProvider.autoDispose<TextSettings>((ref) async {
  final config = await ref.read(configJsonProvider).read();
  return TextSettings.fromConfig(config);
});
