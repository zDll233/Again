import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

/// 封面 FileImage 实例缓存（FIFO）。
/// 每次 build 新建 FileImage 会让全局 ImageCache 永远 miss，
/// 复用同一实例 + ResizeImage 才能命中缓存。
const int _maxCoverCacheSize = 300;
final Map<String, FileImage> _coverImageCache = {};

FileImage _cachedFileImage(String path) {
  final cached = _coverImageCache[path];
  if (cached != null) {
    // 简单的 LRU: 重新插入到末尾
    _coverImageCache.remove(path);
    _coverImageCache[path] = cached;
    return cached;
  }
  if (_coverImageCache.length >= _maxCoverCacheSize) {
    _coverImageCache.remove(_coverImageCache.keys.first);
  }
  final image = FileImage(File(path));
  _coverImageCache[path] = image;
  return image;
}

class ImageThumbnail extends StatelessWidget {
  final String imagePath;
  final double imageSize;

  /// 可选覆盖宽高 (默认正方形 [imageSize]×[imageSize])。
  final double? imageWidth;
  final double? imageHeight;

  const ImageThumbnail({
    super.key,
    required this.imagePath,
    this.imageSize = 75.0,
    this.imageWidth,
    this.imageHeight,
  });

  void openImageDialog(BuildContext context, ImageProvider imageProvider) =>
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final controller = PhotoViewController();
          return Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                final scale = controller.scale ?? 1.0;
                final newScale = scale - event.scrollDelta.dy / 1000;
                controller.scale = newScale.clamp(0.1, 5.0);
              }
            },
            child: Dialog(
              insetPadding: EdgeInsets.all(70.0),
              backgroundColor: Colors.transparent,
              child: ClipRect(
                child: PhotoView(
                  tightMode: true,
                  loadingBuilder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  backgroundDecoration:
                      BoxDecoration(color: Colors.transparent),
                  imageProvider: imageProvider,
                  controller: controller,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final coverFile = File(imagePath);
    final imageProvider = imagePath.isNotEmpty && coverFile.existsSync()
        ? _cachedFileImage(imagePath)
        : const AssetImage('assets/images/nocover.jpg') as ImageProvider;
    // 按 DPR 换算物理像素解码: 否则小尺寸缓存图在 DPR 1.5 下
    // 被放大, 看起来发糊
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final w = imageWidth ?? imageSize;
    final h = imageHeight ?? imageSize;
    final cacheHeight = (h * dpr).round();
    return GestureDetector(
      onTap: () => openImageDialog(context, imageProvider),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.0),
          child: Image(
            image: ResizeImage(imageProvider, height: cacheHeight),
            width: w,
            height: h,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
