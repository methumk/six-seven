import 'dart:async';
import 'package:six_seven/components/cards/card.dart';

class PlusCard extends ValueActionCard {
  PlusCard({required super.value})
    : super(
        cardType: CardType.valueActionPlusCard,
        actionText: "+",
        descripTitleText: "Plus Value",
        descripText: "Current value gets increased by $value",
      );

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
  }

  @override
  String toString() {
    return "Plus Card +$value";
  }
}
