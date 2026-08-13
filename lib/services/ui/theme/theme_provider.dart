import 'package:again/services/ui/ui_providers.dart';
import 'package:again/utils/cover_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 当前选中作品的封面路径(用于动态主题取色)。
final selectedCoverPathProvider = Provider<String?>((ref) {
  final selected =
      ref.watch(voiceWorkProvider.select((state) => state.selectedItem));
  return selected.coverPath;
});

/// 封面主色(异步提取, 失败回退默认紫色)。
final coverSeedColorProvider = FutureProvider.autoDispose<Color>((ref) async {
  final coverPath = ref.watch(selectedCoverPathProvider);
  if (coverPath == null || coverPath.isEmpty) {
    return kDefaultThemeSeed;
  }
  return CoverColorExtractor.extract(coverPath);
});

/// 应用主题: 跟随封面主色动态生成。
final appThemeProvider = Provider<ThemeData>((ref) {
  final seed = ref.watch(coverSeedColorProvider).valueOrNull ??
      kDefaultThemeSeed;
  return _buildTheme(seed);
});

ThemeData _buildTheme(Color seed) {
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  final base = ThemeData(colorScheme: scheme);

  return base.copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    listTileTheme: ListTileThemeData(
      selectedColor: scheme.onSecondaryContainer,
      selectedTileColor: scheme.secondaryContainer.withValues(alpha: 0.30),
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
