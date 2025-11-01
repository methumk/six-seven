import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/deck.dart';

class FlipThreeCard extends EventActionCard {
  FlipThreeCard() {
    eventEnum = EventCardEnum.FlipThree;
  }

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
      description: "The player that gets chosen must flip 3 cards!",
      descriptionTitle: "Flip Three",
    );
  }

  //Forces player to flip 3 cards
  @override
  Future<void> executeOnEvent() async {
    //To Do: implement
    return;
  }

  @override
  void description() {
    print("${cardType.label} the player that gets chosen must flip 3 cards!");
  }
}
