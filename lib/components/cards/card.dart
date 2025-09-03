import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

enum CardType {
  numberCard("Number card of value: "),
  valueActionCard("Value Action Card of value: "),
  eventActionCard("Event Action Card with effect: ");

  final String label;
  const CardType(this.label);
}

//Base card class
abstract class Card {
  late CardType cardType;

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
  NumberCard({required double value}) : super(cardType: CardType.numberCard) {
    _value = value;
  }

  double get value => _value;
  set value(double value) => _value = value;

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
}
