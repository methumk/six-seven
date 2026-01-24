import 'dart:ui';

import 'package:flame/components.dart';

/// Glow component with multiple layers for a more pronounced effect
class GlowComponent extends PositionComponent with HasVisibility {
  final Vector2 cardSize;
  final Color glowColor;
  final double borderRadius;
  final int glowLayers;

  bool animate = false;
  double _glowScale = 0.0; // 0 = no glow, 1 = full glow
  bool _isTransitioning = false;
  bool _targetState = false;

  GlowComponent({
    required this.cardSize,
    required this.glowColor,
    required this.borderRadius,
    this.glowLayers = 3,
    this.animate = false,
  }) {
    size = cardSize;
  }

  void startTransition(bool toGlowing) {
    if (animate) {
      _targetState = toGlowing;
      _isTransitioning = true;
    } else {
      // Instant transition when animation is disabled
      _glowScale = toGlowing ? 1.0 : 0.0;
      _isTransitioning = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isTransitioning) {
      final speed = 3.0; // Speed of transition

      if (_targetState) {
        // Growing
        _glowScale += dt * speed;
        if (_glowScale >= 1.0) {
          _glowScale = 1.0;
          _isTransitioning = false;
        }
      } else {
        // Shrinking
        _glowScale -= dt * speed;
        if (_glowScale <= 0.0) {
          _glowScale = 0.0;
          _isTransitioning = false;
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_glowScale <= 0.0) return; // Don't render if no glow

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // Draw multiple glow layers with decreasing opacity
    for (int i = glowLayers; i > 0; i--) {
      final offset = i * 3.0 * _glowScale; // Scale the glow size
      final expandedRect = Rect.fromLTWH(
        -offset,
        -offset,
        size.x + offset * 2,
        size.y + offset * 2,
      );

      final rrect = RRect.fromRectAndRadius(
        expandedRect,
        Radius.circular(borderRadius + offset),
      );

      // Calculate opacity - outer layers are more transparent
      final baseOpacity = (1.0 - (i / (glowLayers + 1))) * 0.6;
      final opacity = baseOpacity * _glowScale;

      final glowPaint =
          Paint()
            ..color = glowColor.withValues(alpha: opacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, offset * 0.5);

      canvas.drawRRect(rrect, glowPaint);
    }

    // Draw a solid inner glow
    final innerRRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );
    final innerOpacity = 0.4 * _glowScale;
    final innerGlowPaint =
        Paint()
          ..color = glowColor.withValues(alpha: innerOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;

    canvas.drawRRect(innerRRect, innerGlowPaint);
  }
}
