import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class TextButton extends SpriteButtonComponent {
  late final Vector2 pos;
  late final Vector2 upBtnSize;
  late final Vector2 downBtnSize;
  late final TextComponent textComponent;
  late void Function() stayPressed;
  late final String text;
  late final ui.Image downBtnImg;
  late final ui.Image upBtnImg;

  TextButton({
    required this.text,
    required this.stayPressed,
    required this.upBtnSize,
    required this.upBtnImg,
    required this.downBtnSize,
    required this.downBtnImg,
    required Vector2 pos,
    required Vector2 size,
    required Anchor anchor,
  }) : super(size: size, anchor: anchor, position: pos);

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Set up Sprite Button
    button = Sprite(upBtnImg, srcSize: upBtnSize);
    buttonDown = Sprite(downBtnImg, srcSize: downBtnSize);
    onPressed = stayPressed;

    // Set up text
    textComponent = TextComponent(
      text: text,
      priority: 3,
      anchor: Anchor.center,
      position: Vector2(size.x * .5, size.y * .4),
      size: size,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: size.y * 0.65,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(textComponent);
  }
}
