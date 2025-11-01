import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class RoundedBorderComponent extends PositionComponent {
  double borderWidth;
  Color borderColor;
  Color? fillColor;
  double borderRadius;

  RoundedBorderComponent({
    Vector2? position,
    Vector2? size,
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
    this.borderRadius = 12.0,
    this.fillColor,
  }) {
    this.position = position ?? Vector2.all(0);
    this.size = size ?? Vector2.all(0);
  }

  void setBorderColor(Color color) => borderColor = color;
  void setFillColor(Color? color) => fillColor = color;
  void setBorderWidth(double width) => borderWidth = width;
  void setBorderRadius(double radius) => borderRadius = radius;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    if (fillColor != null) {
      final fillPaint =
          Paint()
            ..color = fillColor!
            ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);
    }

    // Border
    final borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;
    canvas.drawRRect(rrect, borderPaint);
  }

  Future<void> moveTo(
    Vector2 target,
    double duration, {
    Curve curve = Curves.easeInOut,
  }) async {
    final completer = Completer<void>();

    // Remove existing MoveEffect if any
    removeWhere((c) => c is MoveEffect);

    add(
      MoveEffect.to(
        target,
        EffectController(duration: duration, curve: curve),
        onComplete: completer.complete,
      ),
    );

    return completer.future;
  }
}
