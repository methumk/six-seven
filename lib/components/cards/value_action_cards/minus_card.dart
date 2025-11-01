import 'dart:async';
import 'package:six_seven/components/cards/card.dart';

class MinusCard extends ValueActionCard {
  MinusCard({required super.value});

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
    initTitleText("-");
    initDescriptionText(
      descriptionTitle: "Subtract Value",
      description: "Current value gets decreased by $value",
    );
  }

  @override
  String toString() {
    return "Minus Card -$value";
  }
}
