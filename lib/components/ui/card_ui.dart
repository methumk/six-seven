import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class NumberCardUI extends PositionComponent with DragCallbacks, TapCallbacks {
  final _paint = Paint();
  bool _isDragged = false;

  NumberCardUI() : super(size: Vector2(60, 120));

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragged = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.canvasDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragged = false;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _paint.color = _isDragged ? Colors.red : Colors.white;
    canvas.drawRect(size.toRect(), _paint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    print("Tapping down");
  }

  @override
  bool get debugMode => true;
}
