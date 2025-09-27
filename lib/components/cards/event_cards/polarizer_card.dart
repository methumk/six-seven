//Choice draw: User can choose to reverse the polarity for any of the value action cards in their hand
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class PolarizerCard extends EventActionCard {
  PolarizerCard();

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
          "User can choose to reverse the polarity for any of the value action cards in their hand.",
      descriptionTitle: "PolarizerCard",
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
      "${cardType.label} User can choose to reverse the polarity for any of the value action cards in their hand.",
    );
  }
}
