//Progressive Income Tax Card
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class IncomeTax extends EventActionCard {
  IncomeTax();
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
      description: "Enforces a progressive income tax on the player!",
      descriptionTitle: "Income Tax",
    );
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print("${cardType.label} enforces a progressive income tax on the player!");
  }
}
