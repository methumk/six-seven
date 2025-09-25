import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WrappingTextBox extends PositionComponent {
  final String text;
  final Vector2 boxSize;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final TextOverflow overflow;

  late final TextPainter _painter;

  WrappingTextBox({
    required this.text,
    required this.boxSize,
    required this.textStyle,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.clip, // Options: clip, ellipsis, fade
    Vector2? position,
    super.priority,
    super.anchor,
  }) : super(position: position ?? Vector2.zero(), size: boxSize);

  @override
  Future<void> onLoad() async {
    _painter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
      maxLines: null, // Allow wrapping
      ellipsis: overflow == TextOverflow.ellipsis ? '…' : null,
    );

    _painter.layout(maxWidth: size.x);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Clip to the bounding box
    canvas.save();
    canvas.clipRect(size.toRect());

    // Paint text
    _painter.paint(canvas, Offset.zero);

    canvas.restore();
  }
}
