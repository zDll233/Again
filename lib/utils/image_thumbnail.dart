import 'dart:io';
import 'package:flutter/material.dart';

class ImageThumbnail extends StatelessWidget {
  final String? imagePath;
  final double imageSize;

  const ImageThumbnail({
    super.key,
    required this.imagePath,
    this.imageSize = 75.0,
  });

  Widget _buildImage(ImageProvider imageProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: Image(
        image: ResizeImage(
          imageProvider,
          height: imageSize.toInt(),
        ),
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var coverFile = File(imagePath!);
    return _buildImage(
      coverFile.existsSync()
          ? FileImage(coverFile)
          : const AssetImage('assets/images/nocover.jpg') as ImageProvider,
    );
  }
}
