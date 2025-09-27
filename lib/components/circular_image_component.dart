import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class CircularImageComponent extends PositionComponent {
  final String imagePath;
  final double radius;
  final double borderWidth;
  final Color borderColor;

  late ui.Image _image;

  CircularImageComponent({
    required this.imagePath,
    required this.radius,
    this.borderWidth = 4.0,
    this.borderColor = Colors.white,
  }) : super(size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _image = await Flame.images.load(imagePath);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint();

    // Draw circular border
    final borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;
    canvas.drawCircle(
      Offset(radius, radius),
      radius - borderWidth / 2,
      borderPaint,
    );

    // Clip the canvas into a circle
    final rect = Rect.fromCircle(
      center: Offset(radius, radius),
      radius: radius - borderWidth,
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    // Draw the image inside the circle
    paint.isAntiAlias = true;
    canvas.drawImageRect(
      _image,
      Rect.fromLTWH(0, 0, _image.width.toDouble(), _image.height.toDouble()),
      rect,
      paint,
    );

    canvas.restore();
  }
}
