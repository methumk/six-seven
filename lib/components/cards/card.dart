import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

enum CardType {
  numberCard("Number card of value: "),
  valueActionCard("Value Action Card of value: "),
  eventActionCard("Event Action Card with effect: ");

  final String label;
  const CardType(this.label);
}

//Base card class
abstract class Card extends RectangleComponent
    with DragCallbacks, TapCallbacks {
  late CardType cardType;
  static final double borderRadius = 8.0;
  static final Vector2 cardSizeThirdPerson = Vector2(60, 120);
  static final Vector2 cardSizeFirstPerson = Vector2(80, 140);

  Card({required this.cardType});

  //TO DO: Add players as param inputs for executeOnEvent
  //once player classes have been constructed
  void executeOnEvent();
  double executeOnStay(double currentValue);
  void description();
}

//Base Number Card Class
class NumberCard extends Card {
  late final double _value;
  late final TextComponent _tlText, _trText, _blText, _brText, _cText;
  bool componentInitialized = false;

  NumberCard({required double value}) : super(cardType: CardType.numberCard) {
    _value = value;
  }

  double get value => _value;
  set value(double value) => _value = value;

  void _removeText() {
    if (componentInitialized) {
      removeAll([_tlText, _trText, _blText, _brText, _cText]);
      componentInitialized = false;
    }
  }

  // NOTE: render manually not on load
  void _loadCardComponent({
    required bool firstPersonView,
    required bool faceUp,
  }) {
    if (firstPersonView) {
      size = Card.cardSizeFirstPerson;
    } else {
      size = Card.cardSizeThirdPerson;
    }

    _removeText();

    TextPaint small = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
    TextPaint big = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );

    if (faceUp) {
      bool isInt = _value % 1 == 0;
      String textvalue;
      if (isInt) {
        textvalue = _value.toInt().toString();
      } else {
        textvalue = _value.toString();
      }

      _tlText = TextComponent(
        text: textvalue,
        position: Vector2(size.x * .15, size.y * .1),
        size: Vector2(size.x * .2, size.x * .2),
        anchor: Anchor.center,
        angle: angle,
        textRenderer: small,
      );
      _trText = TextComponent(
        text: textvalue,
        position: Vector2(size.x * .85, size.y * .1),
        size: Vector2(size.x * .2, size.x * .2),
        anchor: Anchor.center,
        angle: angle,
        textRenderer: small,
      );
      _blText = TextComponent(
        text: textvalue,
        position: Vector2(size.x * .15, size.y * .9),
        size: Vector2(size.x * .2, size.x * .2),
        anchor: Anchor.center,
        angle: math.pi,
        textRenderer: small,
      );
      _brText = TextComponent(
        text: textvalue,
        position: Vector2(size.x * .85, size.y * .9),
        size: Vector2(size.x * .2, size.x * .2),
        anchor: Anchor.center,
        angle: math.pi,
        textRenderer: small,
      );
      _cText = TextComponent(
        text: textvalue,
        position: Vector2(size.x * .5, size.y * .5),
        size: Vector2(size.x * .4, size.y * .4),
        anchor: Anchor.center,
        angle: 0,
        textRenderer: big,
      );

      componentInitialized = true;
      addAll([_tlText, _trText, _blText, _brText, _cText]);
    }
  }

  @override
  void executeOnEvent() {}

  @override
  void description() {
    print("${cardType.label} ${_value}");
  }

  @override
  double executeOnStay(double currentValue) {
    currentValue += _value;
    return currentValue;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    paint = Paint()..color = Colors.white;
    _loadCardComponent(faceUp: true, firstPersonView: true);
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

  @override
  bool get debugMode => true;
}

//Event Action Card Class
abstract class EventActionCard extends Card {
  EventActionCard() : super(cardType: CardType.eventActionCard);

  //executeOnEvent depends on the specific event action card
  //like if  it's freeze, flip three, etc. Thus it is left to
  //the child class itself

  @override
  double executeOnStay(double currentValue) {
    print("Check which event action cards have executions on player stay");
    return currentValue;
  }

  @override
  bool get debugMode => true;
}

//Value Action Abstract Card:
abstract class ValueActionCard extends Card {
  late final double _value;
  ValueActionCard({required double value})
    : super(cardType: CardType.valueActionCard) {
    _value = value;
  }

  double get value => _value;

  @override
  void executeOnEvent() {}

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    paint = Paint()..color = Colors.green;
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

  @override
  bool get debugMode => true;
}
