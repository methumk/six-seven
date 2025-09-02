import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/card.dart';

class NumberCardUI extends RectangleComponent with DragCallbacks, TapCallbacks {
  late final Paint _paint;
  late final NumberCard _numberCard;

  NumberCardUI({required Vector2 pos, required double numberValue})
    : super(size: Vector2(60, 120), position: pos) {
    _numberCard = NumberCard(value: numberValue);
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    _paint = Paint()..color = Colors.white;
    paint = _paint;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    paint.color = Colors.red;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.canvasDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    paint.color = Colors.white;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    print("Tapping down");
  }

  void onButtonTestClick() {
    paint.color = Colors.green;
  }

  void onButtonTestUnClick() {
    paint.color = Colors.white;
  }

  @override
  bool get debugMode => true;
}
