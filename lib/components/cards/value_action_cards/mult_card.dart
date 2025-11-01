import 'dart:async';
import 'package:six_seven/components/cards/card.dart';

class MultCard extends ValueActionCard {
  MultCard({required super.value});

  @override
  double executeOnStay(double currentValue) {
    currentValue *= value;
    return currentValue;
  }

  @override
  void description() {
    print("${cardType.label} x $value");
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    initTitleText("x");
    initDescriptionText(
      descriptionTitle: "Multiply Value",
      description: "Current value gets multiplied by $value",
    );
  }

  @override
  String toString() {
    return "Mult Card x$value";
  }
}
