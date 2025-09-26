//Effect: You are to take a card from anywhere inside the deck. Not yet revealing the card,
//you can choose to give it to yourself or any player.
//Once such a player is chosen, they reveal it.
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class CribberCard extends EventActionCard {
  CribberCard();

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
          "You get to crib a random card from the deck, then give it to any player!",
      descriptionTitle: "Cribber",
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
      "${cardType.label} you get to crib a random card from the deck, then give it to any player!",
    );
  }
}
