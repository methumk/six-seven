import 'dart:async';
import 'package:six_seven/components/cards/card.dart';

class MultCard extends ValueActionCard {
  MultCard({required super.value}) {
    cardType = CardType.valueActionMultCard;
  }

  @override
  double executeOnStay(double cv) {
    return cv * value;
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
