import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ValueActionTitleText extends PositionComponent {
  // Value type as separate tile (x, +, -) to center unlike number Title
  late final TextComponent? valueTypeTitle;
  // Number as part of the value title
  late final TextComponent? numberTitle;
  late final String valueTypeText;
  late final String numberTitleText;

  ValueActionTitleText({
    required this.valueTypeText,
    required this.numberTitleText,
  }) : super(anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    valueTypeTitle = TextComponent(
      text: valueTypeText,
      position: Vector2(0, 5),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: TextStyle(color: Colors.black, fontSize: 20),
      ),
    );

    numberTitle = TextComponent(
      text: numberTitleText,
      position: Vector2(0, 0),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: 27,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    addAll([valueTypeTitle!, numberTitle!]);
  }

  Vector2 getCenterSize() {
    if (numberTitle != null && valueTypeTitle != null) {
      var totalCenter = (valueTypeTitle!.size + numberTitle!.size) / 2;
      totalCenter.x = totalCenter.x - valueTypeTitle!.size.x;
      return totalCenter;
    }
    return Vector2(0, 0);
  }
}
