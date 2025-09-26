//Reverses turn order
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class ReverseTurn extends EventActionCard {
  ReverseTurn();

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
      description: "Reverses turn order!",
      descriptionTitle: "Reverse Turn",
    );
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print("${cardType.label} Reverses turn order!");
  }
}
