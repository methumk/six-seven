import 'dart:async';
import 'package:six_seven/components/cards/card.dart';

class MinusCard extends ValueActionCard {
  MinusCard({required super.value})
    : super(
        cardType: CardType.valueActionMinusCard,
        actionText: "-",
        descripTitleText: "Subtract Value",
        descripText: "Current value gets decreased by $value",
      );

  @override
  double executeOnStay(double currentValue) {
    currentValue -= value;
    return currentValue;
  }

  @override
  void description() {
    print("${cardType.label} - $value");
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
  }

  @override
  String toString() {
    return "Minus Card -$value";
  }
}
