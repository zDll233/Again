import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageThumbnail extends StatelessWidget {
  final String imagePath;
  final double imageSize;

  const ImageThumbnail({
    super.key,
    required this.imagePath,
    this.imageSize = 75.0,
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
                  loadingBuilder: (_, __) => const Center(child: CircularProgressIndicator()),
                  backgroundDecoration: BoxDecoration(color: Colors.transparent),
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
    final imageProvider = coverFile.existsSync()
        ? FileImage(coverFile)
        : const AssetImage('assets/images/nocover.jpg') as ImageProvider;
    return GestureDetector(
      onTap: () => openImageDialog(context, imageProvider),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: Image(
          image: ResizeImage(imageProvider, height: imageSize.toInt()),
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
