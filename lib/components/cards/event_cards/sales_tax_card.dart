//Regressive Income Tax Card, probably a super harsh one of -15
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class SalesTax extends EventActionCard {
  SalesTax();
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    await initCardIcon("game_ui/test.png");
    initDescriptionText(
      description:
          "Player gets to enforce a sales tax on their player of choice!",
      descriptionTitle: "Sales Tax",
    );
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} player gets to enforce a sales tax on their player of choice!",
    );
  }
}
