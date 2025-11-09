import 'dart:async';
import 'package:six_seven/components/cards/card.dart';

class PlusCard extends ValueActionCard {
  PlusCard({required super.value}) {
    cardType = CardType.valueActionPlusCard;
  }

  @override
  double executeOnStay(double cv) {
    return cv + value;
  }

  @override
  void description() {
    print("${cardType.label} + $value");
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    initTitleText("+");
    initDescriptionText(
      descriptionTitle: "Plus Value",
      description: "Current value gets increased by $value",
    );
  }

  @override
  String toString() {
    return "Plus Card +$value";
  }
}
