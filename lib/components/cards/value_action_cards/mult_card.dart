import 'dart:async';
import 'package:six_seven/components/cards/card.dart';

class MultCard extends ValueActionCard {
  MultCard({required super.value})
    : super(
        cardType: CardType.valueActionMultCard,
        actionText: "x",
        descripTitleText: "Multiply Value",
        descripText: "Current value gets multiplied by $value",
      );

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
  }

  @override
  String toString() {
    return "Mult Card x$value";
  }
}
