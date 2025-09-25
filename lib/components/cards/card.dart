import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/value_action_text.dart';
import 'package:six_seven/components/rounded_border_component.dart';
import 'package:six_seven/components/wrapping_text_box.dart';
import 'package:six_seven/pages/game/game_manager.dart';

enum CardType {
  numberCard("Number card of value: "),
  valueActionCard("Value Action Card of value: "),
  eventActionCard("Event Action Card with effect: ");

  final String label;
  const CardType(this.label);
}

double truncateToDecimals(double value, int fractionalDigits) {
  double mod = math.pow(10.0, fractionalDigits).toDouble();
  return (value * mod).truncate() / mod;
}

// Will truncate a given double value  to the number of decimal places needed and return the number of digits in the double
int numDigitsInDouble(double value, {int truncateNumDecimals = 0}) {
  double truncated = truncateToDecimals(value, truncateNumDecimals);
  String str = truncated.toString();
  List<String> parts = str.split('.');

  int beforeDecimal = parts[0].length;
  int afterDecimal = parts.length > 1 ? parts[1].length : 0;

  return beforeDecimal + afterDecimal;
}

int numCharsInDouble(double value, {int truncateNumDecimals = 0}) {
  double truncated = truncateToDecimals(value, truncateNumDecimals);
  return truncated.toString().length;
}

// This will round to the safeZone place, so ensure this value doesn't effect your number
String doubleToStringNoTrailingZeros(double value, int safeZone) {
  // Use fixed precision, then strip trailing zeros and decimal if unnecessary
  return value.toStringAsFixed(safeZone).replaceFirst(RegExp(r'\.?0+$'), '');
}

//Base card class
abstract class Card extends RoundedBorderComponent
    with DragCallbacks, TapCallbacks {
  late CardType cardType;
  static final Vector2 cardSize = Vector2(80, 140);
  Card({required this.cardType})
    : super(borderColor: Colors.black, borderWidth: 2.5, borderRadius: 5.0);

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
    anchor = Anchor.bottomCenter;
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
        position: Vector2(Card.cardSize.x * .15, Card.cardSize.y * .1),
        size: Vector2(Card.cardSize.x * .2, Card.cardSize.x * .2),
        anchor: Anchor.center,
        angle: angle,
        textRenderer: small,
      );
      _trText = TextComponent(
        text: textvalue,
        position: Vector2(Card.cardSize.x * .85, Card.cardSize.y * .1),
        size: Vector2(Card.cardSize.x * .2, Card.cardSize.x * .2),
        anchor: Anchor.center,
        angle: angle,
        textRenderer: small,
      );
      _blText = TextComponent(
        text: textvalue,
        position: Vector2(Card.cardSize.x * .15, Card.cardSize.y * .9),
        size: Vector2(Card.cardSize.x * .2, Card.cardSize.x * .2),
        anchor: Anchor.center,
        angle: math.pi,
        textRenderer: small,
      );
      _brText = TextComponent(
        text: textvalue,
        position: Vector2(Card.cardSize.x * .85, Card.cardSize.y * .9),
        size: Vector2(Card.cardSize.x * .2, Card.cardSize.x * .2),
        anchor: Anchor.center,
        angle: math.pi,
        textRenderer: small,
      );
      _cText = TextComponent(
        text: textvalue,
        position: Vector2(Card.cardSize.x * .5, Card.cardSize.y * .5),
        size: Vector2(Card.cardSize.x * .4, Card.cardSize.y * .4),
        anchor: Anchor.center,
        angle: 0,
        textRenderer: big,
      );

      size = Card.cardSize;

      if (!firstPersonView) {
        size *= GameManager.thirdPersonScale.x;
        _tlText.scale.setFrom(GameManager.thirdPersonScale);
        _trText.scale.setFrom(GameManager.thirdPersonScale);
        _blText.scale.setFrom(GameManager.thirdPersonScale);
        _brText.scale.setFrom(GameManager.thirdPersonScale);
        _cText.scale.setFrom(GameManager.thirdPersonScale);
      }

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
    // paint = Paint()..color = Colors.white;
    fillColor = Colors.white;
    _loadCardComponent(faceUp: true, firstPersonView: true);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    // paint.color = Colors.red;
    fillColor = Colors.red;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.canvasDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // paint.color = Colors.white;
    fillColor = Colors.white;
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
  late final WrappingTextBox _descrip;
  late final TextComponent _descripTitle; // Description box
  late final ValueActionTitleText _titleText;
  late final RoundedBorderComponent _bodyDescriptionBorder;

  late final Vector2 _halfCard;
  late final Vector2 _bodyDescripPos;
  late final Vector2 _bodyDescripSize;
  late final Vector2 _bodyDescripPadding;

  ValueActionCard({required double value})
    : super(cardType: CardType.valueActionCard) {
    _value = value;
    _halfCard = Card.cardSize / 2;
    _bodyDescripPos = Vector2(Card.cardSize.x * .1, Card.cardSize.y * .5);
    _bodyDescripSize = Vector2(Card.cardSize.x * .8, Card.cardSize.y * .47);
    // x is top and bottom padding y is left, right
    _bodyDescripPadding = Vector2(7, 5);
  }

  double get value => _value;

  void initDescriptionText({
    String descriptionTitle = "",
    String description = "",
  }) {
    _descripTitle = TextComponent(
      text: descriptionTitle,
      position: Vector2(_halfCard.x, _halfCard.y + _bodyDescripPadding.x),
      size: Vector2(_bodyDescripSize.x, _bodyDescripSize.y * .2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: 7.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    _descrip = WrappingTextBox(
      text: description,
      textStyle: const TextStyle(fontSize: 7, color: Colors.black),
      boxSize: Vector2(
        _bodyDescripSize.x - _bodyDescripPadding.y * 2,
        Card.cardSize.y * .45 - _descripTitle.size.y,
      ),
      position: Vector2(
        _halfCard.x,
        _descripTitle.position.y + _descripTitle.size.y + .5,
      ),
      anchor: Anchor.topCenter,
    );

    addAll([_descripTitle, _descrip]);
  }

  void initTitleText(String valueAction) {
    String valueString = doubleToStringNoTrailingZeros(_value, 5);
    _titleText = ValueActionTitleText(
      valueTypeText: valueAction,
      numberTitleText: valueString,
    );
    add(_titleText);
    final center = _titleText.getCenterSize();
    _titleText.position = Vector2(_halfCard.x, Card.cardSize.y * .3) - center;
  }

  @override
  void executeOnEvent() {}

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Card.cardSize;
    fillColor = Colors.white;
    _bodyDescriptionBorder = RoundedBorderComponent(
      position: _bodyDescripPos,
      size: _bodyDescripSize,
      borderWidth: 1.5,
      borderColor: Colors.black,
      borderRadius: 5.0,
    );
    add(_bodyDescriptionBorder);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    fillColor = Colors.red;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position += event.canvasDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    fillColor = Colors.white;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    print("Tapping down");
  }
}
