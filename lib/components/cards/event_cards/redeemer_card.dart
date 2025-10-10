//Choice draw: User can choose to reverse the polarity for any of the value action cards in their hand
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class RedeemerCard extends HandEventActionCard {
  RedeemerCard();

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
          "User will have this card for the remainder the round. If they get a duplicate number card, instead of busting, they get 67% of the points from the round (not including duplicate)!",
      descriptionTitle: "Redeemer",
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
      "${cardType.label} User will have this card for the remainder the round. " +
          "If they get a duplicate number card, instead of busting, they get 67% of " +
          "the points from the round (not including duplicate).",
    );
  }
}
