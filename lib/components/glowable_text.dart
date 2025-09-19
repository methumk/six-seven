import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GlowableText extends TextComponent {
  bool highlighted = false;
  // Paint highlightPaint = Paint()..color = Colors.yellow.withAlpha(128);
  late final TextComponent highlightText;
  late final double smallTextSize;
  late final Color smallColor;
  late final Color highlightColor;

  GlowableText({
    required String text,
    required this.smallColor,
    required this.smallTextSize,
    this.highlightColor = Colors.red,
    required Vector2 position,
    Anchor anchor = Anchor.center,
  }) : super(text: text, position: position, anchor: anchor, priority: 0);

  void addHighlight() {
    highlighted = true;
  }

  void removeHighlight() {
    highlighted = false;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    textRenderer = TextPaint(
      style: TextStyle(
        color: smallColor,
        fontSize: smallTextSize,
        fontWeight: FontWeight.bold,
      ),
    );
    // highlightText = TextComponent(
    //   text: text,
    //   // anchor: anchor,
    //   priority: 3,
    //   position: position,
    //   textRenderer: TextPaint(
    //     style: TextStyle(color: highlightColor, fontSize: smallTextSize * 1.05),
    //   ),
    // );

    // add(highlightText);
  }
}
