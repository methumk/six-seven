import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class DoubleChanceCard extends HandEventActionCard {
  DoubleChanceCard();

  //No special execute on stay
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
      description: "The player that gets chosen is granted double chance!",
      descriptionTitle: "Double Chance",
    );
  }

  //Grants double chance
  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} the player that gets chosen is granted double chance!",
    );
  }
}
