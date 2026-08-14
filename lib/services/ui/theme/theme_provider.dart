import 'package:again/common/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 默认主题种子色 (对应 kDefaultThemeSeedHex)。
const Color kDefaultThemeSeed = Color(0xFF9C6BFF);

/// 解析自定义主题色, 缺省返回默认紫色 (#RRGGBB)。
String resolveThemeSeedHex(Map<String, dynamic> config) {
  final v = config['themeSeedColor'];
  return v is String && v.isNotEmpty ? v : kDefaultThemeSeedHex;
}

/// 解析 #RRGGBB / RRGGBB 十六进制颜色, 非法返回 null。
Color? parseHexColor(String hex) {
  final cleaned = hex.replaceAll('#', '').trim();
  if (cleaned.length != 6) return null;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return null;
  return Color(0xFF000000 | value);
}

/// 文字颜色模式解析: 优先 `textColorMode`, 兼容旧 `accentColorMode`, 缺省跟随主题色。
String resolveTextColorMode(Map<String, dynamic> config) {
  final v = config['textColorMode'] ?? config['accentColorMode'];
  return v is String && v.isNotEmpty ? v : TEXT_MODE_FOLLOW;
}

/// 文字颜色解析 (#RRGGBB), 缺省 M3 dark onSurface。
String resolveTextColorHex(Map<String, dynamic> config) {
  final v = config['textColor'] ?? config['accentColor'];
  return v is String && v.isNotEmpty ? v : kDefaultTextColorHex;
}

/// 主题种子色: 手动设置的主题色 (跟随封面功能已移除)。
final coverSeedColorProvider = FutureProvider.autoDispose<Color>((ref) async {
  final config = await ref.read(configJsonProvider).read();
  return parseHexColor(resolveThemeSeedHex(config)) ?? kDefaultThemeSeed;
});

/// 文字颜色 (主文字/选中项文字): follow=随主题色, custom=独立颜色。
final textColorProvider = FutureProvider.autoDispose<({String mode, Color color})>(
    (ref) async {
  final config = await ref.read(configJsonProvider).read();
  return (
    mode: resolveTextColorMode(config),
    color:
        parseHexColor(resolveTextColorHex(config)) ?? kDefaultThemeSeed,
  );
});

/// 窗口背景效果解析: 优先 `windowEffect`, 兼容旧配置 `liquidGlass`
/// (true=acrylic, false=transparent), 缺省 acrylic。
String resolveWindowEffect(Map<String, dynamic> config) {
  final v = config['windowEffect'];
  if (v is String && v.isNotEmpty) return v;
  return config['liquidGlass'] == false
      ? WINDOW_EFFECT_TRANSPARENT
      : WINDOW_EFFECT_ACRYLIC;
}

/// 窗口背景效果模式 ('transparent' | 'acrylic' | 'opaque')。
final windowEffectProvider = FutureProvider.autoDispose<String>((ref) async {
  final config = await ref.read(configJsonProvider).read();
  return resolveWindowEffect(config);
});

/// 列表搜索开关 (config.json `searchEnabled`, 默认开启)。
final searchEnabledProvider = FutureProvider.autoDispose<bool>((ref) async {
  final config = await ref.read(configJsonProvider).read();
  return config['searchEnabled'] != false;
});

/// 应用主题: 由自定义主题色生成; 文字颜色独立设置时覆盖文字角色。
final appThemeProvider = Provider<ThemeData>((ref) {
  final seed = ref.watch(coverSeedColorProvider).valueOrNull ??
      kDefaultThemeSeed;
  final text = ref.watch(textColorProvider).valueOrNull;
  return _buildTheme(seed, text);
});

ThemeData _buildTheme(Color seed, ({String mode, Color color})? text) {
  var scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  if (text != null && text.mode == TEXT_MODE_CUSTOM) {
    // 文字独立: 主文字/次文字改用固定色; 选中项文字与高亮仍用主题色
    final c = text.color;
    scheme = scheme.copyWith(
      onSurface: c,
      onSurfaceVariant:
          Color.alphaBlend(c.withValues(alpha: 0.72), scheme.surface),
    );
  }
  final base = ThemeData(
    colorScheme: scheme,
    // 统一字体族: 避免 Segoe UI + 微软雅黑混排, 中文粗细不一致
    fontFamily: 'Microsoft YaHei',
    fontFamilyFallback: const ['Microsoft YaHei UI', 'Segoe UI', 'SimHei'],
  );

  // 字重扁平化: 微软雅黑只有 400/700 真实字重,
  // w500/w600 会被系统合成加粗导致粗细不均, 统一映射到真实字重
  final textTheme = base.textTheme.copyWith(
    titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    titleMedium:
        base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    titleSmall:
        base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    labelLarge:
        base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
    labelMedium:
        base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w400),
    labelSmall:
        base.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w400),
  );

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: Colors.transparent,
    listTileTheme: ListTileThemeData(
      selectedColor: scheme.primary,
      selectedTileColor: scheme.secondaryContainer.withValues(alpha: 0.20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      dense: true,
    ),
    sliderTheme: SliderThemeData(
      trackHeight: 3.0,
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.15),
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
      overlayColor: scheme.primary.withValues(alpha: 0.15),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        hoverColor: scheme.onSurface.withValues(alpha: 0.08),
        focusColor: Colors.transparent,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.onSurface.withValues(alpha: 0.85),
        overlayColor: scheme.onSurface.withValues(alpha: 0.08),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.primary.withValues(alpha: 0.35),
    ),
  );
}
