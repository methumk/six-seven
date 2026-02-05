import 'package:flame/components.dart';
import 'package:flame_svg/svg_component.dart';
import 'package:flutter/material.dart';

class RoundedBorderComponent extends PositionComponent with HasVisibility {
  double borderWidth;
  Color borderColor;
  Color? fillColor;
  SvgComponent? fillImage;
  double borderRadius;

  final Paint _borderPaint = Paint();
  final Paint _fillPaint = Paint();

  RoundedBorderComponent({
    Vector2? position,
    Vector2? size,
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
    this.borderRadius = 12.0,
    this.fillColor,
  }) {
    this.position = position ?? Vector2.zero();
    this.size = size ?? Vector2.zero();

    _updatePaints();
  }

  void _updatePaints() {
    _borderPaint
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    if (fillColor != null) {
      _fillPaint
        ..color = fillColor!
        ..style = PaintingStyle.fill;
    }
  }

  void setBorderColor(Color color) {
    borderColor = color;
    _updatePaints();
  }

  void setFillColor(Color? color) {
    fillColor = color;
    _updatePaints();
  }

  void setFillImage(SvgComponent image) {
    fillImage?.removeFromParent();
    fillImage =
        image
          ..position = Vector2.zero()
          ..size = size
          ..anchor = Anchor.topLeft;
    fillColor = null;
    add(fillImage!);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    if (fillColor != null) {
      canvas.drawRRect(rrect, _fillPaint);
    }

    canvas.drawRRect(rrect, _borderPaint);
  }
}
