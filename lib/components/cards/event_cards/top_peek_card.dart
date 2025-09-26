//Magnifying Glass: Can see the next card in the deck before making decision
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class TopPeekCard extends EventActionCard {
  TopPeekCard();

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
      description:
          "The player that gets chosen is allowed to take a peek at the next card in the deck!",
      descriptionTitle: "Top Peek",
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
      "${cardType.label} the player that gets chosen is allowed to take a peek at the next card in the deck!",
    );
  }
}
