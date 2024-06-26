import 'package:flutter/material.dart';

class RectangleOverlayShape extends SliderComponentShape {
  final Size? shapeSize;
  RectangleOverlayShape({this.shapeSize});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return shapeSize ?? const Size(4.0, 20.0);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()
      ..color = sliderTheme.overlayColor ?? Colors.transparent;

    var size = getPreferredSize(true, true);
    Rect rect =
        Rect.fromCenter(center: center, width: size.width, height: size.height);

    canvas.drawRect(rect, paint);
  }
}
