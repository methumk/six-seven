import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class FreezeCard extends EventActionCard {
  FreezeCard();

  //No special execute on stay function
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
          "The player that gets chosen will be frozen, forcing them to stay for the round!",
      descriptionTitle: "Freeze",
    );
  }

  //Freezes other player
  @override
  void executeOnEvent() {
    //TO DO: Impleme
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} the player that gets chosen will be frozen, forcing them to stay for the round!",
    );
  }
}
