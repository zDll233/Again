import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// 从封面图片中提取主色, 用于动态主题。
/// 解码降采样到 64x64 后统计, 控制主线程开销。

const Color kDefaultThemeSeed = Color(0xFF9C6BFF);

/// 解码图片并统计主色, 解码失败/无彩色主色时返回 null。
Future<int?> _dominantColor(Uint8List bytes) async {
  final codec =
      await ui.instantiateImageCodec(bytes, targetWidth: 64, targetHeight: 64);
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final data = await image.toByteData();
  image.dispose();

  if (data == null) {
    return null;
  }

  // 量化颜色桶: 每通道 4bit -> 4096 桶
  final counts = <int, int>{};
  final rSum = <int, int>{};
  final gSum = <int, int>{};
  final bSum = <int, int>{};

  final pixels = data.buffer.asUint8List();
  final n = (pixels.length / 4).floor();
  for (var i = 0; i < n; i++) {
    final offset = i * 4;
    final a = pixels[offset + 3];
    if (a < 128) continue; // 忽略透明像素

    final r = pixels[offset];
    final g = pixels[offset + 1];
    final b = pixels[offset + 2];

    // 忽略接近黑白灰的颜色(它们不是"主色"气质)
    final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
    final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
    if (maxC - minC < 24) continue;

    final bucket = ((r >> 4) << 8) | ((g >> 4) << 4) | (b >> 4);
    counts[bucket] = (counts[bucket] ?? 0) + 1;
    rSum[bucket] = (rSum[bucket] ?? 0) + r;
    gSum[bucket] = (gSum[bucket] ?? 0) + g;
    bSum[bucket] = (bSum[bucket] ?? 0) + b;
  }

  if (counts.isEmpty) {
    return null;
  }

  // 取出现最多的桶
  var bestBucket = 0;
  var bestCount = -1;
  counts.forEach((bucket, count) {
    if (count > bestCount) {
      bestCount = count;
      bestBucket = bucket;
    }
  });

  return Color.fromARGB(
    255,
    (rSum[bestBucket]! / counts[bestBucket]!).round(),
    (gSum[bestBucket]! / counts[bestBucket]!).round(),
    (bSum[bestBucket]! / counts[bestBucket]!).round(),
  ).toARGB32();
}

/// 提取封面主色(带内存缓存), 文件缺失/解码失败/无彩色主色时返回 null。
/// 注意: 不能在 compute isolate 中调用 dart:ui 解码 (Windows 上后台
/// isolate 没有图像解码器注册表, 会抛异常), 必须在主 isolate 解码。
class CoverColorExtractor {
  static const int _maxCacheSize = 64;
  static final Map<String, Color> _cache = {};

  static Future<Color?> extract(String imagePath) async {
    final cached = _cache[imagePath];
    if (cached != null) {
      return cached;
    }
    if (!File(imagePath).existsSync()) {
      return null;
    }

    final bytes = await File(imagePath).readAsBytes();
    final argb = await _dominantColor(bytes);
    if (argb == null) {
      return null;
    }
    final color = Color(argb);

    if (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[imagePath] = color;
    return color;
  }
}
